//
//  AnnotationTypes.swift
//  TestableApp
//
//  Created by Bora Erdem on 10.10.2022.
//

import Foundation
import MapKit

class RiskColoredAnnotations: MKPointAnnotation {
    var post: Post
    init(post: Post) {
        self.post = post
//        switch post.riskDegree {
//        case 0:
//            self.post = "LowPin"
//        case 1:
//            self.post = "MedPin"
//        case 2:
//            self.post = "HighPin"
//        default:
//            self.post = "LowPin"
//
//        }
    }
}

class DirectionEndPoint: MKPointAnnotation {
    var type: String
    init(type: String) {
        self.type = type
    }
}
