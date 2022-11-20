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

    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        createMainContainer()
        view.stack(mainContainer).withMargins(.init(top: 10, left: 20, bottom: 10, right: 20))
        manager.delegate = self
        viewModel.delegate = self
        manager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchCalls()
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
    
    private func createMainContainer() {
        mainContainer.layer.cornerRadius = 8
        mainContainer.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        mainContainer.layer.borderWidth = 0.2
        
    }
    
    private func fetchCalls() {
        CallService.shared.fetchActiveCalls { [unowned self]  call in
            viewModel.calls.accept(call)
        }
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
            prepareCalls().withHeight(150),
            UIView(),
            callBtn.withHeight(45),
            privacyLbl,
            spacing: 10)
        .withMargins(.allSides(12))
    }
    
    func initializeAndJoinChannel(role: AgoraClientRole, channel: String){
        
        if role == .broadcaster {
            CallService.shared.makeCall(for: userUid ?? "") { res in
            }
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: .init(handler: {_ in self.didTapStop()}))
    }
    
    func didTapJoin(role: AgoraClientRole, channel: String ) {
        mainContainer.subviews.forEach { v in
            v.removeFromSuperview()
        }
        initializeAndJoinChannel(role: role, channel: channel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: .init(handler: {_ in self.didTapStop()}))
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
