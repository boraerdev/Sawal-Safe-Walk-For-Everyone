//
//  File.swift
//  TestableApp
//
//  Created by Bora Erdem on 7.10.2022.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

protocol MapViewModelInterface: AnyObject {
    
}

final class MapViewModel {
    weak var view: MapViewControllerInterface?
    static let shared = MapViewModel()
    var currentCoordinate: BehaviorRelay<CLLocationCoordinate2D> = .init(value: .init(latitude: 50, longitude: 130))
}

extension MapViewModel: MapViewModelInterface {
    
}
