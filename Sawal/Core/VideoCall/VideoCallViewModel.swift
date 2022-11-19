//
//  VideoCallViewModel.swift
//  Sawal
//
//  Created by Bora Erdem on 19.11.2022.
//

import Foundation
import FirebaseAuth

protocol VideoCallViewModelInterface: AnyObject {
    func makeCall(completion: @escaping (Result<Bool, Error>)->())
}

class VideoCallViewModel {
    weak var delegate: VideoCallViewControllerInterface?
    let userUid = Auth.auth().currentUser?.uid
}

extension VideoCallViewModel: VideoCallViewModelInterface {
    
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
    
    
    
    
}
