//
//  MapViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 26.09.2022.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa

protocol MapViewControllerInterface: AnyObject {
    
}

class MapViewController: UIViewController {
    
    //MARK: Def
    let clManager = CLLocationManager()
    let viewModel = MapViewModel.shared
    let disposeBag = DisposeBag()
    
    //MARK: UI
    lazy var mapKit : MKMapView = {
       let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }()
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        mapKit.showsUserLocation = true
        viewModel.view = self
        clManager.delegate = self
        handleUserLocation()
        viewModel.viewDidLoad()
        mapKit.removeAnnotations(mapKit.annotations)
        handleSharedAnnotations()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(mapKit)
        NSLayoutConstraint.activate([
            mapKit.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapKit.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapKit.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapKit.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchSharedLocations()
    }
}

extension MapViewController {
    private func handleUserLocation() {
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
        clManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    private func handleSharedAnnotations() {
        viewModel.posts.subscribe { [weak self] posts in
            posts.element?.forEach({ post in
                let ano = MKPointAnnotation()
                ano.coordinate = .init(latitude: post.location.latitude, longitude: post.location.longitude)
                self?.mapKit.addAnnotation(ano)
            })
            
        }.disposed(by: disposeBag)
        mapKit.showAnnotations(mapKit.annotations, animated: false)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {fatalError()}
        mapKit.setRegion(.init(center: location.coordinate, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: false)
        viewModel.currentCoordinate.accept(location.coordinate)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            clManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            clManager.startUpdatingLocation()
        default:
            print("ok")
        }
    }
}

extension MapViewController: MapViewControllerInterface {}
