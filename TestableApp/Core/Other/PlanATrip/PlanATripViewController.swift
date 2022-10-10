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

class PlanATripViewController: UIViewController {

    //MARK: Def
    let vc = MapViewController()
    let currentLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let startLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let finishLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    var tripAnnotations = [MKAnnotation]()
    let startAno: MKAnnotation? = nil
    let finishAno: MKAnnotation? = nil

    //MARK: UI
    
    let directionsView = UIView(backgroundColor: .white.withAlphaComponent(0.3))
    
    let directionsTimeLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .label)
    
    private lazy var fieldsBG = UIView(backgroundColor: .main3)
    
    private lazy var startField = IndentedTextField(placeholder: "Start", padding: 10, cornerRadius: 8, backgroundColor: .white.withAlphaComponent(0.3))
    
    private lazy var finishField = IndentedTextField(placeholder: "Finish", padding: 10, cornerRadius: 8, backgroundColor: .white.withAlphaComponent(0.3))
    
    private lazy var startIcon = UIImageView(image: .init(systemName: "circle.circle"))
    
    private lazy var exitBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(.init(systemName: "xmark"), for: .normal)
        btn.tintColor = .main3
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        return btn
    }()
    
    let header = UIView(backgroundColor: .systemBackground)
    
    private lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(" Go", for: .normal)
        btn.setTitleColor(.main3, for: .normal)
        btn.setImage(.init(systemName: "arrowtriangle.right"), for: .normal)
        btn.tintColor = .main3
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
        return btn
    }()
    
    private lazy var finishIcon = UIImageView(image: .init(systemName: "pin"))
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMainView()
        prepareMapView()
        prepareFields()
        addTargets()
    }
    
    override func viewDidLayoutSubviews() {
        
        view.stack(header, vc.view,fieldsBG)

        header.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor,padding: .init(top: 0, left: 0, bottom: -55, right: 0))
        
        let container = UIView(backgroundColor: .clear)
        header.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide(padding: .init(top: 0, left: 20, bottom: 10, right: 20))
        container.hstack(exitBtn.withWidth(45),directionsView, spacing: 12)
        
        fieldsBG.withHeight(250)
        setupSomeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
}

//MARK: Funcs
extension PlanATripViewController {
    
    @objc func didTapExit() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapStart() {
    }
    
    private func setupSomeUI() {
        exitBtn.layer.cornerRadius = 8
        header.applyGradient(colours: [.main3,.main3Light])
        fieldsBG.applyGradient(colours: [.main3, .main3Light])
        directionsView.layer.cornerRadius = 8
    }
    
