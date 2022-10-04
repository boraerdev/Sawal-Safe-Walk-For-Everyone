//
//  UserService.swift
//  TestableApp
//
//  Created by Bora Erdem on 4.10.2022.
//

import Foundation
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    func getUser(uid: String, completion: @escaping (User)-> Void)  {
            Firestore.firestore().collection("users").document(uid)
                .getDocument { snapshot, error in
                    guard error == nil else {fatalError()}
                    guard let snapshot = snapshot else {return}
                    guard let user = try? snapshot.data(as: User.self) else {fatalError()}
                    completion(user)
                }
        }
}
