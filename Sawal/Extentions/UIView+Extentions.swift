//
//  UIView+Extentions.swift
//  TestableApp
//
//  Created by Bora Erdem on 3.10.2022.
//

import Foundation
import UIKit

extension UIView {
    
    func makeConstraints(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, topMargin: CGFloat, leftMargin: CGFloat, rightMargin: CGFloat, bottomMargin: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: topMargin).isActive = true
        }
        
        if let left = left {
            self.leadingAnchor.constraint(equalTo: left, constant: leftMargin).isActive = true
        }
        
        if let right = right {
            self.trailingAnchor.constraint(equalTo: right, constant: -rightMargin).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomMargin).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach{ addSubview($0) }
    }
    
    func applyGradient(colours: [UIColor]) {
        return self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10
        layer.shadowOffset = .zero
    }
    
    func handleSafeAreaBlurs() {
        let visualBottomBlur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        let visualTopBlur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        self.addSubviews(visualBottomBlur,visualTopBlur)
        visualBottomBlur.anchor(top: self.safeAreaLayoutGuide.bottomAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        visualTopBlur.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.safeAreaLayoutGuide.topAnchor, trailing: self.trailingAnchor)
    }
    
    func addExitBtn() -> UIButton {
        lazy var exitBtn: UIButton = {
            let btn = UIButton()
            btn.setImage(.init(systemName: "xmark"), for: .normal)
            btn.tintColor = .label
            btn.layer.cornerRadius = 8
            btn.backgroundColor = .secondarySystemBackground
            return btn
        }()
        
        self.addSubviews(exitBtn)
        exitBtn.anchor(top: self.safeAreaLayoutGuide.topAnchor, leading: self.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 0), size: .init(width: 45, height: 45))
        exitBtn.dropShadow()
        return exitBtn
    }
    
}
