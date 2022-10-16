//
//  SideMenuViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 14.10.2022.
//

import UIKit
import LBTATools
import FirebaseAuth

final class SideMenuViewController: UIViewController {
    
    //MARK: UI
    let exitBtn = UIButton(title: " Log Out", titleColor: .systemRed, backgroundColor: .white, target: self, action: #selector(didTapExit))
    let buttonLists = MenuButtonsList()
    let userFullNameLbl = UILabel(text: AuthManager.shared.currentUser?.fullName, font: .systemFont(ofSize: 22, weight: .heavy), textColor: .white)
    let versionLbl = UILabel(text: "v1.0.0", font: .systemFont(ofSize: 13, weight: .light), textColor: .white, textAlignment: .center, numberOfLines: 1)
    

}

//MARK: Core
extension SideMenuViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .main3
        prepareExitBtn()
        
        view.stack(
            userFullNameLbl,
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

struct MenuButton {
    let image: UIImage
    let title: String
    let handler: ()->()
}

class MenuButtonCell: LBTAListCell<MenuButton> {
    
    override var item: MenuButton! {
        didSet {
            btn.setTitle(item.title, for: .normal)
            btnImage.image = item.image
        }
    }
    
    let btnImage = UIImageView(image: nil, contentMode: .scaleAspectFit)
    let btn = UIButton(title: "", titleColor: .white, font: .systemFont(ofSize: 15), target: self, action: #selector(didTapBtn))
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .clear
        btnImage.tintColor = .white
        hstack(btnImage, btn, UIView(), spacing: 10)
    }
    
    @objc func didTapBtn() {
        item.handler()
    }
    
}

class MenuButtonsList: LBTAListController<MenuButtonCell, MenuButton>, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = [
            .init(image: .init(systemName: "person")!, title: "Profile", handler: {
                print("did tap profile")
            }),
            .init(image: .init(systemName: "gearshape")!, title: "Settings", handler: {
                print("did tap  settings")
            })
        ]
        collectionView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 45)
    }
    
}