    @objc private func didTapChangeStart() {
        let vc = MapSearchViewController()
        vc.selectionHandler = { [unowned self] item in
            self.startField.text = item.name
            self.navigationController?.popViewController(animated: true)
            let anoTitle = "Start"
            updateMap(item, title: anoTitle) { [weak self] in
                removeAno(title: anoTitle)
                self?.startLocation.accept(item.placemark.coordinate)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapChangeFinish() {
        let vc = MapSearchViewController()
        vc.selectionHandler = { [unowned self] item in
            self.finishField.text = item.name
            self.navigationController?.popViewController(animated: true)
            let anoTitle = "Finish"
            updateMap(item, title: anoTitle) { [weak self] in
                removeAno(title: anoTitle)
                self?.finishLocation.accept(item.placemark.coordinate)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func removeAno(title: String) {
        if self.vc.mapKit.annotations.count > 2 {
            let ano = self.vc.mapKit.annotations.first(where: {$0.title == title})
            if let ano = ano {
                tripAnnotations.removeAll { ano in
                    ano.title == title
                }
                self.vc.mapKit.removeAnnotation(ano)
            }
        }
    }
    
    private func updateMap(_ item: MKMapItem, title: String, updateVars: ()->()) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        updateVars()
        annotation.title = title
        
        self.vc.mapKit.addAnnotation(annotation)
        tripAnnotations.append(annotation)
        requestForDirections()
        self.vc.mapKit.showAnnotations(tripAnnotations, animated: true)
    }
    
    private func addTargets() {
        startField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapChangeStart)))
        finishField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapChangeFinish)))
    }
    
    private func prepareMainView() {
        vc.mapKit.delegate = self
    }
    
    private func prepareFields() {
        
        lazy var containerView = UIView()
        fieldsBG.addSubview(containerView)
        containerView.fillSuperviewSafeAreaLayoutGuide(padding: .init(top: 30, left: 20, bottom: 30, right: 20))
        
        [startField, finishField].forEach { field in
            field.withHeight(45)
            field.textColor = .white
        }
                
        startField.attributedPlaceholder = .init(string: "Start", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        
        finishField.attributedPlaceholder = .init(string: "Finish", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)])
        
        [startIcon, finishIcon].forEach { icon in
            icon.contentMode = .scaleAspectFit
            icon.tintColor = .white
        }
        
        containerView.stack(
            containerView.hstack(
                startIcon.withWidth(25)
                ,startField,
                spacing: 12,
                alignment: .center),
            containerView.hstack(
                finishIcon.withWidth(25)
                ,finishField,
                spacing: 12,
                alignment: .center),
            startBtn,
            spacing: 10,
            distribution: .fillEqually
        )
    }
    
    private func prepareMapView() {
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    private func requestForDirections() {
        
        guard startLocation.value != nil, finishLocation.value != nil else {return}
        
        let request = MKDirections.Request()
        var startingPlacemark: MKPlacemark?
        startLocation.subscribe { result in
            startingPlacemark = .init(coordinate: result.element!!)
        }.disposed(by: disposeBag)
        
        request.source = .init(placemark: startingPlacemark!)
        
        var endingPlacemark: MKPlacemark?
        finishLocation.subscribe { result in
            endingPlacemark = .init(coordinate: result.element!!)
        }.disposed(by: disposeBag)
        
        request.destination = .init(placemark: endingPlacemark!)
        request.requestsAlternateRoutes = false
        request.transportType = .any
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (resp, err) in
            if let err = err {
                print("Failed to find routing info:", err)
                return
            }
            
            // success
            print("Found my directions/routing....")
            guard let route = resp?.routes.first else { return }
            
            let mpak = CLLocation(latitude: 41.05285834919655, longitude: 28.695940298728843)
            route.steps.forEach { step in
                let metr = step.polyline.coordinate.distance(to: mpak.coordinate)
                if metr < 500 {
                    print("çalışıyor")
                }
                
            }
            
            resp?.routes.forEach({ [weak self] (route) in
                
                DispatchQueue.main.async {
                    self?.vc.mapKit.removeOverlays(self?.vc.mapKit.overlays ?? [])
                    self?.vc.mapKit.addOverlay(route.polyline)
                }
                self?.directionsTimeLbl.text = String(route.expectedTravelTime)
            })
        }
    }
}

extension PlanATripViewController: MKMapViewDelegate {
    
    func handleStartFinishAno() {
        guard startAno != nil, finishAno != nil else { return }
        mapView(vc.mapKit, viewFor: vc.mapKit.annotations.first(where: {$0.title == "Start"})!)
        mapView(vc.mapKit, viewFor: vc.mapKit.annotations.first(where: {$0.title == "Finish"})!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationStartFinish")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationStartFinish")
        }
        if let title = annotation.title {
            if annotation.coordinate.latitude != mapView.userLocation.coordinate.latitude{
                if title == "Start" {
                    annotationView?.image = .init(named: "StartPin")
                    return annotationView
                } else if title == "Finish" {
                    annotationView?.image = .init(named: "FinishPin")
                    return annotationView
                } else {
                    return annotationView
                }
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        currentLocation.accept(userLocation.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .systemRed
           polylineRenderer.lineWidth = 5
           return polylineRenderer
       }
}
