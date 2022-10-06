//
//  PersonViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 26.09.2022.
//

import UIKit
import FirebaseAuth

class PersonViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = AuthManager.shared.currentUser?.fullName
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(systemName: "rectangle.portrait.and.arrow.right"), style: .done, target: self, action: #selector(didTapExit))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "gear"), style: .plain, target: self, action: #selector(didTapSettings))
        tabBarItem.title = "Person"
    }
    
    
}

extension PersonViewController {
    @objc func didTapExit() {
        do {
            try Auth.auth().signOut()
            let vc = UINavigationController(rootViewController: SignInViewController())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } catch let error {
        }
    }
    @objc func didTapSettings() {
        
    }
}
