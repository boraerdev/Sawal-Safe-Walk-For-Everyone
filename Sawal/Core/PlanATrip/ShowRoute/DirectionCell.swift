//
//  DirectionCell.swift
//  Sawal
//
//  Created by Bora Erdem on 26.10.2022.
//

import UIKit
import LBTATools
import MapKit

final class DirectionCell:LBTAListCell<MKRoute.Step> {
    
    override var item: MKRoute.Step!{
        didSet{
            directionLbl.text = item.instructions
            distanceLbl.text = String(format: "%.0f m", item.distance)
            
            if item.instructions.localizedStandardContains("right") {
                directionImage.image = .init(systemName: "arrow.turn.up.right")
            } else if item.instructions.localizedStandardContains("left") {
                directionImage.image = .init(systemName: "arrow.turn.up.left")
            } else {
                directionImage.image = .init(systemName: "arrow.up")
            }
        }
    }
    
    //MARK: UI
    lazy var directionLbl = UILabel(font: .systemFont(ofSize: 15), textColor: .label, numberOfLines: 0)
    lazy var distanceLbl = UILabel(font: .systemFont(ofSize: 13), textColor: .secondaryLabel, numberOfLines: 1)
    lazy var directionImage = UIImageView(image: .init(systemName: "arrow.triangle.turn.up.right.diamond"), contentMode: .scaleAspectFit)
    let container = UIView(backgroundColor: .secondarySystemBackground)
    
    //MARK: Core
    override func setupViews() {
        super.setupViews()
        setupContainer()
        directionLbl.withWidth(280)
        layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        container.layer.borderColor = UIColor.clear.cgColor
        container.layer.borderWidth = 0
        container.layer.shadowOpacity = 0
    }
    
    //MARK: Funcs
    private func setupContainer() {
        addSubview(container)
        container.layer.cornerRadius = 8
        let anchors = container.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        anchors.leading?.constant = 10
        anchors.trailing?.constant = -10
        container.hstack(
            directionLbl,
            UIView(),
            container.stack(
                directionImage.withSize(.init(width: 50, height: 50)),
                distanceLbl,
                distribution: .fill
            )
        ).withMargins(.allSides(12))
    }
}
