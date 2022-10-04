//
//  AuthManager.swift
//  TestableApp
//
//  Created by Bora Erdem on 4.10.2022.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthManager {
    
    static let shared = AuthManager()
    var userSession: FirebaseAuth.User?
    var currentUser: User?
    
    init() {}
    
    public func fetchUser(completion: @escaping (User)->()){
            guard let user = userSession else { return }
            UserService.shared.getUser(uid: user.uid) { [weak self] returned in
                self?.currentUser = returned
                completion(returned)
            }
        }
    
    public func signIn(email: String, pass: String, completion: @escaping (Result<User, Error>) -> ()) {
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] result, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            self?.userSession = result.user
            self?.fetchUser(completion: { _ in })
            self?.fetchUser(completion: { result in
                completion(.success(result))
            })
        }
    }
    
    public func register(fullName: String, email: String, pass: String, completion: @escaping (Result<User, Error>) -> ()) {
        let data = ["mail": email, "fullName": fullName] as [String: Any]
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] result, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            self?.userSession = result.user
            Firestore.firestore().collection("users").document(result.user.uid).setData(data)
            self?.fetchUser(completion: { user in
                completion(.success(user))
            })
        }
    }
}


