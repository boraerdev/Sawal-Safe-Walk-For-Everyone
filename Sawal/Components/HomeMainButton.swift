//
//  MainHomeButton.swift
//  Sawal
//
//  Created by Bora Erdem on 10.12.2022.
//

import Foundation
import UIKit
import LBTATools

class HomeMainButton: UIButton {

    var mySubtitleLabel: UILabel!
    var myTitleLabel: UILabel!
    var bgImg: UIImageView!
    

    public init(imgName: String, subtitle: String, title: String) {
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        setTitle("", for: .normal)
        layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 0.2
        layer.cornerRadius = 8
        layer.masksToBounds = true

        bgImg = UIImageView()
        bgImg.contentMode = .scaleAspectFit
        bgImg.tintColor = .secondarySystemBackground
        bgImg.alpha = 1
        addSubview(bgImg)

        mySubtitleLabel = UILabel()
        mySubtitleLabel.font = .systemFont(ofSize: 13)
        mySubtitleLabel.textColor = .secondaryLabel
        mySubtitleLabel.textAlignment = .left
        mySubtitleLabel.numberOfLines = 2
        addSubview(mySubtitleLabel)

        myTitleLabel = UILabel()
        myTitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        myTitleLabel.textColor = .label
        myTitleLabel.textAlignment = .left
        myTitleLabel.numberOfLines = 2
        addSubview(myTitleLabel)
        
        setButtonProperties(imgName: imgName, subtitle: subtitle, title: title)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func setButtonProperties(imgName: String, subtitle: String, title: String) {
        bgImg.image = UIImage(named: imgName)
        mySubtitleLabel.text = subtitle
        myTitleLabel.text = title

        bgImg.anchor(top: topAnchor, leading: .none, bottom: .none, trailing: trailingAnchor, padding: .init(top: -100, left: 0, bottom: 0, right: -140), size: .init(width: 350, height: 350))
        mySubtitleLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 20, bottom: 20, right: 20))
        myTitleLabel.anchor(top: nil, leading: mySubtitleLabel.leadingAnchor, bottom: mySubtitleLabel.topAnchor, trailing: .none)
        myTitleLabel.withWidth(100)
    }
}
