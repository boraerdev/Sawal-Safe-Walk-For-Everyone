//
//  SettingsViewController.swift
//  Sawal
//
//  Created by Bora Erdem on 18.10.2022.
//

import UIKit
import LBTATools

class SettingsViewController: UIViewController {
    
    //MARK: Def
    // Cell name-desc-icon
    let infoContainerList: ItemsList = {
       let list = ItemsList()
        list.items = [
            ["App", "", "info"],
            ["Name", "Sawal", "character.cursor.ibeam"],
            ["Version", "v0.0.5", "number"],
            ["Developer", "Bora Erdem", "person"]
        ]
        return list
    }()
    let devContainerList: ItemsList = {
       let list = ItemsList()
        list.items = [
            ["Bora Erdem", "", "person"],
            ["GitHub", "/boraerdev", "number"],
            ["Feedback", "boraerdev@gmail", "number"]
        ]
        return list
    }()
    
    //MARK: Core
    override func viewDidLoad() {
        title = "Settings"
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.stack(
            prepareInfoContainer(),
            prepareDeveloperContainer(),
            UIView(),
        spacing: 10)
            .withMargins(.allSides(16))
    }
    
}

//MARK: Funcs
extension SettingsViewController {
    func prepareInfoContainer() -> UIView {
        let bg = UIView(backgroundColor: .secondarySystemBackground)
        bg.withHeight(CGFloat(infoContainerList.items.count)*50)
        bg.layer.cornerRadius = 8
        bg.stack(infoContainerList.view)
        bg.clipsToBounds = true
        return bg
    }
    
    func prepareDeveloperContainer() -> UIView {
        let bg = UIView(backgroundColor: .secondarySystemBackground)
        bg.withHeight(CGFloat(devContainerList.items.count)*50)
        bg.layer.cornerRadius = 8
        bg.stack(devContainerList.view)
        bg.clipsToBounds = true
        return bg
    }

}


