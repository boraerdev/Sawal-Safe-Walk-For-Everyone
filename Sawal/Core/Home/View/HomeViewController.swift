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
import LBTATools

protocol HomeViewControllerInterface: AnyObject {
}

//MARK: Def, UI
final class HomeViewController: UIViewController {
    
    //MARK: Def
    let viewModel = HomeControllerViewModel()
    let disposeBag = DisposeBag()
    let sideMenu = SideMenuViewController()
    let darkBgForSideMenu = UIView(backgroundColor: .black.withAlphaComponent(0.1))

    
    //MARK: UI
    private lazy var goMapBtn = UIButton()
    
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
    
    private lazy var shareRiskBtn = UIButton()
    
    private lazy var planTrpBtn = UIButton()
    
}

//MARK: Core
extension HomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMainView()
        prepareStack()
        performButtons()
    }
}

//MARK: Funcs
extension HomeViewController {
    
    private func prepareMainView() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.titleView = welcomeStack
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "line.3.horizontal"), style: .done, target: self, action: #selector(didTapMenu))
    }
    
    private func prepareSideMenu() {
        addChild(sideMenu)
        sideMenu.didMove(toParent: self)
        darkBgForSideMenu.isUserInteractionEnabled = true
        view.addSubview(darkBgForSideMenu)
        darkBgForSideMenu.fillSuperview()
        view.addSubview(sideMenu.view)
        sideMenu.view.frame = .init(x: -(view.frame.width * 0.8), y: 0, width: view.frame.width * 0.8, height: view.frame.height)
        darkBgForSideMenu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenu)))
    }
    
    private func prepareStack() {
        let container = UIView()
        view.stack(container).withMargins(.init(top: 10, left: 20, bottom:0, right: 20))
        
        container.stack(
            container.hstack(goMapBtn, shareRiskBtn, spacing: 10, distribution: .fillEqually),
            planTrpBtn,
            spacing: 10,
            distribution: .fillEqually
        )
        configureButtons()
        
    }
    
    private func configureButtons() {
        let titles = ["Go Map", "Share a Risk", "Plan a Trip"]
        let icons = ["map.fill", "square.and.arrow.up.trianglebadge.exclamationmark", "location.fill"]
        let colors: [UIColor] = [.main1Light, .main2Light, .main3Light]
        [goMapBtn,shareRiskBtn, planTrpBtn].enumerated().forEach { i,btn in
            btn.backgroundColor = .systemBackground
            let bgImg = UIImageView(image: .init(systemName: icons[i])!)
            bgImg.frame = .init(x: -30, y: 15, width: 130, height: 130)
            bgImg.contentMode = .scaleAspectFit
            btn.setTitle(titles[i], for: .normal)
            btn.setTitleColor(colors[i], for: .normal)
            bgImg.tintColor = .secondarySystemBackground
            bgImg.alpha = 1
            
            btn.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
            btn.layer.borderWidth = 0.2
            btn.layer.cornerRadius = 8
            btn.layer.masksToBounds = true
            btn.addSubview(bgImg)
        }
    }
    
    private func performButtons() {
        goMapBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(MapViewController(), animated: true)
        })
        .disposed(by: disposeBag)
        
        shareRiskBtn.rx.tap.subscribe(onNext: {[unowned self] in
            let simulator = true
            simulator ? navigationController?.pushViewController(ShareViewController(), animated: true) :                     navigationController?.pushViewController(CameraView(), animated: true)
        })
        .disposed(by: disposeBag)
        
        planTrpBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(PlanATripViewController(), animated: true)
        })
        .disposed(by: disposeBag)
        
    }

}

//MARK: Objc
extension HomeViewController {
    @objc func didTapMenu() {
        welcomeStack.isHidden = true
        prepareSideMenu()
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else {return}
            self.sideMenu.view.frame = .init(x: 0, y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height)
        }
    }
    
    @objc func closeMenu() {
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.sideMenu.view.frame = .init(x: -(self.view.frame.width * 0.8), y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height)

        } completion: { [weak self] isFinish in
            self?.sideMenu.view.removeFromSuperview()
            self?.sideMenu.removeFromParent()
            self?.darkBgForSideMenu.removeFromSuperview()
            self?.welcomeStack.isHidden = false
        }
    }
}
