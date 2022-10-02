//
//  WelcomeViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 2.10.2022.
//

import UIKit

final class WelcomeViewController: UIViewController {
    
    //MARK: UI
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentSize = .init(
            width: (view.frame.width * 0.9) * 3,
            height: view.frame.height * 0.8)
        sv.backgroundColor = .red
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
        sv.layer.shadowRadius = 30
        sv.layer.shadowOpacity = 0.3
        sv.layer.shadowOffset = .zero
        return sv
    }()
    
    private lazy var mockview: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
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
        view.backgroundColor = .systemBackground
        preparePageViews()
    }
    
    private func preparePageViews() {
        let vc = WelcomePage3ViewController()
        addChild(vc)
        vc.didMove(toParent: self)
        scrollView.addSubview(vc.view)
        vc.view.frame = .init(x: scrollView.frame.width * 2, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(scrollView)
        view.addSubview(pagingView)
        scrollView.addSubview(mockview)
        mockview.frame = .init(x: scrollView.frame.width * 1, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        
        NSLayoutConstraint.activate([
            pagingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pagingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }
}

//MARK: ScrollViewExtensions
extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = view.frame.width
        pagingView.currentPage = x > width * 2 * 0.5 ? 2 : x > width * 0.5 ? 1 : 0
    }
}
