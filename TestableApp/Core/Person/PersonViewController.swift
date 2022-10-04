//
//  PersonViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 26.09.2022.
//

import UIKit
import FirebaseAuth

class PersonViewController: UIViewController {
    
    private lazy var btn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Çıkış", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        btn.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func didTapExit() {
        do {
            try Auth.auth().signOut()
            let vc = UINavigationController(rootViewController: SignInViewController())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } catch let error {
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            btn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
