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
    func prepareMainView()
    func prepareSideMenu()
    func prepareStack()
    func bindButtons()
}

//MARK: Def, UI
final class HomeViewController: UIViewController, HomeViewControllerInterface {
    
    //MARK: Def
    let viewModel = HomeControllerViewModel()
    let disposeBag = DisposeBag()
    let sideMenu = SideMenuViewController()

    //MARK: UI
    private lazy var goMapBtn = HomeMainButton(imgName: "Location", subtitle: "Go map and take a look risky areas.", title: "Map")
    
    private lazy var shareRiskBtn = HomeMainButton(imgName: "Attention", subtitle: "Post a risk and make trips safer.", title: "Post")
    
    private lazy var planTrpBtn = HomeMainButton(imgName: "Checkbox", subtitle: "Plan a trip and walk safely.", title: "Plan a Trip")
    
    private lazy var videoCallBtn = HomeMainButton(imgName: "Compass", subtitle: "Start a video call and get directions.", title: "Be My Eyes")
    
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
    
    private var tmpCircleView: UIView? = nil
    
    let darkBgForSideMenu = UIView(backgroundColor: .black.withAlphaComponent(0.1))
    
    let badgeText = UILabel(text: "1",font: .systemFont(ofSize: 13), textColor: .white)

}

//MARK: Core
extension HomeViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMainView()
        prepareStack()
        bindButtons()
        viewModel.fetchCalls()
        updateBadge()
    }
}

//MARK: Funcs
extension HomeViewController {
    
    func updateBadge() {
        VideoCallViewModel.shared.calls.subscribe { [unowned self] calls in
            if calls.element?.count ?? 0 > 0 {
                badgeText.text = String(calls.element?.count ?? 0)
                handleBadge()
            } else {
                tmpCircleView?.removeFromSuperview()
            }
        }.disposed(by: disposeBag)
    }
    
    func prepareMainView() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.titleView = welcomeStack
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "line.3.horizontal"), style: .done, target: self, action: #selector(didTapMenu))
    }
    
    func prepareSideMenu() {
        addChild(sideMenu)
        sideMenu.didMove(toParent: self)
        darkBgForSideMenu.isUserInteractionEnabled = true
        view.addSubview(darkBgForSideMenu)
        darkBgForSideMenu.fillSuperview()
        view.addSubview(sideMenu.view)
        sideMenu.view.frame = .init(x: -(view.frame.width * 0.8), y: 0, width: view.frame.width * 0.8, height: view.frame.height)
        darkBgForSideMenu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenu)))
    }
    
    func prepareStack() {
        let container = UIView()
        view.stack(container).withMargins(.init(top: 10, left: 20, bottom:10, right: 20))
        container.stack(
            container.hstack(goMapBtn, shareRiskBtn, spacing: 10, distribution: .fillEqually),
            planTrpBtn,
            videoCallBtn,
            spacing: 10,
            distribution: .fillEqually
        )
    }
    
    func bindButtons() {
        
        goMapBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(MapViewController(), animated: true)
        }).disposed(by: disposeBag)
        
        shareRiskBtn.rx.tap.subscribe(onNext: {[unowned self] in
            let simulator = true
            simulator ? navigationController?.pushViewController(ShareViewController(), animated: true) :                navigationController?.pushViewController(CameraView(), animated: true)
        }).disposed(by: disposeBag)
        
        planTrpBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(PlanATripViewController(), animated: true)
        }).disposed(by: disposeBag)
        
        videoCallBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(VideoCallViewController(), animated: true)
        }).disposed(by: disposeBag)
        
    }

    func handleBadge() {
        tmpCircleView?.removeFromSuperview()
        let circleView = UIView(backgroundColor: .red)
        let padding: CGFloat = -10
        let btnSize: CGFloat = 20
        circleView.withSize(.init(width: btnSize, height: btnSize))
        circleView.layer.cornerRadius = btnSize/2
        circleView.dropShadow()
        view.addSubview(circleView)
        circleView.anchor(top: videoCallBtn.topAnchor, leading: nil, bottom: nil, trailing: videoCallBtn.trailingAnchor, padding: .init(top: padding, left: 0, bottom: 0, right: padding))
        circleView.stack(badgeText, alignment: .center)
        tmpCircleView = circleView
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
