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
    func viewDidLoad()
    func fetchSharedLocations()
}

final class MapViewModel {
    weak var view: MapViewControllerInterface?
    static let shared = MapViewModel()
    var posts: BehaviorRelay<[Post]> = .init(value: [])
    var currentCoordinate: BehaviorRelay<CLLocationCoordinate2D> = .init(value: .init(latitude: 50, longitude: 130))
}

extension MapViewModel: MapViewModelInterface {
    func viewDidLoad() {
        fetchSharedLocations()
    }
    
    func fetchSharedLocations() {
        PostService.shared.fetchSharedLocations { [weak self] result in
            switch result{
            case .success(let resultPosts):
                self?.posts.accept(resultPosts)
            case .failure(_):
                print("")
            }
        }
    }
    
}
