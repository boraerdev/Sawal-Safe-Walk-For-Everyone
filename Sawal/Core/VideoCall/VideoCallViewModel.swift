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

protocol VideoCallViewModelInterface: AnyObject {
    func makeCall(completion: @escaping (Result<Bool, Error>)->())
}

class VideoCallViewModel {
    static let shared = VideoCallViewModel()
    weak var delegate: VideoCallViewControllerInterface?
    let userUid = Auth.auth().currentUser?.uid
    var calls: BehaviorRelay<[Call]> = .init(value: [])
    var isLoading : BehaviorRelay<Bool> = .init(value: false)
}

extension VideoCallViewModel: VideoCallViewModelInterface {
    
    func makeCall(completion: @escaping (Result<Bool, Error>) -> ()) {
        guard userUid != nil else {return}
        CallService.shared.makeCall(for: userUid!) { [unowned self] result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    
    
    
}
