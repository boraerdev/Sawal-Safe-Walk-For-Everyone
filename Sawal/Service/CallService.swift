//
//  CallService.swift
//  Sawal
//
//  Created by Bora Erdem on 19.11.2022.
//

import Foundation
import FirebaseFirestore
import UIKit
import FirebaseAuth

class CallService {
    static let shared = CallService()
    var token = ""
    
    func makeCall(for authorUid: String, completion: @escaping (Result<Bool, Error>)->()) {
        let data = ["authorUid": authorUid, "date": Date(), "isMeetStarted": false] as [String: Any]
        Firestore.firestore().collection("calls").document(authorUid).setData(data) { err in
            guard err == nil else {
                completion(.failure(err!))
                return
            }
            completion(.success(true))
        }
    }
    
    func fetchToken(channelName: String, userRole: Int, completion: @escaping (String)->()) {
        // Construct the endpoint URL
        guard let tokenServerURL = URL(string: "\(serverUrl)/rtc/\(channelName)/\(userRole)/uid/\(Int.random(in: 100...99999))/?expiry=\(3600)") else {
            fatalError()
        }
        /// Semaphore waits for the request to complete, before returning the token.
        let semaphore = DispatchSemaphore(value: 0)
        var request = URLRequest(url: tokenServerURL, timeoutInterval: 10)
        request.httpMethod = "GET"

        // Construct the GET request
        let task = URLSession.shared.dataTask(with: request) { data, response, err in
            defer {
                // Signal that the request has completed
                semaphore.signal()
            }
            guard let data = data else {
                // No data, no token
                fatalError()
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                if let returnToken = json?["rtcToken"] as? String {
                    DispatchQueue.main.async {
                        self.token = returnToken
                    }
                }
                
            } catch {
                print("errorMsg")
            }
            
        }

        task.resume()

        // Waiting for signal found inside the GET request handler
        semaphore.wait()
        completion(token)
    }
    
    func removeCall(for uid: String) {
        Firestore.firestore().collection("calls").document(uid).delete()
    }
    
    func fetchActiveCalls(completion: @escaping ([Call])->()) {
        Firestore.firestore().collection("calls").addSnapshotListener{ query, err in
            guard err == nil, let query = query else {
                return
            }
            let calls = query.documents.compactMap({doc in
                let call = try? doc.data(as: Call.self)
                if call?.authorUid != userUid ?? "" {
                    return call
                } else {
                    return nil
                }
            })
            VideoCallViewModel.shared.calls.accept(calls)
        }
    }

}
