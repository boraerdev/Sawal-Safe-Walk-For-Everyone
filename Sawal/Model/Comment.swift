//
//  Comment.swift
//  Sawal
//
//  Created by Bora Erdem on 16.10.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Comment: Codable {
    @DocumentID var id: String?
    let comment: String
    let authorUid: String
    let date: Date
}
