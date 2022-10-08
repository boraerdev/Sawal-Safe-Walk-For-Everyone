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

protocol ShareViewControllerInterface: AnyObject {
    
}

final class ShareViewController: UIViewController {
    
    //MARK: Def
    private var currentLocation: BehaviorRelay<CLLocation?> = .init(value: nil)
    private let disposeBag = DisposeBag()
    private let mapViewModel = MapViewModel.shared
    private var locationInfo: CLPlacemark?
    private var textCount: BehaviorRelay<Int> = .init(value: 0)
    private var viewModel = ShareViewModel()
    var annotationImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)

    
    //MARK: UI
    private lazy var spinner: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.frame = .init(x: 0, y: 0, width: 100, height: 100)
        let bg = UIView()
        bg.backgroundColor = .secondarySystemBackground
        bg.layer.cornerRadius = 8
        bg.frame = ind.bounds
        ind.layer.insertSublayer(bg.layer, at: 0)
        ind.center = view.center
        return ind
    }()
    
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
    private lazy var countLbl: UILabel = {
       let lbl = UILabel()
        textCount.subscribe { [weak self] result in
            lbl.text = "\(result.element!)/140"
            lbl.textColor = result.element == 140 ? .red : .secondaryLabel
        }.disposed(by: disposeBag)
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
        view.addSubviews(viewStack, countLbl, spinner)
        
        viewStack.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: view.leadingAnchor, right: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, topMargin: 10, leftMargin: 20, rightMargin: 20, bottomMargin: 0, width: 0, height: 0)
        
        countLbl.makeConstraints(top: nil, left: nil, right: viewStack.trailingAnchor, bottom: imagesStack.topAnchor, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 5, width: 0, height: 0)
        
        mapview.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imagesStack.heightAnchor.constraint(equalToConstant: 100).isActive = true
        postField.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
            
    }
}

//MARK: Funcs
extension ShareViewController {
    private func prepareMainView() {
        viewModel.view = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShare))
        viewModel.isLoading.subscribe { [weak self] result in
            result ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
        }
        handleBind()
    }
    private func setupSomeUI() {
        annotationImage.subscribe { [weak self] returned in
            self?.postImage.image = returned
        }.disposed(by: disposeBag)
        let inf = "\(locationInfo?.name ?? ""), \(locationInfo?.administrativeArea ?? "")"
        headerLocation.text = inf
    }
    @objc func didTapShare() {
        throwAlert(title: "Share this report", message: "Are you sure you want to share this report?") { [weak self] in
            self?.viewModel.uploadPost { [weak self] result in
                switch result {
                case .success(_):
                    self?.throwAlert(title: "Success", message: "Successfully shared. Thank you for your support.", handler: {
                        self?.navigationController?.popViewController(animated: true)
                    })
                case .failure(_):
                    self?.throwAlert(title: "Error", message: "An error occured. Please try again later.", handler: nil)
                }
            }
        }
    }
    private func throwAlert(title: String, message: String, handler: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "OK", style: .default, handler: { action in
            if let handler = handler {
                handler()
            }
        }))
        self.present(alert, animated: true)
    }
    private func prepareStack() {
        headerStack = .init(arrangedSubviews: [headerLocation, currentDateLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalCentering
        
        imagesStack = .init(arrangedSubviews: [postImage, addImageBtn])
        imagesStack.axis = .horizontal
        imagesStack.distribution = .fillEqually
        imagesStack.spacing = 5

        viewStack = .init(arrangedSubviews: [headerStack, mapview,postField, imagesStack])
        viewStack.axis = .vertical
        viewStack.distribution = .equalSpacing
        viewStack.spacing = 5
    }
    private func fetchLocationInfo(for location: CLLocation?) {
        location?.fetchLocationInfo { [weak self] locationInfo, error in
            guard error == nil else { return }
            self?.locationInfo = locationInfo
            self?.setupSomeUI()
        }
    }
    private func handleBind() {
        postField.rx.text.orEmpty.bind(to: viewModel.description).disposed(by: disposeBag)
        annotationImage.bind(to: viewModel.postImage).disposed(by: disposeBag)
        currentLocation.bind(to: viewModel.location).disposed(by: disposeBag)
        
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        textCount.accept(newText.count)
        return newText.count < 140
    }
}

extension ShareViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        fetchLocationInfo(for: mapView.userLocation.location)
        currentLocation.accept(mapView.userLocation.location)
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
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, _ in
                }
            }
        }
    }
}

extension ShareViewController: ShareViewControllerInterface {
    
}
