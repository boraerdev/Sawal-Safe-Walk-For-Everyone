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
    var tempHud: UIView?
    
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
        addClearGesture()
        handleMapKit()
        handleBackBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        handleSharedAnnotations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapKit.removeAnnotations(mapKit.annotations)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
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
    
    private func addClearGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapClear))
        mapKit.addGestureRecognizer(gesture)
        
    }
    
    private func handleUserLocation() {
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
        clManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    private func handleMapKit() {
        view.addSubview(mapKit)
        mapKit.fillSuperview()
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
    
    func handleBackBtn() {
        let btn = UIButton(image: .init(systemName: "xmark")!, tintColor: .main3, target: self, action: #selector(didTapBack))
        btn.backgroundColor = .systemBackground
        btn.clipsToBounds = false
        btn.layer.cornerRadius = 8
        btn.dropShadow()
        view.addSubview(btn)
        btn.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 20, bottom: 0, right: 0), size: .init(width: 45, height: 45))
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
        tempHud?.removeFromSuperview()
        if !(view.annotation is RiskColoredAnnotations) {return}
        
        //Def
        let customCallout = UIView(backgroundColor: .clear)
        let hudView = UIView(backgroundColor: .systemBackground)
        let post: Post!
        let bgImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
        let titleLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .label, textAlignment: .center)
        
        
        view.addSubview(customCallout)
        self.mapKit.addSubview(hudView)
        
        hudView.layer.cornerRadius = 8
        hudView.dropShadow()
        titleLbl.backgroundColor = .systemBackground

        if let ano = view.annotation as? RiskColoredAnnotations {
            post = ano.post
            bgImage.kf.setImage(with: URL(string: post.imageURL!), placeholder: UIImage(systemName: "wifi"))
            
            let loc = CLLocation(latitude: post.location.latitude, longitude: post.location.longitude)
            loc.fetchLocationInfo { locationInfo, error in
                titleLbl.text = locationInfo?.name
            }
        }
        
        
        hudView.anchor(top: nil, leading: mapKit.leadingAnchor, bottom: mapKit.safeAreaLayoutGuide.bottomAnchor, trailing: mapKit.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        hudView.withHeight(150)
        
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
            customCallout.hstack(titleLbl.withHeight(20), alignment: .center).withMargins(.allSides(2))
        )
        hudView.stack(titleLbl, alignment: .center).withMargins(.allSides(12))

        
        tempHud = hudView
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
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapClear() {
        currentSelectCallout?.removeFromSuperview()
        tempHud?.removeFromSuperview()
    }
}
