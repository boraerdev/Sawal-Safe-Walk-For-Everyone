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
    var selectedPost: Post?
    
    //MARK: UI
    lazy var mapKit : MKMapView = {
       let mv = MKMapView()
        mv.translatesAutoresizingMaskIntoConstraints = false
        return mv
    }()
    
    var currentSelectCallout: UIView?
    
    var tempHud: UIView?
    
    var hudContainer = UIView(backgroundColor: .clear)
    
    private lazy var exitBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(.init(systemName: "xmark"), for: .normal)
        btn.tintColor = .label
        btn.layer.cornerRadius = 8
        btn.backgroundColor = .secondarySystemBackground
        btn.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return btn
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
        view.handleSafeAreaBlurs()
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
        hudContainer.anchor(top: nil, leading: mapKit.leadingAnchor, bottom: mapKit.safeAreaLayoutGuide.bottomAnchor, trailing: mapKit.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 10, right: 10))
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
    }
    
    private func handleBackBtn() {
        view.addSubviews(exitBtn)
        exitBtn.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 45, height: 45))
        exitBtn.dropShadow()
    }
    
    private func handleAnnotationImage(_ annotation: MKAnnotation, for annotationView: MKAnnotationView ) {
        annotationView.canShowCallout = true
        if let customPin = annotation as? RiskColoredAnnotations {
            switch customPin.post.riskDegree {
            case 0:
                annotationView.image = .init(named: "LowPin")
            case 1:
                annotationView.image = .init(named: "MedPin")
            case 2:
                annotationView.image = .init(named: "HighPin")
            default: break
            }
        }
    }
    
    private func setupPostInfoHud(view: MKAnnotationView) {
        
        let customCallout = UIView(backgroundColor: .clear)
        let hudView = UIView(backgroundColor: .secondarySystemBackground)
        let post: Post!
        let bgImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
        let adressLbl = UILabel(text: "", font: .systemFont(ofSize: 22), textColor: .label, numberOfLines: 1)
        let riskDEgreeLbl = UILabel(text: "", font: .systemFont(ofSize: 13), numberOfLines: 1)
        let descLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .secondaryLabel, numberOfLines: 2)
        let infoBtn = UIButton(image: .init(systemName: "info.circle.fill")!, tintColor: .label, target: self, action: #selector(didTapGoDetail))
        let shareBtn = UIButton(image: .init(systemName: "square.and.arrow.up.circle.fill")!, tintColor: .label, target: self, action: #selector(didTapShare(sender:)))
        view.addSubview(customCallout)
        
        hudView.layer.cornerRadius = 8
        hudView.dropShadow()
        
        if let ano = view.annotation as? RiskColoredAnnotations {
            
            //Set Data
            post = ano.post
            selectedPost = ano.post
            
            //Configure Items
            bgImage.kf.setImage(with: URL(string: post.imageURL!), placeholder: UIImage(systemName: "wifi"))
            
            descLbl.text = post.description

            switch post.riskDegree {
            case 0:
                riskDEgreeLbl.text = "Low Risk Area"
                riskDEgreeLbl.textColor = .systemOrange
            case 1:
                riskDEgreeLbl.text = "Medium Risk Area"
                riskDEgreeLbl.textColor = .systemRed
            case 2:
                riskDEgreeLbl.text = "High Risk Area"
                riskDEgreeLbl.textColor = .main2
            default: break
            }
            
            //Fetch Adress
            let loc = CLLocation(latitude: post.location.latitude, longitude: post.location.longitude)
            loc.fetchLocationInfo { locationInfo, error in
                adressLbl.text = locationInfo?.name
            }
        }
        
        hudContainer.addSubview(hudView)
        hudView.fillSuperview()
        
        configureCustomCallout(customCallout: customCallout, view: view)
        customCallout.stack(bgImage)
        
        hudView.stack(
            hudView.hstack(riskDEgreeLbl,UIView(), shareBtn, infoBtn, alignment: .top),
            UIView(),
            adressLbl,
            descLbl)
        .withMargins(.allSides(12))
        
        tempHud = hudView
        currentSelectCallout = customCallout
    }
    
    private func configureCustomCallout(customCallout: UIView, view: MKAnnotationView) {
        customCallout.layer.masksToBounds = true
        customCallout.clipsToBounds = true
        customCallout.layer.cornerRadius = 8
        customCallout.layer.borderWidth = 2
        customCallout.layer.borderColor = UIColor.systemBackground.cgColor
        customCallout.translatesAutoresizingMaskIntoConstraints = false
        customCallout.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customCallout.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -10).isActive = true
        customCallout.withWidth(100)
        customCallout.withHeight(150)
    }
    
}

//MARK: CLLocation Delegate
extension MapViewController: CLLocationManagerDelegate {
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
        mapKit.userTrackingMode = .followWithHeading
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is RiskColoredAnnotations) {return nil}
        var annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "id2")
        handleAnnotationImage(annotation, for: annotationView)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        hudContainer.isHidden = false
        currentSelectCallout?.removeFromSuperview()
        tempHud?.removeFromSuperview()
        if !(view.annotation is RiskColoredAnnotations) {return}
        setupPostInfoHud(view: view)
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
    
    @objc func didTapShare(sender: UIView) {
        
        let textToShare = "Look at this risk: "
        let riskImg = "Image: \((selectedPost?.imageURL)!)"
        
        if let riskUrl = URL(string: "http://maps.apple.com/?ll=\((selectedPost?.location.latitude)!),\((selectedPost?.location.longitude)!)") {
            let objectsToShare = [textToShare, riskUrl,riskImg] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter, .postToFacebook]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
}
