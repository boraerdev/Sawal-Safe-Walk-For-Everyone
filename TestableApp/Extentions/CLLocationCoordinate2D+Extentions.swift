//
//  CLLocationCoordinate2D+Extentions.swift
//  TestableApp
//
//  Created by Bora Erdem on 9.10.2022.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {

    func distance(to coordinate: CLLocationCoordinate2D) -> Double {

        return MKMapPoint(self).distance(to: MKMapPoint(coordinate))
    }
}
