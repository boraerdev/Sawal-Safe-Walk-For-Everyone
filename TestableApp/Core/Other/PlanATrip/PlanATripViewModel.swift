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
        print(filteredPostsOnRoute.count)
    }
    
    func detectRisk(postList: [Post]) {
        var postCoor: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
        var distance: Double?
        currentLocation.subscribe { [weak self] result in
            postList.forEach { post in
                postCoor = .init(latitude: post.location.latitude, longitude: post.location.longitude)
                distance = result?.distance(to: postCoor)
                if distance ?? 100 <= 21, distance ?? 100 >= 19 {
                    if self?.riskMode.value == .outArea {
                       self?.riskMode.accept(.inAreaCloser)
                    } else if self?.riskMode.value == .inAreaAway {
                        self?.riskMode.accept(.outArea)
                    } else if self?.riskMode.value == .inAreaCloser {
                        self?.riskMode.accept(.outArea)
                        
                    }
                    else if self?.riskMode.value == nil {
                        self?.riskMode.accept(.inAreaCloser)
                    }
                }
                
                if distance ?? 100 <= 0.5{
                   self?.riskMode.accept(.inAreaAway)
                }
                
                if distance ?? 100 <= 20 {
                    self?.distance.accept(distance)
                    if self?.riskMode.value == .inAreaCloser {
                        print("Riskli alana \(String(format: "%.1f", distance!))m kaldı.")
                    } else if self?.riskMode.value == .inAreaAway {
                        print("Riskli alandan \(String(format: "%.1f", distance!))m uzaklaştınız.")
                    }
                }
            }
        }.disposed(by: disposeBag)
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
            var newList = resp?.routes.sorted(by: {$0.distance<$1.distance})
            guard let route =  newList?.first else {return}
            sharedRoute.accept(route)
            filterAndDetect { post in
                detectRisk(postList: post)
            }
            completion(route)
            
            
            
        }
    }
}
