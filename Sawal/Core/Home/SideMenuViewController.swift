//
//  SideMenuViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 14.10.2022.
//

import UIKit
import FirebaseAuth
//TODO
final class SideMenuViewController: UIViewController {
    
    let exitBtn = UIButton(title: " Log Out", titleColor: .systemRed, backgroundColor: .systemBackground, target: self, action: #selector(didTapExit))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main3
        prepareExitBtn()
        view.stack(UIView(), exitBtn.withHeight(45)).withMargins(.allSides(20))
    }

}

extension SideMenuViewController {
    func prepareExitBtn() {
        exitBtn.tintColor = .systemRed
        exitBtn.setImage(.init(systemName: "delete.left"), for: .normal)
        exitBtn.layer.cornerRadius = 8
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
}
