//
//  SettingsViewController.swift
//  Sawal
//
//  Created by Bora Erdem on 18.10.2022.
//

import UIKit
import LBTATools
import SwiftUI

class SettingsViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.stack(
            prepareCustomTitle(),
            prepareInfoContainer(),
            prepareDeveloperContainer(),
            UIView(),
        spacing: 10)
            .withMargins(.allSides(16))
    }
    
    func prepareCustomTitle() -> UIView {
        let title = UILabel(text: "Settings", font: .systemFont(ofSize: 22, weight: .bold), textColor: .label, textAlignment: .center, numberOfLines: 1)
        return title
    }
    
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

class ItemsCell: LBTAListCell<[String]> {
    
    override var item: [String]! {
        didSet{
            title.text = item[0]
            desc.text = item[1]
            image.image = .init(systemName: item[2])
        }
    }
    
    let title = UILabel(text: "", font: .systemFont(ofSize: 17, weight: .bold), textColor: .label, textAlignment: .center, numberOfLines: 0)
    
    let desc = UILabel(text: "", font: .systemFont(ofSize: 17, weight: .regular), textColor: .label, textAlignment: .center, numberOfLines: 0)
    
    let image = UIImageView(image: .init(systemName: "house"), contentMode: .scaleAspectFit)

    
    override func setupViews() {
        super.setupViews()
        image.tintColor = .label
        image.withWidth(15)
        image.withHeight(15)
        backgroundColor = .clear
        stack(
            hstack(image, title,UIView(), desc, spacing: 10)
        )
            .withMargins(.init(top: 5, left: 20, bottom: 5, right: 20))
        
    }
    
}

class ItemsList: LBTAListController<ItemsCell, [String]>, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
        
}


//Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return SettingsViewController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
        
    }
}
