//
//  WelcomePage3ViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 2.10.2022.
//

import UIKit

final class WelcomePage2ViewController: UIViewController {
    
    
    //MARK: UI
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Post Risk"
        lbl.textColor = .systemBackground
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        return lbl
    }()
    
    private lazy var descLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "We use the data we collect from you for a safe walk and create safe routes based on this data. Don't forget to share the risk points around you for safer walks."
        lbl.numberOfLines = 0
        lbl.textColor = .systemBackground
        lbl.font = .systemFont(ofSize: 13, weight: .light)
        return lbl
    }()
    
    private var textStack: UIStackView!
    
    private lazy var mainImage: UIImageView = {
       let img = UIImageView()
        img.image = .init(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
        img.tintColor = .systemBackground
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.clipsToBounds = true
        
        prepareStacks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setGradientBackground()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(textStack)
        view.addSubview(mainImage)
        
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            mainImage.widthAnchor.constraint(equalToConstant: 400),
            mainImage.heightAnchor.constraint(equalToConstant: 400),
            mainImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -80),
            mainImage.topAnchor.constraint(equalTo: view.topAnchor, constant: -80),
            
        ])
    }
}

//MARK: Extentions
extension WelcomePage2ViewController {
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}


extension WelcomePage2ViewController {
    private func setGradientBackground() {
        let colorTop =  UIColor.main2.cgColor
        let colorBottom = UIColor.main2Light.cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func prepareStacks() {
        textStack = .init(arrangedSubviews: [titleLabel,descLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 10
    }
}
