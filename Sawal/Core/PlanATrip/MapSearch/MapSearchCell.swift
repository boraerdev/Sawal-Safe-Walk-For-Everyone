//
//  MapSearchCell.swift
//  Sawal
//
//  Created by Bora Erdem on 23.10.2022.
//

import Foundation
import LBTATools
import MapKit

final class MapSearchCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            nameLbl.text = item.name
            adressLbl.text = item.address()
        }
    }
    
    let nameLbl = UILabel()
    
    let adressLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .secondaryLabel, textAlignment: .left, numberOfLines: 2)
    
    override func setupViews() {
        super.setupViews()
        stack(nameLbl, adressLbl).withMargins(.allSides(20))
        addSeparatorView()
        backgroundColor = .systemBackground
    }
}
