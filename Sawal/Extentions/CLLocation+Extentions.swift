//
//  CLLocation+Extentions.swift
//  TestableApp
//
//  Created by Bora Erdem on 7.10.2022.
//

import Foundation
import MapKit

extension CLLocation {
    func fetchLocationInfo(completion: @escaping (_ locationInfo: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) {
            completion($0?.first, $1)
        }
    }
}
