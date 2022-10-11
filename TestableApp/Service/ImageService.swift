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
        let ref = Storage.storage().reference(withPath: "/image/\(uuid)")
        ref.putData(imageData) { _, error in
            guard error == nil else {
                print("image has not translated")
                return
            }
            ref.downloadURL { url, error in
                guard let url = url else {
                    print("image has not downloaded")
                    return
                }
                let urlString = url.absoluteString
                completion(urlString)
            }
        }
    }
}
