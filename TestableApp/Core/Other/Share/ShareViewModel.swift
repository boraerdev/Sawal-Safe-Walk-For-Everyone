//
//  ShareViewModel.swift
//  TestableApp
//
//  Created by Bora Erdem on 8.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit
import FirebaseFirestore

protocol ShareViewModelInterFace: AnyObject {
    func uploadPost(completion: @escaping (Result<Bool, Error>)->())
}

final class ShareViewModel {
    static let shared = ShareViewModel()
    weak var view: ShareViewControllerInterface?
    let description: BehaviorRelay<String> = .init(value: "")
    let postImage: BehaviorRelay<UIImage?> = .init(value: nil)
    let location: BehaviorRelay<CLLocation?> = .init(value: nil)
    let isLoading: BehaviorRelay<Bool> = .init(value: false)
    let riskDegree: BehaviorRelay<Int> = .init(value: 0)
}


extension ShareViewModel: ShareViewModelInterFace {
    func uploadPost(completion: @escaping (Result<Bool, Error>) -> ()) {
        isLoading.accept(true)
        PostService.shared.uploadPost(desc: description.value, img: postImage.value ?? .init(), location: location.value ?? .init(), riskDegree: riskDegree.value) { [weak self] result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
            self?.isLoading.accept(false)
        }
    }
    
    
}
