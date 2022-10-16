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
final class MapViewController: UIViewController {
    
    //MARK: Def
    let clManager = CLLocationManager()
    let viewModel = MapViewModel.shared
    let disposeBag = DisposeBag()
    var currentSelectCallout: UIView?
    var tempHud: UIView?
    var hudContainer = UIView(backgroundColor: .clear)
    var selectedPost: Post?
    
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
        navigationController?.navigationBar.isHidden = true
        viewModel.fetchSharedLocations()
        handleSharedAnnotations()
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapKit.removeAnnotations(mapKit.annotations)
        navigationController?.navigationBar.isHidden = false
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
        hudContainer.layer.cornerRadius = 8
        hudContainer.isHidden = true
    }
    
    private func addClearGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapClear))
        mapKit.addGestureRecognizer(gesture)
        hudContainer.isHidden = true
    }
    
    private func handleUserLocation() {
        clManager.requestWhenInUseAuthorization()
        clManager.startUpdatingLocation()
        clManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func handleMapKit() {
        view.addSubview(mapKit)
        mapKit.fillSuperview()
        view.addSubview(hudContainer)
        
        hudContainer.anchor(top: nil, leading: mapKit.leadingAnchor, bottom: mapKit.safeAreaLayoutGuide.bottomAnchor, trailing: mapKit.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        hudContainer.withHeight(150)
    }
    
    private func handleSharedAnnotations() {
        viewModel.posts.subscribe { [weak self] posts in
            posts.element?.forEach({ post in
                let ano = RiskColoredAnnotations(post: post)
                ano.coordinate = .init(latitude: post.location.latitude, longitude: post.location.longitude)
                DispatchQueue.main.async {
                    self?.mapKit.addAnnotation(ano)
                }
            })
        }.disposed(by: disposeBag)
        print(mapKit.annotations.count)
        //mapKit.showAnnotations(mapKit.annotations, animated: false)
    }
    
    private func handleBackBtn() {
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
        guard let loca = locations.first else {
            print("location has not received")
            return
        }
        let span: MKCoordinateSpan = .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let center: CLLocationCoordinate2D = .init(latitude: loca.coordinate.latitude, longitude: loca.coordinate.longitude)
        let region: MKCoordinateRegion = .init(center: center, span: span)
        self.mapKit.setRegion(region, animated: false)
        mapKit.userTrackingMode = .follow
        manager.stopUpdatingLocation()
        
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
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        viewModel.currentCoordinate.accept(userLocation.coordinate)
    }
    
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
        hudContainer.isHidden = false
        currentSelectCallout?.removeFromSuperview()
        tempHud?.removeFromSuperview()
        if !(view.annotation is RiskColoredAnnotations) {return}
        
        //Def
        let customCallout = UIView(backgroundColor: .clear)
        let hudView = UIView(backgroundColor: .systemBackground)
        let post: Post!
        let bgImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
        let adressLbl = UILabel(text: "", font: .systemFont(ofSize: 22), textColor: .label, numberOfLines: 1)
        let riskDEgreeLbl = UILabel(text: "", font: .systemFont(ofSize: 13), numberOfLines: 1)
        let descLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .secondaryLabel, numberOfLines: 2)
        let infoBtn = UIButton(image: .init(systemName: "info.circle.fill")!, tintColor: .label, target: self, action: #selector(didTapGoDetail))
        
        
        view.addSubview(customCallout)
        self.mapKit.addSubview(hudView)
        
        hudView.layer.cornerRadius = 8
        hudView.dropShadow()
        adressLbl.backgroundColor = .systemBackground

        if let ano = view.annotation as? RiskColoredAnnotations {
            post = ano.post
            selectedPost = ano.post
            bgImage.kf.setImage(with: URL(string: post.imageURL!), placeholder: UIImage(systemName: "wifi"))
            riskDEgreeLbl.text = post.riskDegree == 0 ? "Low Risk Area" : post.riskDegree == 1 ? "Medium Risk Area" : "High Risk Area"
            riskDEgreeLbl.textColor = post.riskDegree == 0 ? .systemOrange : post.riskDegree == 1 ? .systemRed : .main2
            descLbl.text = post.description
            let loc = CLLocation(latitude: post.location.latitude, longitude: post.location.longitude)
            loc.fetchLocationInfo { locationInfo, error in
                adressLbl.text = locationInfo?.name
                
            }
        }
        
        hudContainer.addSubview(hudView)
        hudView.fillSuperview()
        
        configureCustomCallout(customCallout: customCallout, view: view)
        
        customCallout.stack(bgImage)
        //hudView.stack(adressLbl, alignment: .center).withMargins(.allSides(12))
        hudView.hstack(hudView.stack(hudView.hstack(riskDEgreeLbl, infoBtn, alignment: .top),
                                     UIView(),
                                     adressLbl,
                                     descLbl))
        .withMargins(.allSides(12))
        
        
        tempHud = hudView
        currentSelectCallout = customCallout
    }
    
    private func configureCustomCallout(customCallout: UIView, view: MKAnnotationView) {
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
    }
    
}

//MARK: MapViewController Interface
extension MapViewController: MapViewControllerInterface {}

//MARK: Objc
extension MapViewController {
    @objc func didTapGoDetail() {
        let vc = RiskDetailViewController()
        vc.post = selectedPost
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapClear() {
        currentSelectCallout?.removeFromSuperview()
        tempHud?.removeFromSuperview()
        hudContainer.isHidden = true
    }
}
