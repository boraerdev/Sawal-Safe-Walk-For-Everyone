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
import Lottie
import LBTATools

enum RiskDegree: Int {
    case low
    case medium
    case high
}

protocol ShareViewControllerInterface: AnyObject {
}

//MARK: Def, UI
final class ShareViewController: UIViewController {
    
    //MARK: Def
    private var currentLocation: BehaviorRelay<CLLocation?> = .init(value: nil)
    private let disposeBag = DisposeBag()
    private let mapViewModel = MapViewModel.shared
    private var locationInfo: CLPlacemark?
    private var textCount: BehaviorRelay<Int> = .init(value: 0)
    private var viewModel = ShareViewModel()
    static var annotationImage: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    var annotationView: MKAnnotationView?

    
    //MARK: UI
    private lazy var mapView = MKMapView()
    
    private lazy var successAnimation: AnimationView = {
        let ani = AnimationView()
        ani.animation = .named("success")
        ani.frame = view.bounds
        let bg = UIView()
        bg.backgroundColor = .white
        bg.frame = view.frame
        ani.contentMode = .scaleAspectFit
        ani.center = view.center
        ani.clipsToBounds = false
        ani.layer.masksToBounds = false
        ani.layer.cornerRadius = 8
        ani.layer.insertSublayer(bg.layer, at: 0)
        ani.loopMode = .playOnce
        ani.isHidden = true
        return ani
    }()
    
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
    
    private lazy var mapViewContainer: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var lowBtn = UIButton(title: "Low", titleColor: .systemOrange, font: .systemFont(ofSize: 15), backgroundColor: .clear, target: self, action: #selector(didTapRiskBtn(_:)))
    
    private lazy var medBtn = UIButton(title: "Medium", titleColor: .systemRed, font: .systemFont(ofSize: 15), backgroundColor: .clear, target: self, action: #selector(didTapRiskBtn(_:)))
    
    private lazy var highBtn = UIButton(title: "High", titleColor: .main2, font: .systemFont(ofSize: 15), backgroundColor: .clear, target: self, action: #selector(didTapRiskBtn(_:)))
    
    private lazy var headerLocation = UILabel(font: .systemFont(ofSize: 11), textColor: .secondaryLabel)
    
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
    
}

//MARK: Core
extension ShareViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMainView()
        ShareViewController.annotationImage.accept(.init(named: "ist"))
        handleMapView()
        prepareStack()
        handleBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .clear
    }
}

//MARK: Funcs
extension ShareViewController {
    
    private func prepareMainView() {
        viewModel.view = self
        view.backgroundColor = .systemBackground
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShare))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didtapCancel))
        mapView.layer.cornerRadius = 8
        configureRiskButtons()
        
    }
    
    private func handleMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    private func prepareStack() {
        view.stack(view.hstack(headerLocation, currentDateLabel),
                   mapView.withHeight(250),
                   postField,
                   UIView(),
                   view.hstack( view.hstack(UILabel(text:"Risk:",font: .systemFont(ofSize:15), textColor: .secondaryLabel),lowBtn,medBtn,highBtn,
                        spacing: 5) ,UIView(), countLbl).padBottom(10),
                   view.hstack(postImage,addImageBtn, spacing: 5, distribution: .fillEqually).withHeight(100),
                   spacing: 5)
        .withMargins(.init(top: 10, left: 20, bottom: 0, right: 20))
        view.addSubviews(spinner,successAnimation)
    }

    private func setLocationName() {
        let inf = "\(locationInfo?.name ?? ""), \(locationInfo?.administrativeArea ?? "")"
        headerLocation.text = inf
    }
    
    private func configureRiskButtons() {
        [lowBtn, medBtn, highBtn].enumerated().forEach { i, btn in
            btn.contentEdgeInsets = .init(top: 4, left: 10, bottom: 4, right: 10)
            btn.layer.borderColor = UIColor.secondarySystemBackground.cgColor
            btn.layer.borderWidth = 2
            btn.layer.cornerRadius = 4
            btn.tag = RiskDegree(rawValue: i)?.rawValue ?? 0
        }
    }
    
    private func throwAlert(title: String, message: String,cancel: Bool = false, handler: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if cancel {
            alert.addAction(.init(title: "Cancel", style: .cancel))
        }
        alert.addAction(.init(title: "OK", style: .default, handler: { action in
            if let handler = handler {
                handler()
            }
        }))
        self.present(alert, animated: true)
    }
    
    private func fetchLocationInfo(for location: CLLocation?) {
        location?.fetchLocationInfo { [weak self] locationInfo, error in
            guard error == nil else { return }
            self?.locationInfo = locationInfo
            self?.setLocationName()
        }
    }
    
    private func handleBind() {
        postField.rx.text.orEmpty.bind(to: viewModel.description).disposed(by: disposeBag)
        ShareViewController.annotationImage.bind(to: viewModel.postImage)
            .disposed(by: disposeBag)
        
        currentLocation.bind(to: viewModel.location).disposed(by: disposeBag)
        
        viewModel.isLoading.subscribe { [weak self] result in
            result ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
        }.disposed(by: disposeBag)
    }
    
    private func bindMapViewImage() {
        ShareViewController.annotationImage.subscribe { [weak self] result in
            if let i = result.element {
                if i != nil {
                    self?.annotationView?.image = i
                    self?.postImage.image = i
                }
            }
        }.disposed(by: disposeBag)
    }
    
}

