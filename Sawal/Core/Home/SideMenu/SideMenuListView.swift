//
//  SideMenuListView.swift
//  Sawal
//
//  Created by Bora Erdem on 27.11.2022.
//

import Foundation
import LBTATools

struct MenuButton {
    let image: UIImage
    let title: String
    let handler: ()->()
}

class MenuButtonCell: LBTAListCell<MenuButton> {
    
    //Configure cell
    override var item: MenuButton! {
        didSet {
            btn.setTitle(item.title, for: .normal)
            btnImage.image = item.image
        }
    }
    
    //UI
    let btnImage = UIImageView(image: nil, contentMode: .scaleAspectFit)
    let btn = UIButton(title: "", titleColor: .white, font: .systemFont(ofSize: 15), target: self, action: #selector(didTapBtn))
    
    //Core
    override func setupViews() {
        super.setupViews()
        backgroundColor = .clear
        btnImage.tintColor = .white
        hstack(btnImage, btn, UIView(), spacing: 10)
    }
    
    //Objc
    @objc func didTapBtn() {
        item.handler()
    }
}

class MenuButtonsList: LBTAListController<MenuButtonCell, MenuButton> {
    
    //Def
    weak var delegate: SideMenuViewControllerInterface?
    var superView: UIViewController!
    
    //Core
    override func viewDidLoad() {
        superView = delegate as? SideMenuViewController
        super.viewDidLoad()
        items = [
            .init(image: .init(systemName: "gearshape")!, title: "Settings", handler: didTapSettings)
        ]
        collectionView.backgroundColor = .clear
    }
    
}

//Button's funcs
extension MenuButtonsList {
    func didTapSettings() {
        superView.navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
}

extension MenuButtonsList: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 45)
    }
}
