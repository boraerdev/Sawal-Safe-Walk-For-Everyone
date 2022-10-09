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
    let finishLocation: BehaviorRelay<CLLocation?> = .init(value: nil)
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()

    //MARK: UI
    private lazy var fieldsBG = UIView(backgroundColor: .main3)
    
    private lazy var startField = IndentedTextField(placeholder: "Start", padding: 10, cornerRadius: 8, backgroundColor: .white.withAlphaComponent(0.3))
    
    private lazy var finishField = IndentedTextField(placeholder: "Finish", padding: 10, cornerRadius: 8, backgroundColor: .white.withAlphaComponent(0.3))
    
    private lazy var startIcon = UIImageView(image: .init(systemName: "circle.circle"))
    
    private lazy var exitBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(.init(systemName: "xmark"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .main3
        btn.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        return btn
    }()
    
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
        view.stack(vc.view,fieldsBG)
        view.addSubview(exitBtn)
        fieldsBG.withHeight(250)
        
        exitBtn.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 20, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        
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
        exitBtn.layer.cornerRadius = exitBtn.frame.height / 2
        exitBtn.dropShadow()
        fieldsBG.applyGradient(colours: [.main3, .main3Light])
    }
    
    @objc private func didTapChangeStart() {
        let vc = MapSearchViewController()
        vc.selectionHandler = { [weak self] item in
            self?.startField.text = item.name
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapChangeFinish() {
        let vc = MapSearchViewController()
        vc.selectionHandler = { [weak self] item in
            self?.finishField.text = item.name
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
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
        let request = MKDirections.Request()
        var startingPlacemark: MKPlacemark?
        currentLocation.subscribe { location in
            startingPlacemark = .init(coordinate: location.element!!.coordinate)
        }.disposed(by: disposeBag)
        request.source = .init(placemark: startingPlacemark!)
        
        var endingPlacemark: MKPlacemark?
        finishLocation.subscribe { [unowned self] location in
            endingPlacemark = .init(coordinate: (location.element!?.coordinate ?? self.currentLocation.value?.coordinate)!)
        }.disposed(by: disposeBag)
        
        request.destination = .init(placemark: endingPlacemark!)
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
        polylineRenderer.strokeColor = .main3Light
           polylineRenderer.lineWidth = 5
           return polylineRenderer
       }
}
