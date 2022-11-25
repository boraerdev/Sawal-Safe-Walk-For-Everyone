//
//  PlanATripViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 8.10.2022.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import CoreLocation
import LBTATools
import AVFoundation

protocol PlanATripViewControllerInterFace: AnyObject {
    func speech(message: String)
    func handleGestureAddPin()
    func handleBlur()
    func preapreExitBtn()
    func prepareRiskView()
    func AddRiskView()
    func RemoveRiskView()
    func configureSomeUI()
    func setupDelegates()
    func prepareFields()
    func startMonitoring()
    func prepareStepData()
    func setStepData(stepNumber: Int)
    func showStepsHud()
    func addTargets()
    func addAnnotation(title: String, item: MKMapItem)
    func updateStartFinishAnnotations()
    func requestForDirections()
    func handleSharedAnnotations()
}

//MARK: Def, UI
final class PlanATripViewController: UIViewController, PlanATripViewControllerInterFace {
    
    //MARK: Def
    var curRiskView: UIViewController?
    var isNowPlaying = false
    let disposeBag = DisposeBag()
    var tripAnnotations = [MKAnnotation]()
    let startAno: MKAnnotation? = nil
    let finishAno: MKAnnotation? = nil
    var mapView = MKMapView()
    let manager = CLLocationManager()
    let viewModel = PlanATripViewModel.shared
    var startItem: MKMapItem? = nil
    var finishItem: MKMapItem? = nil
    let speechSynthesizer = AVSpeechSynthesizer()
    var stepCounter = 0
    var steps: [MKRoute.Step] = []
    var isInstructionsAppear = false

    //MARK: UI
    private var instructionsHud = UIView(backgroundColor: .systemBackground)
    
    lazy var directionLbl = UILabel(font: .systemFont(ofSize: 15), textColor: .label, numberOfLines: 2)
    
    lazy var distanceLbl = UILabel(font: .systemFont(ofSize: 11), textColor: .secondaryLabel, numberOfLines: 1)
    
    lazy var directionImage = UIImageView(image: .init(systemName: "arrow.triangle.turn.up.right.diamond"), contentMode: .scaleAspectFit)
    
    private lazy var fieldsBG = UIView(backgroundColor: .secondarySystemBackground)
    
    private lazy var startField = IndentedTextField(placeholder: "Start", padding: 10)
    
    private lazy var finishField = IndentedTextField(placeholder: "Finish", padding: 10)
    
    private lazy var startIcon = UIImageView(image: .init(systemName: "circle.circle"))
    
    private lazy var exitBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(.init(systemName: "xmark"), for: .normal)
        btn.tintColor = .label
        btn.backgroundColor = .secondarySystemBackground
        btn.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        return btn
    }()
    
    private lazy var header = UIView(backgroundColor: .systemBackground)
    
    private lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(" Go", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.setImage(.init(systemName: "arrowtriangle.right"), for: .normal)
        btn.tintColor = .label
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        return btn
    }()
    
    private lazy var finishIcon = UIImageView(image: .init(systemName: "pin"))
    
    
}

//MARK: Core
extension PlanATripViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        addTargets()
        view.stack(mapView)
        prepareFields()
        preapreExitBtn()
        handleBlur()
        configureSomeUI()
        prepareRiskView()
        DispatchQueue.main.async {
            self.mapView.setUserTrackingMode(.followWithHeading, animated: false)
        }
        handleGestureAddPin()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchSharedLocations()
        handleSharedAnnotations()
        navigationController?.navigationBar.isHidden = true
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        mapView.removeAnnotations(mapView.annotations)
    }
}

//MARK: Funcs
extension PlanATripViewController {
    
