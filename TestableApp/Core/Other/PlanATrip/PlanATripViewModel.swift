//
//  PlanATripViewModel.swift
//  TestableApp
//
//  Created by Bora Erdem on 11.10.2022.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

protocol PlanATripViewModelInterFace: AnyObject {
    func viewDidLoad()
    func detectRisk()
}

class PlanATripViewModel {
    weak var view: PlanATripViewControllerInterFace?
    let currentLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let startLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let finishLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    var posts: BehaviorRelay<[Post]> = .init(value: [])
    let disposeBag = DisposeBag()
    let yakinlas: BehaviorRelay<Bool> = .init(value: true)
}

extension PlanATripViewModel: PlanATripViewModelInterFace {
    func viewDidLoad() {
        fetchSharedLocations()
        bindAreaInfo()
    }
    
    func bindAreaInfo() {
        self.yakinlas.subscribe { result in
            print(result)
        }.disposed(by: disposeBag)
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
    
    func detectRisk() {
        var postCoor: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
        var distance: Double?
        currentLocation.subscribe { [weak self] result in
            self?.posts.value.forEach { post in
                postCoor = .init(latitude: post.location.latitude, longitude: post.location.longitude)
                distance = result?.distance(to: postCoor)
                if distance ?? 100 <= 21, distance ?? 100 >= 20 {
                    self?.yakinlas.accept(true)
                }
                if distance ?? 100 <= 0.5{
                   self?.yakinlas.accept(false)
               }
                if distance ?? 100 <= 20 {
                    if self?.yakinlas.value == true {
                        print("Riskli alana \(String(format: "%.1f", distance!))m kaldı.")
                    } else {
                        print("Riskli alandan \(String(format: "%.1f", distance!))m uzaklaştınız.")
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
}
