//
//  HomeViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 26.09.2022.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa

protocol HomeViewControllerInterface: AnyObject {
}

final class HomeViewController: UIViewController {
    
    //MARK: Def
    let viewModel = HomeControllerViewModel()
    let disposeBag = DisposeBag()
    
    //MARK: UI
    private lazy var goMapBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.layer.cornerRadius = 8
        btn.setTitle("Go Map", for: .normal)
        let bgImg = UIImageView(image: .init(systemName: "map.fill")!)
        bgImg.frame = .init(x: -20, y: 20, width: 100, height: 100)
        bgImg.contentMode = .scaleAspectFit
        bgImg.tintColor = .secondarySystemBackground
        bgImg.alpha = 0.3
        btn.clipsToBounds = true
        btn.addSubview(bgImg)
        return btn
    }()
    
    private lazy var welcomeStack: UIStackView = {
        let welcomeText = UILabel()
        welcomeText.text = "Welcome Back,"
        welcomeText.font = .systemFont(ofSize: 13)
        let name = UILabel()
        name.text = AuthManager.shared.currentUser?.fullName
        name.font = .boldSystemFont(ofSize: 13)
        let stack = UIStackView(arrangedSubviews: [welcomeText,name])
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.spacing = 4
        return stack
    }()
    
    private lazy var addRiskBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 8
        btn.setTitle("Share a Risk", for: .normal)
        btn.setTitleColor(.secondarySystemBackground, for: .selected)
        let bgImg = UIImageView(image: .init(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")!)
        bgImg.frame = .init(x: -20, y: 20, width: 100, height: 100)
        bgImg.contentMode = .scaleAspectFit
        bgImg.tintColor = .secondarySystemBackground
        bgImg.alpha = 0.3
        btn.clipsToBounds = true
        btn.addSubview(bgImg)
        return btn
    }()
    
    private lazy var planTrpBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("Plan a Trip", for: .normal)
        let bgImg = UIImageView(image: .init(systemName: "paperplane")!)
        bgImg.frame = .init(x: -20, y: 20, width: 100, height: 100)
        bgImg.contentMode = .scaleAspectFit
        bgImg.tintColor = .secondarySystemBackground
        bgImg.alpha = 0.3
        btn.clipsToBounds = true
        btn.addSubview(bgImg)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    private var btnHStack: UIStackView!
    private var btnVStack: UIStackView!
    
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.titleView = welcomeStack
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "line.3.horizontal"), style: .done, target: self, action: #selector(didTapMenu))
        prepareStack()
        performButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(btnVStack)
        
        btnVStack.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: view.leadingAnchor, right: view.trailingAnchor, bottom: nil, topMargin: 0, leftMargin: 20, rightMargin: 20, bottomMargin: 0, width: 0, height: 250)
        
        goMapBtn.applyGradient(colours: [.main1,.main1Light])
        addRiskBtn.applyGradient(colours: [.main2,.main2Light])
        planTrpBtn.applyGradient(colours: [.main3,.main3Light])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
}

extension HomeViewController {
    @objc func didTapMenu() {
        //
    }
    
    private func prepareStack() {
        btnHStack = .init(arrangedSubviews: [goMapBtn, addRiskBtn])
        btnHStack.axis = .horizontal
        btnHStack.distribution = .fillEqually
        btnHStack.spacing = 10
        
        btnVStack = .init(arrangedSubviews: [btnHStack,planTrpBtn])
        btnVStack.translatesAutoresizingMaskIntoConstraints = false
        btnVStack.axis = .vertical
        btnVStack.distribution = .fillEqually
        btnVStack.spacing = 10
    }
    
    private func performButtons() {
        goMapBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.tabBarController?.selectedIndex = 1
        })
        .disposed(by: disposeBag)
        
        addRiskBtn.rx.tap.subscribe(onNext: {[unowned self] in
            //TODO
            let simulator = true
            simulator ? navigationController?.pushViewController(ShareViewController(), animated: true) : navigationController?.pushViewController(CustomCameraController(), animated: true)
        })
        .disposed(by: disposeBag)
        
        planTrpBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(PlanATripViewController(), animated: true)
        })
        .disposed(by: disposeBag)
    }

}


