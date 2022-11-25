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
    func configureButtons()
    func bindButtons()
}

//MARK: Def, UI
final class HomeViewController: UIViewController, HomeViewControllerInterface {
    
    //MARK: Def
    let viewModel = HomeControllerViewModel()
    let disposeBag = DisposeBag()
    let sideMenu = SideMenuViewController()
    let darkBgForSideMenu = UIView(backgroundColor: .black.withAlphaComponent(0.1))
    let badgeText = UILabel(text: "1",font: .systemFont(ofSize: 13), textColor: .white)

    //MARK: UI
    private lazy var goMapBtn = UIButton()
    private var tmpCircleView: UIView? = nil
    
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
    
    private lazy var videoCallBtn = UIButton()
    
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
        configureButtons()
    }
    
    func configureButtons() {
        
        let buttons: [HomeBtnViewModel] = [
            .init(title: "Map", subtitle: "Go map and take a look risky areas.", imgName: "Location"),
            .init(title: "Post", subtitle: "Post a risk and make trips safer.", imgName: "Attention"),
            .init(title: "Plan a Trip", subtitle: "Plan a trip and walk safely.", imgName: "Checkbox"),
            .init(title: "Be My Eyes", subtitle: "Start a video call and get directions.", imgName: "Compass")
        ]
        

        [goMapBtn,shareRiskBtn, planTrpBtn, videoCallBtn].enumerated().forEach { i,btn in
            //Bg Img
            let bgImg = UIImageView(image: .init(named: buttons[i].imgName)!)
            bgImg.contentMode = .scaleAspectFit
            bgImg.tintColor = .secondarySystemBackground
            bgImg.alpha = 1
            
            //Btn
            btn.backgroundColor = .systemBackground
            btn.setTitle("", for: .normal)
            btn.layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
            btn.layer.borderWidth = 0.2
            btn.layer.cornerRadius = 8
            btn.layer.masksToBounds = true
            btn.addSubview(bgImg)
            bgImg.anchor(top: btn.topAnchor, leading: .none, bottom: .none, trailing: btn.trailingAnchor, padding: .init(top: -100, left: 0, bottom: 0, right: -140), size: .init(width: 350, height: 350))

            //Subtitle
            let subtitle = UILabel(text: buttons[i].subtitle, font: .systemFont(ofSize: 13), textColor: .secondaryLabel, textAlignment: .left, numberOfLines: 2)
            btn.addSubview(subtitle)
            subtitle.anchor(top: nil, leading: btn.leadingAnchor, bottom: btn.bottomAnchor, trailing: btn.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 20, right: 20))
            
            //Title
            let titleBtn = UILabel(text: buttons[i].title, font: .systemFont(ofSize: 28, weight: .bold), textColor: .label, textAlignment: .left, numberOfLines: 2)
            btn.addSubview(titleBtn)
            titleBtn.anchor(top: nil, leading: subtitle.leadingAnchor, bottom: subtitle.topAnchor, trailing: .none)
            titleBtn.withWidth(100)
            
        }
    }
    
    func bindButtons() {
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
        
        videoCallBtn.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(VideoCallViewController(), animated: true)
        })
        .disposed(by: disposeBag)
        
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
