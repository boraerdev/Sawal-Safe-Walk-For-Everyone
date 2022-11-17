//
//  SignInViewModel.swift
//  TestableApp
//
//  Created by Bora Erdem on 4.10.2022.
//

import Foundation
import RxSwift
import RxCocoa


protocol SignInViewModelInterface: AnyObject {
    func signInUser(email: String, pass: String, completion: @escaping (Result<Bool, Error>)->())
}

final class SignInViewModel {
    weak var delegate: SignInViewControllerInterface?
    var email: BehaviorRelay<String> = .init(value: "")
    var pass: BehaviorRelay<String> = .init(value: "")
    var isLoading: BehaviorRelay<Bool> = .init(value: false)
}

extension SignInViewModel: SignInViewModelInterface {
    func signInUser(email: String, pass: String, completion: @escaping (Result<Bool, Error>)->()) {
        isLoading.accept(true)
        AuthManager.shared.signIn(email: email, pass: pass) { [weak self] result in
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
    
    func resetPassword(email: String, completion: @escaping (Result<Bool, Error>)->()) {
        AuthManager.shared.resetPassword(email: email) { result in
            switch result {
                
            case .success(_):
                completion(.success(true))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
}