    func handleGestureAddPin() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    func handleBlur() {
        let visualBottomBlur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        let visualTopBlur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.addSubviews(visualBottomBlur,visualTopBlur)
        visualBottomBlur.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        visualTopBlur.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    func preapreExitBtn() {
        view.addSubviews(exitBtn)
        exitBtn.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 45, height: 45))
    }
    
    func prepareRiskView() {
        viewModel.riskMode.subscribe { [weak self] result in
            if result.element == .inAreaCloser || result.element == .inAreaAway {
                self?.AddRiskView()
                self?.isNowPlaying = true
            } else {
                self?.RemoveRiskView()
                self?.isNowPlaying = false
            }
        }.disposed(by: disposeBag)
    }
    
    func AddRiskView() {
        guard !isNowPlaying else {return}
        let vc = RiskView()
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        curRiskView = vc
    }
    
    func RemoveRiskView() {
        guard isNowPlaying else {return}
        curRiskView?.navigationController?.popViewController(animated: true)
    }
    
    func configureSomeUI() {
        
        //Corner Radius
        instructionsHud.layer.cornerRadius = 8
        exitBtn.layer.cornerRadius = 8
        fieldsBG.layer.cornerRadius = 8
        fieldsBG.layer.masksToBounds = true
        
        [startField, finishField].forEach { field in
            field.withHeight(45)
            field.textColor = .label
            field.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
            field.layer.borderWidth = 0.2
            field.layer.cornerRadius = 8
            field.backgroundColor = .systemBackground
        }
        
        instructionsHud.layer.borderWidth = 2
        instructionsHud.layer.cornerRadius = 8
        instructionsHud.layer.borderColor = UIColor.main3.cgColor
        directionImage.tintColor = .main3

        startField.attributedPlaceholder = .init(string: "Start", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.3)])
        
        finishField.attributedPlaceholder = .init(string: "Finish", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.3)])
        
        [startIcon, finishIcon].forEach { icon in
            icon.contentMode = .scaleAspectFit
            icon.tintColor = .label.withAlphaComponent(0.3)
        }
        
        //Shadows
        startBtn.dropShadow()
        exitBtn.dropShadow()
        instructionsHud.setupShadow(opacity: 0.5, radius: 10, offset: .zero, color: .main3)
    }

    func setupDelegates() {
        manager.delegate = self
        manager.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        viewModel.view = self
    }
    
    func prepareFields() {
        view.addSubview(fieldsBG)
        
        fieldsBG.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 10, right: 10), size: .init(width: 0, height: 200))

        fieldsBG.stack(
            UIView(),
            fieldsBG.hstack(startIcon.withWidth(25),startField,spacing: 10, distribution: .fill).withHeight(45),
            fieldsBG.hstack(finishIcon.withWidth(25),finishField,spacing: 10, distribution: .fill).withHeight(45),
            startBtn.withHeight(45),
            UIView(),
            spacing: 10
        ).withMargins(.allSides(12))
        
        instructionsHud.hstack(
            directionLbl,
            UIView(),
            instructionsHud.stack(
                directionImage.withSize(.init(width: 25, height: 25)),
                distanceLbl,
                alignment: .center,
                distribution: .fill
            )
        ).withMargins(.allSides(12))
        
        fieldsBG.dropShadow()
        
    }
    
    func startMonitoring() {
        let route = viewModel.sharedRoute.value
        guard let route = route else {return}
        for i in 0 ..< route.steps.count {
            let step = route.steps[i]
            let region = CLCircularRegion(center: step.polyline.coordinate , radius: 20, identifier: "\(i)")
            self.manager.startMonitoring(for: region)
        }
    }
    
    func prepareStepData() {
        viewModel.currentStep.subscribe { [weak self] result in
            self?.setStepData(stepNumber: result.element ?? 0)
        }.disposed(by: disposeBag)
    }

    func setStepData(stepNumber: Int) {
        let currentStep = steps[stepNumber]
        directionLbl.text = currentStep.instructions
        distanceLbl.text = String(format: "%.0f m", currentStep.distance)
        if currentStep.instructions.localizedStandardContains("right") {
            directionImage.image = .init(systemName: "arrow.turn.up.right")
        } else if currentStep.instructions.localizedStandardContains("left") {
            directionImage.image = .init(systemName: "arrow.turn.up.left")
        } else {
            directionImage.image = .init(systemName: "arrow.up")
        }
    }
    
    func showStepsHud() {
        view.addSubview(instructionsHud)
        instructionsHud.anchor(top: nil, leading: view.leadingAnchor, bottom: fieldsBG.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 10, right: 10))
    }
    
    func addTargets() {
        startField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapChangeStart)))
        finishField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapChangeFinish)))
    }
    
    func addAnnotation(title: String, item: MKMapItem) {
        let annotation = DirectionEndPoint(type: title)
        annotation.coordinate = item.placemark.coordinate
        annotation.title = title
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
        self.tripAnnotations.append(annotation)
    }
    
    func updateStartFinishAnnotations() {
        if let _ = startItem {
            if let ano = mapView.annotations.first(where: {$0.title == "Start"}) {
                mapView.removeAnnotation(ano)
                tripAnnotations.removeAll(where: {$0.title == "Start" || $0.title == "Finish"})
            }
            addAnnotation(title: "Start", item: startItem!)
        }
        if let _ = finishItem {
            if let ano = mapView.annotations.first(where: {$0.title == "Finish"}) {
                mapView.removeAnnotation(ano)
                tripAnnotations.removeAll(where: {$0.title == "Start" || $0.title == "Finish"})
            }
            addAnnotation(title: "Finish", item: finishItem!)
        }
        requestForDirections()
        mapView.showAnnotations(tripAnnotations, animated: false)
    }
    
    func requestForDirections() {
        viewModel.requestForDirections { [weak self] route in
            DispatchQueue.main.async {
                self?.tripAnnotations.removeAll(keepingCapacity: false)
                self?.mapView.removeOverlays(self?.mapView.overlays ?? [])
                self?.mapView.addOverlay(route.polyline)
            }
        }
        self.mapView.showAnnotations(tripAnnotations , animated: true)
    }
    
    func handleSharedAnnotations() {
        viewModel.posts.subscribe { [weak self] posts in
            posts.element?.forEach({ post in
                let ano = RiskColoredAnnotations(post: post)
                ano.coordinate = .init(latitude: post.location.latitude, longitude: post.location.longitude)
                DispatchQueue.main.async {
                    self?.mapView.addAnnotation(ano)
                }
            })
        }.disposed(by: disposeBag)
    }
    
    func speech(message: String) {
            let msg = message
            let speecU = AVSpeechUtterance(string: msg)
            speecU.voice = .init(language: "en-EN")
            self.speechSynthesizer.speak(speecU)
    }
    
}

