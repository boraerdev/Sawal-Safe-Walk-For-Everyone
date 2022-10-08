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
    let currentLocation: BehaviorRelay<CLLocation?> = .init(value: nil)
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    
    //MARK: UI
    private lazy var fieldsBG: UIView = {
        let view = UIView()
        view.backgroundColor = .main3
        view.dropShadow()
        return view
    }()
    
    private lazy var startField = IndentedTextField(placeholder: "Start", padding: 10, cornerRadius: 8, backgroundColor: .white.withAlphaComponent(0.3))
    
    private lazy var finishField = IndentedTextField(placeholder: "Finish", padding: 10, cornerRadius: 8, backgroundColor: .white.withAlphaComponent(0.3))
    
    private lazy var startIcon = UIImageView(image: .init(systemName: "circle.circle"))
    
    private lazy var finishIcon = UIImageView(image: .init(systemName: "map"))
    
    //Stacks
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMainView()
        prepareMapView()
        prepareFields()
    }
    override func viewDidLayoutSubviews() {
        view.stack(vc.mapKit,fieldsBG)
        
        fieldsBG.withHeight(250)
        startIcon.withWidth(25)
        finishIcon.withWidth(25)
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
}

//MARK: Funcs
extension PlanATripViewController {
    private func prepareMainView() {
        vc.mapKit.delegate = self
    }
    
    private func prepareFields() {
        lazy var containerView = UIView(backgroundColor: .red)
        containerView.fillSuperviewSafeAreaLayoutGuide(padding: .init(top: 10, left: 20, bottom: 10, right: 20))

        
        fieldsBG.addSubview(containerView)
            
        
        
        [startField, finishField].forEach { field in
            field.withHeight(45)
        }
        
        [startIcon, finishIcon].forEach { icon in
            icon.contentMode = .scaleAspectFit
            icon.tintColor = .white
        }
        
        containerView.stack(
            containerView.hstack(startIcon,startField, spacing: 12),
            containerView.hstack(finishIcon,finishField, spacing: 12),
            spacing: 20,
            distribution: .equalSpacing
        )
    }
    
    private func prepareMapView() {
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    private func requestForDirections() {
        let request = MKDirections.Request()
        var startingPlacemark: MKPlacemark?
        currentLocation.subscribe { location in
            startingPlacemark = .init(coordinate: location.element!!.coordinate)
        }.disposed(by: disposeBag)
        request.source = .init(placemark: startingPlacemark!)
        
        let andAnnotationView = MKPointAnnotation()
        andAnnotationView.coordinate = .init(latitude: 41.00981375699895, longitude: 28.657054364790238)
        
        let endingPlacemark = MKPlacemark(coordinate: .init(latitude: 41.00981375699895, longitude: 28.657054364790238))
        
        request.destination = .init(placemark: endingPlacemark)
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (resp, err) in
            if let err = err {
                print("Failed to find routing info:", err)
                return
            }
            
            // success
            print("Found my directions/routing....")
            guard let route = resp?.routes.first else { return }
            print(route.expectedTravelTime / 60 / 60)

            resp?.routes.forEach({ [weak self] (route) in
                DispatchQueue.main.async {
                    self?.vc.mapKit.addOverlay(route.polyline)
                }
            })
            self.vc.mapKit.addAnnotation(andAnnotationView)
        }
    }
}

extension PlanATripViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("çalıştı")
        currentLocation.accept(userLocation.location)
        requestForDirections()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .main3
           polylineRenderer.lineWidth = 5
           return polylineRenderer
       }
}
