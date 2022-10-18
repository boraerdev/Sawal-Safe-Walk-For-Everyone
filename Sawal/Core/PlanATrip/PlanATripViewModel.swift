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
    func detectRisk(postList: [Post])
}

enum CurrentRiskMode {
    case inAreaCloser
    case inAreaAway
    case outArea
}

final class PlanATripViewModel {
    weak var view: PlanATripViewControllerInterFace?
    let currentLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let startLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    let finishLocation: BehaviorRelay<CLLocationCoordinate2D?> = .init(value: nil)
    var posts: BehaviorRelay<[Post]> = .init(value: [])
    let disposeBag = DisposeBag()
    let riskMode: BehaviorRelay<CurrentRiskMode> = .init(value: .outArea)
    let distance: BehaviorRelay<Double?> = .init(value: nil)
    let sharedRoute: BehaviorRelay<MKRoute?> = .init(value: nil)
    var filteredPostsOnRoute: [Post] = []
}

extension PlanATripViewModel: PlanATripViewModelInterFace {
    
    
    func viewDidLoad() {
        fetchSharedLocations()
        bindAreaInfo()
    }
    
    func bindAreaInfo() {
        self.riskMode.subscribe { result in
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
    
    func filterAndDetect(completion: ([Post])->()) {
        guard let route = sharedRoute.value, sharedRoute.value != nil else {return}
        guard posts.value.count != 0 else {return}
        filteredPostsOnRoute.removeAll(keepingCapacity: false)
        route.steps.forEach { step in
            posts.value.filter{ post in
                if step.polyline.coordinate.distance(to: .init(latitude: post.location.latitude, longitude: post.location.longitude)) < 300 {
                    if filteredPostsOnRoute.first(where: {$0.location.latitude == post.location.latitude }) == nil {
                        filteredPostsOnRoute.append(post)
                    }
                }
                return true
            }
        }
        completion(filteredPostsOnRoute)
    }
    
    func detectRisk(postList: [Post]) {
        var postCoor: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
        var distance: Double?
        DispatchQueue.global(qos: .userInteractive).async {
            self.currentLocation.subscribe { [weak self] result in
                postList.forEach { post in
                    postCoor = .init(latitude: post.location.latitude, longitude: post.location.longitude)
                    guard let distance = result?.distance(to: postCoor) else {return}
                    
                    if distance <= 20 {
                        self?.distance.accept(distance)
                        if distance > 1, distance <= 20 {
                            self?.riskMode.accept(.inAreaCloser)
                        } else if distance > 0, distance <= 1 {
                            print("inArea")
                        }
                    } else if distance < 25 {
                        self?.riskMode.accept(.outArea)
                    }
                }
            }.disposed(by: self.disposeBag)
        }
    }
    
    func requestForDirections(completion: @escaping (MKRoute)->() ) {
        guard startLocation.value != nil, finishLocation.value != nil else {return}
        
        let request = MKDirections.Request()
        var startingPlacemark: MKPlacemark?
        startLocation.subscribe { result in
            startingPlacemark = .init(coordinate: result.element!!)
        }.disposed(by: disposeBag)
        
        request.source = .init(placemark: startingPlacemark!)
        
        var endingPlacemark: MKPlacemark?
        finishLocation.subscribe { result in
            endingPlacemark = .init(coordinate: result.element!!)
        }.disposed(by: disposeBag)
        
        request.destination = .init(placemark: endingPlacemark!)
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (resp, err) in
            
            if let err = err {
                print("Failed to find routing info:", err)
                return
            }
            // success
            print("Found my directions/routing....")
            guard let route =  resp?.routes.first else {return}
            sharedRoute.accept(route)
            
            filterAndDetect { post in
                detectRisk(postList: post)
            }
            completion(route)
            
            var msg = ""
            if filteredPostsOnRoute.count != 0 {
                msg = "There are \(filteredPostsOnRoute.count) risky areas on the route. When you approach here, we will inform you with an audible warning. You can start your safe journey by clicking the Go button."
            } else {
                msg = "We do not found any risk on your route. But may exist unreported risk on your route. You can start your safe journey by clicking the Go button."
            }
            DispatchQueue.global(qos: .userInteractive).async {
                view?.speech(message: msg)
            }

        }
        
    }
}
