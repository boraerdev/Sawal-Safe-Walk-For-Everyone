//
//  ItemsList.swift
//  Sawal
//
//  Created by Bora Erdem on 27.11.2022.
//

import Foundation
import LBTATools

class ItemsCell: LBTAListCell<[String]> {
    
    //Configure cell
    override var item: [String]! {
        didSet{
            title.text = item[0]
            desc.text = item[1]
            image.image = .init(systemName: item[2])
        }
    }
    
    //UI
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

class ItemsList: LBTAListController<ItemsCell, [String]> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
    }
    
}

extension ItemsList: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
