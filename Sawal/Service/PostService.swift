//
//  PostService.swift
//  TestableApp
//
//  Created by Bora Erdem on 8.10.2022.
//

import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

final class PostService {
    static let shared = PostService()
    
    func uploadPost(desc: String, img: UIImage, location: CLLocation,riskDegree: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        ImageService.shared.downloadImageURL(image: img) { rtURL in
            let data = ["date": Date(), "description": desc, "imageURL": rtURL, "location": GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), "riskDegree": riskDegree, "authorUID": AuthManager.shared.currentUser?.id ] as [String: Any]
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
    
    func deletePost(post: Post) {
        Firestore.firestore().collection("posts").document(post.id!).delete()
        Storage.storage().reference(forURL: post.imageURL!).delete { err in
            guard err == nil else {
                print("silinemedi")
                return
            }
        }
    }
    
    func getPostComments(of postId: String, completion: @escaping (Result<[Comment], Error>)->()) {
        Firestore.firestore().collection("posts").document(postId).collection("comments").getDocuments { snapshots, err in
            guard err == nil else {return}
            guard let docs = snapshots?.documents else {return}
            var comments: [Comment] = []
            do {
                comments = try docs.compactMap({try $0.data(as: Comment.self)})
                completion(.success(comments))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func uploadComment(for postId: String, comment: String) {
        let data = ["authorUid": Auth.auth().currentUser?.uid, "date": Date(), "comment": comment] as [String: Any]
        Firestore.firestore().collection("posts").document(postId).collection("comments").document().setData(data)
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