//MARK: CLManagerDelegate
extension PlanATripViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loca = locations.first else {return}
        viewModel.currentLocation.accept(loca.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            print("ok")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.stepCounter += 1
        viewModel.currentStep.accept(stepCounter)
        if self.stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            self.speech(message: "In \(currentStep.distance.rounded()) meters, \(currentStep.instructions)")
            setStepData(stepNumber: stepCounter)
        } else {
            self.speech(message: "Arrived at destination")
            self.stepCounter = 0
            manager.monitoredRegions.forEach { region in
                manager.stopMonitoring(for: region)
            }
        }
    }
    
}

//MARK: MapView Delegate
extension PlanATripViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is DirectionEndPoint || annotation is RiskColoredAnnotations) {return nil}
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "id")
        if let customAnnotation = annotation as? DirectionEndPoint {
            if customAnnotation.type == "Start" {
                annotationView.image = .init(named: "StartPin")
            } else if customAnnotation.type == "Finish" {
                annotationView.image = .init(named: "FinishPin")
            }
        } else {
            annotationView.canShowCallout = true
            if let customPin = annotation as? RiskColoredAnnotations {
                if customPin.post.riskDegree == 0 {
                    annotationView.image = .init(named: "LowPin")
                }else if customPin.post.riskDegree == 1 {
                    annotationView.image = .init(named: "MedPin")
                }else if customPin.post.riskDegree == 2 {
                    annotationView.image = .init(named: "HighPin")
                }
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .systemRed
           polylineRenderer.lineWidth = 5
           return polylineRenderer
       }
}

//MARK: Objc
extension PlanATripViewController {
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {

        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            let location: CLLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let mapItem: MKMapItem = .init(placemark: .init(coordinate: coordinate))
            
            location.fetchLocationInfo { [unowned self] locationInfo, error in
                if tripAnnotations.isEmpty {
                    startField.text = locationInfo?.name
                    viewModel.startLocation.accept(mapItem.placemark.coordinate)
                    self.startItem = mapItem
                    updateStartFinishAnnotations()

                } else if tripAnnotations.count < 2 {
                    finishField.text = locationInfo?.name
                    viewModel.finishLocation.accept(mapItem.placemark.coordinate)
                    self.finishItem = mapItem
                    updateStartFinishAnnotations()

                }
            }
            requestForDirections()
            
            
            
            
        }
    }
    
    @objc func didTapExit() {
        navigationController?.popViewController(animated: true)
        viewModel.filteredPostsOnRoute = []
        viewModel.startLocation.accept(nil)
        viewModel.finishLocation.accept(nil)
    }
    
    @objc func didTapStart() {
        guard startField.text != "", finishField.text != "" else {return}
        isInstructionsAppear.toggle()
        steps = viewModel.sharedRoute.value?.steps ?? []
        
        if (viewModel.startLocation.value?.distance(to: (manager.location?.coordinate)!))! > 200 {
            mapView.setUserTrackingMode(.none, animated: true)
        } else {
            mapView.camera = .init(lookingAtCenter: viewModel.currentLocation.value!, fromDistance: .init(50), pitch: .init(45), heading: CLLocationDirection(0))
            mapView.setCameraZoomRange(.init(maxCenterCoordinateDistance: 1000), animated: true)
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        }
        
        startMonitoring()
        mapView.showAnnotations(tripAnnotations, animated: false)
        prepareStepData()
        showStepsHud()

    }
    
    @objc private func didTapChangeStart() {
        let vc = MapSearchViewController()
        vc.prepareCurrentLocationForSearch = { [weak self] in
            self?.startField.text = "Current Location"
            self?.viewModel.startLocation.accept(self?.viewModel.currentLocation.value)
            let item: MKMapItem = .init(placemark: .init(coordinate: (self?.viewModel.currentLocation.value)!))
            self?.addAnnotation(title: "Start", item: item)
        }
        vc.selectionHandler = { [unowned self] item in
            self.startField.text = item.name
            self.navigationController?.popViewController(animated: true)
            viewModel.startLocation.accept(item.placemark.coordinate)
            self.startItem = item
            updateStartFinishAnnotations()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapChangeFinish() {
        let vc = MapSearchViewController()
        vc.selectionHandler = { [unowned self] item in
            self.finishField.text = item.name
            self.navigationController?.popViewController(animated: true)
            viewModel.finishLocation.accept(item.placemark.coordinate)
            self.finishItem = item
            updateStartFinishAnnotations()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}
