//
//  HomeViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 26.09.2022.
//

import UIKit
import FirebaseAuth

protocol HomeViewControllerInterface: AnyObject {
}

class HomeViewController: UIViewController {
    
    //MARK: Def
    let viewModel = HomeControllerViewModel()
    
    //MARK: UI
    private lazy var testLbl: UILabel = {
        let lbl = UILabel()
        lbl.frame = .init(x: 0, y: 0, width: 200, height: 40)
        lbl.center = view.center
        return lbl
    }()
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(testLbl)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testLbl.text = AuthManager.shared.currentUser?.mail
    }
}

