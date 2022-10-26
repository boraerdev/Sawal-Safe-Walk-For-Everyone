//
//  UIButton+Extentions.swift
//  Sawal
//
//  Created by Bora Erdem on 26.10.2022.
//

import UIKit

extension UIButton {
    func leftImage(image: UIImage, renderMode: UIImage.RenderingMode) {
           self.setImage(image.withRenderingMode(renderMode), for: .normal)
           self.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 0)
           self.titleEdgeInsets.left = (self.frame.width/2) - (self.titleLabel?.frame.width ?? 0)
           self.contentHorizontalAlignment = .left
           self.imageView?.contentMode = .scaleAspectFit
       }
}
