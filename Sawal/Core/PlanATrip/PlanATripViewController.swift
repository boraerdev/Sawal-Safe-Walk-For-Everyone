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
    static let viewModel = PlanATripViewModel()
    var startItem: MKMapItem? = nil
    var finishItem: MKMapItem? = nil
    let speechSynthesizer = AVSpeechSynthesizer()
    var stepCounter = 0
    var steps: [MKRoute.Step] = []

    //MARK: UI
        
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
    
    
    let header = UIView(backgroundColor: .systemBackground)
    
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
        prepareMainView()
        addTargets()
        configureSomeUI()
        prepareRiskView()
    }
    
    override func viewDidLayoutSubviews() {
        view.stack(mapView)
        let container = UIView()
        view.addSubview(container)
        prepareFields()
        container.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: .none, trailing: view.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        container.withHeight(45)
        exitBtn.withSize(.init(width: 45, height: 45))
        container.hstack(exitBtn,UIView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PlanATripViewController.viewModel.fetchSharedLocations()
        handleSharedAnnotations()
        navigationController?.navigationBar.isHidden = true
        PlanATripViewController.viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        mapView.removeAnnotations(mapView.annotations)
    }
}

//MARK: Funcs
extension PlanATripViewController {
    
    private func prepareRiskView() {
        PlanATripViewController.viewModel.riskMode.subscribe { [weak self] result in
            if result.element == .inAreaCloser || result.element == .inAreaAway {
                self?.AddRiskView()
                self?.isNowPlaying = true
            } else {
                self?.RemoveRiskView()
                self?.isNowPlaying = false
            }
        }.disposed(by: disposeBag)
    }
    
    private func AddRiskView() {
        guard !isNowPlaying else {return}
        let vc = RiskView()
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        curRiskView = vc
    }
    
    private func RemoveRiskView() {
        guard isNowPlaying else {return}
        curRiskView?.navigationController?.popViewController(animated: true)
    }
    
    private func configureSomeUI() {
        exitBtn.layer.cornerRadius = 8
        exitBtn.dropShadow()
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
                
        startField.attributedPlaceholder = .init(string: "Start", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.3)])
        
        finishField.attributedPlaceholder = .init(string: "Finish", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.3)])
        
        [startIcon, finishIcon].forEach { icon in
            icon.contentMode = .scaleAspectFit
            icon.tintColor = .label.withAlphaComponent(0.3)
        }
        
        startBtn.dropShadow()
    }

    private func prepareMainView() {
        manager.delegate = self
        manager.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        PlanATripViewController.viewModel.view = self
    }
    
    private func prepareFields() {
        view.addSubview(fieldsBG)
        fieldsBG.anchor(top: .none, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        fieldsBG.withHeight(200)
        fieldsBG.hstack(fieldsBG.stack(
            UIView(),
            fieldsBG.hstack(startIcon.withWidth(25),startField,spacing: 10, distribution: .fill).withHeight(45),
            fieldsBG.hstack(finishIcon.withWidth(25),finishField,spacing: 10, distribution: .fill).withHeight(45),
            startBtn.withHeight(45),
            UIView(),
            spacing: 10
        ), alignment: .center).withMargins(.allSides(12))
        fieldsBG.dropShadow()
    }
    
    private func startMonitoring() {
        let route = PlanATripViewController.viewModel.sharedRoute.value
        guard let route = route else {return}
        for i in 0 ..< route.steps.count {
            let step = route.steps[i]
            let region = CLCircularRegion(center: step.polyline.coordinate , radius: 20, identifier: "\(i)")
            self.manager.startMonitoring(for: region)
        }
        
    }
    
    private func addTargets() {
        startField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapChangeStart)))
        finishField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapChangeFinish)))
    }
    
    private func setupSomeUI() {
        exitBtn.layer.cornerRadius = 8
        header.applyGradient(colours: [.main3,.main3Light])
        fieldsBG.applyGradient(colours: [.main3, .main3Light])
    }
    
    private func addAnnotation(title: String, item: MKMapItem) {
        let annotation = DirectionEndPoint(type: title)
        annotation.coordinate = item.placemark.coordinate
        annotation.title = title
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
        self.tripAnnotations.append(annotation)
    }
    
    private func updateStartFinishAnnotations() {
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
    
    private func requestForDirections() {
        PlanATripViewController.viewModel.requestForDirections { [weak self] route in
            DispatchQueue.main.async {
                self?.tripAnnotations.removeAll(keepingCapacity: false)
                self?.mapView.removeOverlays(self?.mapView.overlays ?? [])
                self?.mapView.addOverlay(route.polyline)
            }
        }
        self.mapView.showAnnotations(tripAnnotations , animated: true)
    }
    
    private func handleSharedAnnotations() {
        PlanATripViewController.viewModel.posts.subscribe { [weak self] posts in
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
        if self.stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            self.speech(message: "In \(currentStep.distance.rounded()) meters, \(currentStep.instructions)")
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
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        PlanATripViewController.viewModel.currentLocation.accept(userLocation.coordinate)
        mapView.userTrackingMode = .followWithHeading
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
    
    @objc func didTapExit() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapStart() {
        guard startField.text != "", finishField.text != "" else {return}
        steps = PlanATripViewController.viewModel.sharedRoute.value?.steps ?? []
        startMonitoring()
        mapView.camera = .init(lookingAtCenter: PlanATripViewController.viewModel.currentLocation.value!, fromDistance: .init(50), pitch: .init(45), heading: CLLocationDirection(0))
        mapView.setCameraZoomRange(.init(maxCenterCoordinateDistance: 1000), animated: true)
    }

    @objc private func didTapChangeStart() {
        let vc = MapSearchViewController()
        vc.prepareCurrentLocationForSearch = { [weak self] in
            self?.startField.text = "Current Location"
            PlanATripViewController.viewModel.startLocation.accept(PlanATripViewController.viewModel.currentLocation.value)
            let item: MKMapItem = .init(placemark: .init(coordinate: PlanATripViewController.viewModel.currentLocation.value!))
            self?.addAnnotation(title: "Start", item: item)
            
        }
        vc.selectionHandler = { [unowned self] item in
            self.startField.text = item.name
            self.navigationController?.popViewController(animated: true)
            PlanATripViewController.viewModel.startLocation.accept(item.placemark.coordinate)
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
            PlanATripViewController.viewModel.finishLocation.accept(item.placemark.coordinate)
            self.finishItem = item
            updateStartFinishAnnotations()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}
