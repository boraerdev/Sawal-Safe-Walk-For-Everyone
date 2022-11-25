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
}

class VideoCallViewController: UIViewController, VideoCallViewControllerInterface {
    
    //MARK: Def
    let manager = CLLocationManager()
    var location: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let disposeBag = DisposeBag()
    let viewModel = VideoCallViewModel.shared
    
    //MARK: UI
    let mainContainer = UIView(backgroundColor: .systemBackground)
    
    var agoraView: AgoraVideoViewer!
    
    let activeCallsLbl = UILabel(text: "", font: .systemFont(ofSize: 11), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 0)
    
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

    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        createMainContainer()
        view.stack(mainContainer).withMargins(.init(top: 10, left: 20, bottom: 10, right: 20))
        view.addSubview(spinner)
        manager.delegate = self
        viewModel.delegate = self
        manager.startUpdatingLocation()
        bindLoading()
        updateActiveCallsLbl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fillContainer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    private func bindLoading(){
        viewModel.isLoading.subscribe { [weak self] result in
            result ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
        }
        .disposed(by: disposeBag)
    }
    
    private func createMainContainer() {
        mainContainer.layer.cornerRadius = 8
        mainContainer.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        mainContainer.layer.borderWidth = 0.2
        
    }
    
    private func fillContainer() {
        
        let videoImg = UIImageView(image: .init(named: "Video"), contentMode: .scaleAspectFit)

        let label = UILabel(text: "A video call will begin and a call request will be sent to volunteers when you click to Video Call button. Live location and back camera view are will be shared with the volunteer. You can ask her/him whatever you want.", font: .systemFont(ofSize: 13), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 0)
        
        let privacyLbl = UILabel(text: "By using our services, you’re agreeing to terms.", font: .systemFont(ofSize: 11), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 0)
        let adressLabel = fetchLocationInfo()
        
        let callBtn = prepareMeetButtons()
        
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
    
    func initializeAndJoinChannel(role: AgoraClientRole, channel: String){
        
        viewModel.isLoading.accept(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            viewModel.isLoading.accept(false)
        }
        
        if role == .broadcaster {
            CallService.shared.makeCall(for: userUid ?? "") { _ in }
        }
        
        var options = AgoraSettings()
        options.tokenURL = serverUrl
        
        agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: appId
            ),
            agoraSettings: options
        )
        agoraView.fills(view: mainContainer)
        
        agoraView.join(
            channel: channel,
            as: role,
            fetchToken: true,
            uid: .init(Float16.random(in: 0...1000))
        )
    }
    
    private func prepareMeetButtons() -> UIButton {
        let callBtn = UIButton(title: "Video Call", titleColor: .systemBackground, font: .systemFont(ofSize: 17), backgroundColor: .main3, target: self, action: #selector(didTapCall))
        
        callBtn.layer.cornerRadius = 8
        callBtn.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        callBtn.layer.borderWidth = 0.2
        
        return callBtn
    }
    
    private func fetchLocationInfo() -> UILabel {
        let adressLabel = UILabel(text: "", font: .systemFont(ofSize: 17), textColor: .label, textAlignment: .center, numberOfLines: 0)
        self.location.take(2).subscribe { result in
            let location = CLLocation(latitude: result?.latitude ?? 0, longitude: result?.longitude ?? 0)
            location.fetchLocationInfo { locationInfo, error in
                guard error == nil else {return}
                adressLabel.text = "\(locationInfo?.administrativeArea ?? ""), \(locationInfo?.thoroughfare ?? ""), \(locationInfo?.locality ?? ""), \(locationInfo?.postalCode ?? "")"
            }
        }.disposed(by: disposeBag)
        return adressLabel
    }
    
    private func prepareCalls() -> UIView {
        let table = CallList()
        table.items = viewModel.calls.value
        table.delegate = self
        viewModel.calls.subscribe { result in
            table.items = result.element ?? []
        }.disposed(by: disposeBag)
        return table.view
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
        mainContainer.subviews.forEach { v in
            v.removeFromSuperview()
        }
        initializeAndJoinChannel(role: .broadcaster, channel: userUid ?? "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(didTapStop))
    }
    
    func didTapJoin(role: AgoraClientRole, channel: String ) {
        print("didtapjoin chabnell: \(channel)")
        mainContainer.subviews.forEach { v in
            v.removeFromSuperview()
        }
        initializeAndJoinChannel(role: role, channel: channel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(didTapStop))
    }
    
    @objc func didTapStop() {
        agoraView.leaveChannel()
        CallService.shared.removeCall(for: userUid ?? "")
        mainContainer.subviews.forEach { v in
            v.removeFromSuperview()
        }
        navigationItem.rightBarButtonItem = nil
        fillContainer()
    }

}
