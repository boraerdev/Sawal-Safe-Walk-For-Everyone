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
import Kingfisher

protocol MapViewControllerInterface: AnyObject {
    
}

//MARK: Def, UI
class MapViewController: UIViewController {
    
    //MARK: Def
    let clManager = CLLocationManager()
    let viewModel = MapViewModel.shared
    let disposeBag = DisposeBag()
    var currentSelectCallout: UIView?
    
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
        handleSharedAnnotations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapKit.removeAnnotations(mapKit.annotations)
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
        addClearGesture()
    }
    
    private func addClearGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapClear))
        mapKit.addGestureRecognizer(gesture)
    }
    
    @objc func didTapClear() {
        currentSelectCallout?.removeFromSuperview()
    }
    
    private func handleUserLocation() {
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
        clManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    private func handleSharedAnnotations() {
        viewModel.posts.subscribe { [weak self] posts in
            posts.element?.forEach({ post in
                let ano = RiskColoredAnnotations(post: post)
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
        if !(annotation is RiskColoredAnnotations) {return nil}
        
        var annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "id2")
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
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        currentSelectCallout?.removeFromSuperview()
        if !(view.annotation is RiskColoredAnnotations) {return}
        //Def
        let customCallout = UIView(backgroundColor: .clear)
        let post: Post!
        let bgImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
        let titleLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .label, textAlignment: .center)
        titleLbl.backgroundColor = .systemBackground
        
        view.addSubview(customCallout)
        if let ano = view.annotation as? RiskColoredAnnotations {
            post = ano.post
            bgImage.kf.setImage(with: URL(string: post.imageURL!), placeholder: UIImage(systemName: "wifi"))
            
            let loc = CLLocation(latitude: post.location.latitude, longitude: post.location.longitude)
            loc.fetchLocationInfo { locationInfo, error in
                titleLbl.text = locationInfo?.name
            }
        }
        
        
        customCallout.layer.masksToBounds = true
        customCallout.clipsToBounds = true
        customCallout.layer.cornerRadius = 8
        customCallout.layer.borderWidth = 2
        customCallout.layer.borderColor = UIColor.black.cgColor
        customCallout.translatesAutoresizingMaskIntoConstraints = false
        customCallout.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customCallout.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -10).isActive = true
        customCallout.withWidth(100)
        customCallout.withHeight(150)
        
        
        
        customCallout.stack(
            bgImage,
            customCallout.hstack(titleLbl.withHeight(20), alignment: .center)
                .withMargins(.allSides(2))
        )
        
        
        currentSelectCallout = customCallout
    }
}

//MARK: MapViewController Interface
extension MapViewController: MapViewControllerInterface {}

//MARK: Objc
extension MapViewController {
    @objc func didTapGoDetail() {
        print("OK")
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        navigationController?.pushViewController(vc, animated: true)
    }
}
