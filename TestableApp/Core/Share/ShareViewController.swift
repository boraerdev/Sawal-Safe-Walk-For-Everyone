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

final class ShareViewController: UIViewController {
    
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
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Risk"
        handleMapView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShare))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(mapview)
        
        NSLayoutConstraint.activate([
            mapview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mapview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mapview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mapview.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
}

extension ShareViewController {
    @objc func didTapShare() {
        //TODO
    }
    private func handleMapView() {
        let vc = MapViewController()
        addChild(vc)
        vc.didMove(toParent: self)
        mapview.addSubview(vc.view)
        vc.view.frame = mapview.bounds
        vc.viewModel.currentCoordinate.subscribe { [weak self] cor in
            self?.currentLocation = cor
        }
        .disposed(by: disposeBag)
    }
}
