//
//  ImageService.swift
//  TestableApp
//
//  Created by Bora Erdem on 8.10.2022.
//

import UIKit
import FirebaseStorage

class ImageService {
    
    static let shared = ImageService()
    
    func downloadImageURL(image : UIImage, completion: @escaping (String)-> Void ) {
        let uuid = UUID().uuidString
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {fatalError()}
        var ref = Storage.storage().reference(withPath: "/image/\(uuid)")
        ref.putData(imageData) { _, error in
            guard error == nil else {fatalError()}
            ref.downloadURL { url, error in
                guard let url = url else {fatalError()}
                var urlString = url.absoluteString
                completion(urlString)
            }
        }
    }
}
