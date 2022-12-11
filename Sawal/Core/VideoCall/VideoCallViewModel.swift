//
//  VideoCallViewModel.swift
//  Sawal
//
//  Created by Bora Erdem on 19.11.2022.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa
import AgoraUIKit
import AgoraRtcKit

protocol VideoCallViewModelInterface: AnyObject {
    func makeCall(completion: @escaping (Result<Bool, Error>)->())
    func viewDidLoad()
}

class VideoCallViewModel {
    static let shared = VideoCallViewModel()
    weak var delegate: VideoCallViewControllerInterface?
    let userUid = Auth.auth().currentUser?.uid
    let disposeBag = DisposeBag()
    var calls: BehaviorRelay<[Call]> = .init(value: [])
    var isLoading : BehaviorRelay<Bool> = .init(value: false)
}

extension VideoCallViewModel: VideoCallViewModelInterface {
    
    func viewDidLoad() {
        bindLoading()
    }
    
    func makeCall(completion: @escaping (Result<Bool, Error>) -> ()) {
        guard userUid != nil else {return}
        CallService.shared.makeCall(for: userUid!) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    private func bindLoading(){
        isLoading.subscribe { [unowned self] result in
            result ? self.delegate?.spinner.startAnimating() : self.delegate?.spinner.stopAnimating()
        }
        .disposed(by: disposeBag)
    }
    
    func initializeAndJoinChannel(role: AgoraClientRole, channel: String){
        
        isLoading.accept(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            isLoading.accept(false)
        }
        
        if role == .broadcaster {
            CallService.shared.makeCall(for: userUid ?? "") { _ in }
        }
        
        var options = AgoraSettings()
        options.tokenURL = serverUrl
        
        delegate?.agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: appId
            ),
            agoraSettings: options
        )
        delegate?.agoraView.fills(view: delegate!.mainContainer)
        
        delegate?.agoraView.join(
            channel: channel,
            as: role,
            fetchToken: true,
            uid: .init(Float16.random(in: 0...1000))
        )
    }
    
}
