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
import PhotosUI

final class ShareViewController: UIViewController {
    
    //MARK: Def
    private var currentLocation: CLLocation?
    private let disposeBag = DisposeBag()
    private let mapViewModel = MapViewModel.shared
    private var locationInfo: CLPlacemark?
    
    //MARK: UI
    private lazy var mapview: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var headerLocation: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    private lazy var currentDateLabel: UILabel = {
        let date = Date()
        let lbl = UILabel()
        lbl.textColor = .secondaryLabel
        lbl.font = .systemFont(ofSize: 11)
        lbl.text = date.formatted(date: .long, time: .shortened)
        return lbl
    }()
    private lazy var postImage: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 8
        img.contentMode = .scaleAspectFill
        img.layer.masksToBounds = true
        img.clipsToBounds = true
        return img
    }()
    private lazy var addImageBtn: UIButton = {
        let btn = UIButton()
        let conf = UIImage.SymbolConfiguration(pointSize: 32)
        btn.setImage(.init(systemName: "plus.square.fill.on.square.fill", withConfiguration: conf), for: .normal)
        btn.backgroundColor = .secondarySystemBackground
        btn.addTarget(self, action: #selector(openPHPicker), for: .touchUpInside)
        btn.layer.cornerRadius = 8
        btn.tintColor = .secondaryLabel
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private lazy var postField: UITextView = {
       let field = UITextView()
        field.delegate = self
        field.textAlignment = .justified
        field.text = "Explain this situation..."
        field.font = .systemFont(ofSize: 17)
        field.textColor = UIColor.lightGray
        return field
    }()
    var annotationImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    
    //Stacks
    private var viewStack: UIStackView!
    private var headerStack: UIStackView!
    private var imagesStack: UIStackView!

    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMainView()
        annotationImage.accept(.init(named: "ist"))
        handleMapView()
        prepareStack()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(viewStack)
        
        viewStack.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: view.leadingAnchor, right: view.trailingAnchor, bottom: nil, topMargin: 10, leftMargin: 20, rightMargin: 20, bottomMargin: 0, width: 0, height: 0)
        
        mapview.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imagesStack.heightAnchor.constraint(equalToConstant: 100).isActive = true
        postField.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
            
    }
}

//MARK: Funcs
extension ShareViewController {
    private func prepareMainView() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShare))

    }
    private func setupSomeUI() {
        annotationImage.subscribe { [weak self] returned in
            self?.postImage.image = returned
        }.disposed(by: disposeBag)
        let inf = "\(locationInfo?.name ?? ""), \(locationInfo?.administrativeArea ?? "")"
        headerLocation.text = inf
    }
    @objc func didTapShare() {
        //TODO
    }
    private func prepareStack() {
        headerStack = .init(arrangedSubviews: [headerLocation, currentDateLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalCentering
        
        imagesStack = .init(arrangedSubviews: [postImage, addImageBtn])
        imagesStack.axis = .horizontal
        imagesStack.distribution = .fillEqually
        imagesStack.spacing = 5

        viewStack = .init(arrangedSubviews: [headerStack, mapview, imagesStack, postField])
        viewStack.axis = .vertical
        viewStack.spacing = 5
    }
    private func fetchLocationInfo(for location: CLLocation?) {
        location?.fetchLocationInfo { [weak self] locationInfo, error in
            guard error == nil else { return }
            self?.locationInfo = locationInfo
            self?.setupSomeUI()
        }
    }
    private func handleMapView() {
        let vc = MapViewController()
        addChild(vc)
        vc.mapKit.delegate = self
        vc.didMove(toParent: self)
        mapview.addSubview(vc.view)
        vc.view.frame = mapview.bounds
    }
    @objc private func openPHPicker() {
           var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
           phPickerConfig.selectionLimit = 1
           phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
           let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
           phPickerVC.delegate = self
           present(phPickerVC, animated: true)
       }
}

extension ShareViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
               textView.text = nil
               textView.textColor = UIColor.black
           }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Explain this situation..."
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ShareViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        fetchLocationInfo(for: mapView.userLocation.location)
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
        annotationImage.subscribe { returned in
            annotationView?.image = returned
        }.disposed(by: disposeBag)
        annotationView?.makeConstraints(top: nil, left: nil, right: nil, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: 70, height: 70)
        return annotationView
    }

}

extension ShareViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.annotationImage.accept(image)
                }
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] url, _ in
                    // TODO: - Here You Get The URL
                }
            }
        }
    }
}
