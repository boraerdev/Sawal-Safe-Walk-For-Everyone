//
//  PostService.swift
//  TestableApp
//
//  Created by Bora Erdem on 8.10.2022.
//

import UIKit
import CoreLocation
import FirebaseFirestore

final class PostService {
    static let shared = PostService()
    
    func uploadPost(desc: String, img: UIImage, location: CLLocation,riskDegree: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        ImageService.shared.downloadImageURL(image: img) { rtURL in
            let data = ["date": Date(), "description": desc, "imageURL": rtURL, "location": GeoPoint(latitude: location.coordinate.latitude.magnitude, longitude: location.coordinate.longitude.magnitude), "riskDegree": riskDegree, "authorUID": AuthManager.shared.currentUser?.id ] as [String: Any]
            let id = UUID().uuidString
            Firestore.firestore().collection("posts").document(id).setData(data) { err in
                guard err == nil else {
                    completion(.failure(err!))
                    return
                }
                completion(.success(true))
            }
        }
    }
    
    func fetchSharedLocations(completion: @escaping (Result<[Post], Error>)->()) {
        Firestore.firestore().collection("posts").getDocuments { query, err in
            guard err == nil else {
                completion(.failure(err!))
                return
            }
            guard let docs = query?.documents else {
                completion(.failure(err!))
                return
            }
            var posts: [Post] = []
            do {
                posts = try docs.compactMap { try $0.data(as: Post.self) }
                completion(.success(posts))
            }catch let err{
                completion(.failure(err))
            }
        }
    }
}
