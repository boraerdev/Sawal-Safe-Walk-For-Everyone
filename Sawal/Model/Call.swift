//
//  Call.swift
//  Sawal
//
//  Created by Bora Erdem on 20.11.2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Call: Codable {
    @DocumentID var id: String?
    let authorUid: String
    let date: Date
    let isMeetStarted: Bool
}
