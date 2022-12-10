//
//  SearchTextField.swift
//  Sawal
//
//  Created by Bora Erdem on 10.12.2022.
//

import Foundation
import UIKit

class SearchTextField: UITextField {
    
    let padding: CGFloat

    public init(placeholder: String? = nil, padding: CGFloat = 0, cornerRadius: CGFloat = 0, keyboardType: UIKeyboardType = .default, backgroundColor: UIColor = .clear, isSecureTextEntry: Bool = false) {
        self.padding = padding
        super.init(frame: .zero)
        self.placeholder = placeholder
        layer.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.keyboardType = keyboardType
        self.isSecureTextEntry = isSecureTextEntry
        attributedPlaceholder = .init(string: placeholder ?? "", attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.3)])
        configure()
    }
    
    func configure() {
        textColor = .label
        layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 0.2
        layer.cornerRadius = 8
        backgroundColor = .systemBackground
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
