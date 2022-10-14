//
//  User.swift
//  TestableApp
//
//  Created by Bora Erdem on 14.10.2022.
//
import Foundation
import FirebaseFirestoreSwift


struct User: Codable {
    @DocumentID var id: String?
    var fullName :String
    var mail: String
}
