//
//  WelcomeViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 2.10.2022.
//

import UIKit
import LBTATools

final class WelcomeViewController: UIViewController {
    
    //MARK: UI
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentSize = .init(
            width: (view.frame.width * 0.9) * 3,
            height: view.frame.height * 0.8)
        sv.backgroundColor = .systemBackground
        sv.isPagingEnabled = true
        sv.frame = .init(
            x: 0,
            y: 0,
            width: view.frame.width * 0.9,
            height: view.frame.height * 0.8)
        sv.center = view.center
        sv.delegate = self
        sv.layer.cornerRadius = 10
        sv.showsHorizontalScrollIndicator = false
        sv.layer.shadowColor = UIColor.black.cgColor
        sv.layer.shadowPath = .init(ellipseIn: .init(x: 0, y: 0, width: 40, height: 40), transform: .none)
        sv.layer.shadowRadius = 20
        return sv
    }()
    
    private lazy var getStartBtn: UIButton = {
        let btn = UIButton(type: .custom)
        if let starImg = UIImage(systemName: "chevron.right.square") {
            btn.setImage(starImg, for: .normal)
        }
        btn.setTitle(" Get Started", for: .normal)
        btn.setTitleColor(.init(named: "main"), for: .normal)
        btn.addTarget(self, action: #selector(didTapStart(_:)), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = .init(named: "main")
        btn.isHidden = true
        
        return btn
    }()
    
    private lazy var pagingView: UIPageControl = {
       let pv = UIPageControl()
        pv.numberOfPages = 3
        pv.frame = .zero
        pv.pageIndicatorTintColor = .label.withAlphaComponent(0.3)
        pv.currentPageIndicatorTintColor = .label
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addSubViewForScrollView()
    }
    
    private func addSubViewForScrollView(){
        for (index, item) in [WelcomePage1ViewController(), WelcomePage2ViewController(), WelcomePage3ViewController()].enumerated() {
            let vc = item
            addChild(item)
            vc.didMove(toParent: self)
            scrollView.addSubview(vc.view)
            item.view.frame = .init(x: scrollView.frame.width * Double(index), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(scrollView)
        view.addSubview(pagingView)
        view.addSubview(getStartBtn)
        
        NSLayoutConstraint.activate([
            pagingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pagingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            getStartBtn.centerXAnchor.constraint(equalTo: pagingView.centerXAnchor),
            getStartBtn.centerYAnchor.constraint(equalTo: pagingView.centerYAnchor)
        ])
    }
}

//MARK: ScrollViewExtensions
extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = view.frame.width
        pagingView.currentPage = x > width * 2 * 0.5 ? 2 : x > width * 0.5 ? 1 : 0
        
        if pagingView.currentPage == 2 {
            pagingView.isHidden = true
            getStartBtn.isHidden = false
        }else {
            pagingView.isHidden = false
            getStartBtn.isHidden = true
        }
    }
}

//MARK: Objc
extension WelcomeViewController {
    @objc func didTapStart(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "isStarted")
        let vc = UINavigationController(rootViewController: SignInViewController())
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
}
