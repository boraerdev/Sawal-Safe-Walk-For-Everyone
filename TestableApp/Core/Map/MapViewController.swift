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

//MARK: Def, UI
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
}

//MARK: Core
extension MapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMainView()
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
    }

}

//MARK: Funcs
extension MapViewController {
    
    private func prepareMainView() {
        view.backgroundColor = .systemBackground
        mapKit.showsUserLocation = true
        viewModel.view = self
        clManager.delegate = self
        mapKit.delegate = self
        handleUserLocation()
        viewModel.viewDidLoad()
        mapKit.removeAnnotations(mapKit.annotations)
    }
    
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

//MARK: CLLocation Delegate
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

//MARK: MKMapView Delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
}

extension MapViewController: MapViewControllerInterface {}
