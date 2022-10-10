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
    }
}

class DirectionEndPoint: MKPointAnnotation {
    var type: String
    init(type: String) {
        self.type = type
    }
}
