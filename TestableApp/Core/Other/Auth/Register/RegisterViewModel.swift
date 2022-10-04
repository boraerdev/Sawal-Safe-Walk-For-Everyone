//
//  RegisterViewModel.swift
//  TestableApp
//
//  Created by Bora Erdem on 4.10.2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol RegisterViewModelInterface: AnyObject {
    func registerUser(fullName: String, email: String, pass: String, completion: @escaping (Result<Bool,Error>)->())
}

final class RegisterViewModel {
    weak var delegate: RegisterViewControllerInterface?
    var fullName: BehaviorRelay<String> = .init(value: "")
    var email: BehaviorRelay<String> = .init(value: "")
    var pass: BehaviorRelay<String> = .init(value: "")
    var isLoading: BehaviorRelay<Bool> = .init(value: false)
}

extension RegisterViewModel: RegisterViewModelInterface {
  
    func registerUser(fullName: String, email: String, pass: String, completion: @escaping (Result<Bool,Error>)->()) {
        isLoading.accept(true)
        AuthManager.shared.register(fullName: fullName, email: email, pass: pass) { [weak self] result in
            switch result {
            case .success(_):
                self?.isLoading.accept(false)
                completion(.success(true))
            case .failure(let failure):
                self?.isLoading.accept(false)
                completion(.failure(failure))
            }
        }
    }
}





