//
//  WelcomePage3ViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 2.10.2022.
//

import UIKit

final class WelcomePage3ViewController: UIViewController {
    
    
    //MARK: UI
    private lazy var getStartButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Get Started", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.contentEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        prepareButtons()
    }
    
    private func prepareButtons() {
        getStartButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(getStartButton)
        
        NSLayoutConstraint.activate([
            getStartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
        
        //CornerRadius
        getStartButton.layer.cornerRadius = getStartButton.frame.height / 2
    }
}

//MARK: Extentions
extension WelcomePage3ViewController {

    @objc func didTapStart() {
        //UserDefaults.standard.set(true, forKey: "isStarted")
        let vc = UINavigationController(rootViewController: SignInViewController())
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .partialCurl
        present(vc, animated: true)
    }
    
}
