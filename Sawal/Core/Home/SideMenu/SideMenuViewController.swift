//
//  SideMenuViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 14.10.2022.
//

import UIKit
import LBTATools
import FirebaseAuth

protocol SideMenuViewControllerInterface: AnyObject {
    
}

final class SideMenuViewController: UIViewController, SideMenuViewControllerInterface {
    
    //MARK: Def
    lazy var buttonLists: MenuButtonsList = {
        let list = MenuButtonsList()
        list.delegate = self
        return list
    }()
    
    //MARK: UI
    let exitBtn = UIButton(title: " Log Out", titleColor: .systemRed, backgroundColor: .white, target: self, action: #selector(didTapExit))
    
    let userFullNameLbl = UILabel(text: AuthManager.shared.currentUser?.fullName, font: .systemFont(ofSize: 22, weight: .heavy), textColor: .white)
    
    let userMailLbl = UILabel(text: AuthManager.shared.currentUser?.mail, font: .systemFont(ofSize: 13, weight: .light), textColor: .white)
    
    let versionLbl = UILabel(text: "v0.0.5", font: .systemFont(ofSize: 13, weight: .light), textColor: .white, textAlignment: .center, numberOfLines: 1)

}

//MARK: Core
extension SideMenuViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(colours: [.main3Light, .main3])
        view.clipsToBounds = true
        prepareExitBtn()
        
        view.stack(
            view.stack(
                userFullNameLbl,
                userMailLbl),
            buttonLists.view,
            UIView(),
            view.stack(exitBtn.withHeight(45),
                      versionLbl,
                      spacing: 6),
            spacing: 12
        ).withMargins(.allSides(20))
        
    }
}

//MARK: Funcs
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
        } catch _ {
        }
    }
    
}



