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
    
    func uploadPost(desc: String, img: UIImage, location: CLLocation, completion: @escaping (Result<Bool, Error>) -> ()) {
        ImageService.shared.downloadImageURL(image: img) { rtURL in
            let data = ["date": Date(), "description": desc, "imageURL": rtURL, "location": GeoPoint(latitude: location.coordinate.latitude.magnitude, longitude: location.coordinate.longitude.magnitude) ] as [String: Any]
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
}