//MARK: MapView Delegate
extension ShareViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        fetchLocationInfo(for: mapView.userLocation.location)
        currentLocation.accept(mapView.userLocation.location)
        
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        
        annotationView?.layer.borderWidth = 4
        annotationView?.contentMode = .scaleAspectFill
        annotationView?.layer.borderColor = UIColor.white.cgColor
        annotationView?.layer.shadowColor = UIColor.black.cgColor
        annotationView?.layer.cornerRadius = 8
        annotationView?.layer.shadowRadius = 40
        annotationView?.clipsToBounds = true
        annotationView?.layer.masksToBounds = true
        
        bindMapViewImage()
        
        annotationView?.makeConstraints(top: nil, left: nil, right: nil, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: 70, height: 70)
        
        if annotation.coordinate.latitude == mapView.userLocation.coordinate.latitude {
            return annotationView
        }else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        viewModel.location.accept(userLocation.location)
        let span: MKCoordinateSpan = .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let center: CLLocationCoordinate2D = .init(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region: MKCoordinateRegion = .init(center: center, span: span)
        mapView.setRegion(region, animated: false)
    }
    
}

//MARK: Interface Delegate
extension ShareViewController: ShareViewControllerInterface {}

//MARK: Objc
extension ShareViewController {
    
    @objc private func openPHPicker() {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }
    
    @objc func didtapCancel(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapRiskBtn(_ sender: UIButton) {
        [lowBtn, medBtn, highBtn].forEach { btn in
            if btn != sender {
                btn.contentEdgeInsets = .init(top: 4, left: 10, bottom: 4, right: 10)
                btn.layer.borderColor = UIColor.secondarySystemBackground.cgColor
                btn.layer.borderWidth = 2
                btn.layer.cornerRadius = 4
            } else {
                btn.contentEdgeInsets = .init(top: 4, left: 10, bottom: 4, right: 10)
                btn.layer.borderColor = btn.titleLabel?.textColor.cgColor
                btn.layer.borderWidth = 2
                btn.layer.cornerRadius = 4
            }
            
        }
        viewModel.riskDegree.accept(sender.tag)
    }

    @objc func didTapShare() {
        guard postField.text != "Explain this situation...", postField.text.count > 20 else {
            throwAlert(title: "Ttr Again", message: "Description must be greater than 20 characters.",cancel: false)
            return
        }
        throwAlert(title: "Share this report", message: "Are you sure you want to share this report?", cancel: true) { [weak self] in
            self?.viewModel.uploadPost { [weak self] result in
                switch result {
                case .success(_):
                    self?.successAnimation.isHidden = false
                    self?.successAnimation.play { myRes in
                        if myRes {
                            self?.navigationController?.popViewController(animated: true)
                            self?.successAnimation.removeFromSuperview()
                        }
                    }
                case .failure(let error):
                    self?.throwAlert(title: "Try Again", message: error.localizedDescription,cancel: false, handler: nil)
                }
            }
        }
    }

}

//MARK: TextView Delegate
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

//MARK: PHPicker Delegate
extension ShareViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    ShareViewController.annotationImage.accept(image)
                }
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, _ in
                }
            }
        }
    }
}
