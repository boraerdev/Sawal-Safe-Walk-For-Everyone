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
    let currentStep: BehaviorRelay<Int> = .init(value: 0)
    static let shared = PlanATripViewModel()
}

extension PlanATripViewModel: PlanATripViewModelInterFace {
    
    func viewDidLoad() {
        fetchSharedLocations()
    }
    
    func fetchSharedLocations() {
        PostService.shared.fetchSharedLocations { [weak self] result in
            switch result{
            case .success(let resultPosts):
                self?.posts.accept(resultPosts)
            case .failure(_):
                ()
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
        let request = prepareRequest()
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (resp, err) in
            guard err == nil else {return}
            guard let route =  resp?.routes.first else {return}
            sharedRoute.accept(route)
            filterAndDetect {detectRisk(postList: $0)}
            startSpeechForRoute()
            completion(route)
        }
    }
    
}

extension PlanATripViewModel {
    
    private func prepareRequest() -> MKDirections.Request {
        let request = MKDirections.Request()
        var startingPlacemark: MKPlacemark = .init(coordinate: startLocation.value!)
        request.source = .init(placemark: startingPlacemark)
        var endingPlacemark: MKPlacemark = .init(coordinate: finishLocation.value!)
        request.destination = .init(placemark: endingPlacemark)
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        return request
    }
    
    private func startSpeechForRoute() {
        var msg = ""
        if filteredPostsOnRoute.count != 0 {
            msg = "There are \(filteredPostsOnRoute.count) risky areas on the route. When you approach here, we will inform you with an audible warning. You can start your safe journey by clicking the Go button."
        } else {
            msg = "We do not found any risk on your route. But may exist unreported risk on your route. You can start your safe journey by clicking the Go button."
        }
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            view?.speech(message: msg)
        }
    }
    
}
