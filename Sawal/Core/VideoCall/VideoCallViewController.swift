//
//  CideoCallViewController.swift
//  Sawal
//
//  Created by Bora Erdem on 18.11.2022.
//

import UIKit
import LBTATools
import CoreLocation
import RxSwift
import RxCocoa
import AgoraUIKit
import AgoraRtcKit

protocol VideoCallViewControllerInterface: AnyObject {
    func didTapJoin(role: AgoraClientRole, channel: String)
    var mainContainer: UIView {get set}
    var agoraView: AgoraVideoViewer! {get set}
    var spinner: UIActivityIndicatorView {get set}
}

class VideoCallViewController: UIViewController, VideoCallViewControllerInterface {
    
    //MARK: Def
    let manager = CLLocationManager()
    var location: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let disposeBag = DisposeBag()
    let viewModel = VideoCallViewModel.shared
    
    //MARK: UI
    var mainContainer = UIView(
        backgroundColor: .systemBackground
    )
    
    var agoraView: AgoraVideoViewer!
    
    var spinner = UIActivityIndicatorView()
    
    lazy var activeCallsLbl = UILabel(
        text: "",
        font: .systemFont(ofSize: 11),
        textColor: .secondaryLabel,
        textAlignment: .center,
        numberOfLines: 0
    )
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        manager.delegate = self
        viewModel.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.stack(mainContainer).withMargins(.init(top: 10, left: 20, bottom: 10, right: 20))
        manager.startUpdatingLocation()
        updateActiveCallsLbl()
        spinner = view.setupSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillContainer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearMainContainer()
        if agoraView != nil {
            agoraView.leaveChannel()
            CallService.shared.removeCall(for: userUid ?? "")
        }
    }
    
}

//MARK: Funcs
extension VideoCallViewController {
    
    func updateActiveCallsLbl() {
        viewModel.calls.subscribe { [unowned self] calls in
            activeCallsLbl.text = "Active Calls: \(calls.element?.count ?? 0)"
        }.disposed(by: disposeBag)
    }
    
    private func fillContainer() {
        
        mainContainer.layer.cornerRadius = 8
        mainContainer.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        mainContainer.layer.borderWidth = 0.2
        
        lazy var videoImg = UIImageView(image: .init(named: "Video"), contentMode: .scaleAspectFit)

        lazy var label = UILabel(text: "A video call will begin and a call request will be sent to volunteers when you click to Video Call button. Live location and back camera view are will be shared with the volunteer. You can ask her/him whatever you want.", font: .systemFont(ofSize: 13), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 0)
        
        lazy var privacyLbl = UILabel(text: "By using our services, you’re agreeing to terms.", font: .systemFont(ofSize: 11), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 0)
        lazy var adressLabel = fetchLocationInfo()
        
        lazy var callBtn = MainButton(title: "Video Call", tintColor: .systemBackground, backgroundColor: .main3)
        callBtn.addTarget(self, action: #selector(didTapCall), for: .touchUpInside)
        
        mainContainer.stack(
            videoImg.withHeight(150),
            label,
            adressLabel,
            activeCallsLbl,
            prepareCalls(),
            UIView(),
            callBtn.withHeight(45),
            privacyLbl,
            spacing: 10)
        .withMargins(.allSides(12))
    }
    
    private func fetchLocationInfo() -> UILabel {
        lazy var adressLabel = UILabel(text: "", font: .systemFont(ofSize: 17), textColor: .label, textAlignment: .center, numberOfLines: 0)
        updateAdressLblText(for: adressLabel)
        return adressLabel
    }
    
    private func updateAdressLblText(for adressLabel: UILabel) {
        self.location.take(2).subscribe { result in
            let location = CLLocation(latitude: result?.latitude ?? 0, longitude: result?.longitude ?? 0)
            location.fetchLocationInfo { locationInfo, error in
                guard error == nil else {return}
                adressLabel.text = "\(locationInfo?.administrativeArea ?? ""), \(locationInfo?.thoroughfare ?? ""), \(locationInfo?.locality ?? ""), \(locationInfo?.postalCode ?? "")"
            }
        }.disposed(by: disposeBag)
    }
    
    private func prepareCalls() -> UIView {
        lazy var table = CallList()
        table.items = viewModel.calls.value
        table.delegate = self
        viewModel.calls.subscribe { result in
            table.items = result.element ?? []
        }.disposed(by: disposeBag)
        return table.view
    }
    
    private func clearMainContainer() {
        mainContainer.subviews.forEach { v in
            v.removeFromSuperview()
        }
    }
    
}

//MARK: CLDelegate
extension VideoCallViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        self.location.accept(location.coordinate)
    }
}

//MARK: Objc
extension VideoCallViewController {
    
    @objc func didTapCall() {
        clearMainContainer()
        viewModel.initializeAndJoinChannel(role: .broadcaster, channel: userUid ?? "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(didTapStop))
    }
    
    func didTapJoin(role: AgoraClientRole, channel: String ) {
        print("didtapjoin chabnell: \(channel)")
        clearMainContainer()
        viewModel.initializeAndJoinChannel(role: role, channel: channel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(didTapStop))
    }
    
    @objc func didTapStop() {
        agoraView.leaveChannel()
        CallService.shared.removeCall(for: userUid ?? "")
        clearMainContainer()
        navigationItem.rightBarButtonItem = nil
        fillContainer()
    }
    
}
