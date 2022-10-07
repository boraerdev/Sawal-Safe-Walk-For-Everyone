//
//  QrViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 26.09.2022.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import MapKit

final class ShareViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Def
    private var currentLocation: CLLocationCoordinate2D?
    let disposeBag = DisposeBag()
    let mapViewModel = MapViewModel.shared
    
    
    //MARK: UI
    private lazy var mapview: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var annotationImage: UIImage?
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Risk"
        handleMapView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShare))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubviews(mapview)
        
        mapview.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: view.leadingAnchor, right: view.trailingAnchor, bottom: nil, topMargin: 10, leftMargin: 20, rightMargin: 20, bottomMargin: 0, width: 0, height: 200)
        
    }
}

extension ShareViewController {
    @objc func didTapShare() {
        //TODO
    }
    private func handleMapView() {
        let vc = MapViewController()
        addChild(vc)
        vc.mapKit.delegate = self
        vc.didMove(toParent: self)
        mapview.addSubview(vc.view)
        vc.view.frame = mapview.bounds
        vc.viewModel.currentCoordinate.subscribe { [weak self] cor in
            self?.currentLocation = cor
        }
        .disposed(by: disposeBag)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            }

        annotationView?.layer.borderWidth = 4
        annotationView?.contentMode = .scaleAspectFill
        annotationView?.layer.borderColor = UIColor.white.cgColor
        annotationView?.layer.shadowColor = UIColor.black.cgColor
        annotationView?.layer.cornerRadius = 8
        annotationView?.layer.shadowRadius = 40
        annotationView?.clipsToBounds = true
        annotationView?.layer.masksToBounds = true
        if let img = annotationImage {
            annotationView?.image = img
        }
        annotationView?.makeConstraints(top: nil, left: nil, right: nil, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: 70, height: 70)
        
        return annotationView
    }
    
}

