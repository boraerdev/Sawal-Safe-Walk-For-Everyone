//
//  Post.swift
//  TestableApp
//
//  Created by Bora Erdem on 8.10.2022.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Post: Codable {
    @DocumentID var id: String?
    let authorUID: String
    let date: Date
    let description: String
    let imageURL: String?
    let location: GeoPoint
    let riskDegree: Int
}
