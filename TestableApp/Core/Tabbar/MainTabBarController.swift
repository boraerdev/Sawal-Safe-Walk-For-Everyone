//
//  ViewController.swift
//  CustomTabBarApp
//
//  Created by Vasichko Anna on 02.06.2022.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBar()
        tabBar.tintColor = .label
        tabBar.shadowImage = UIImage()
    }
    
    private func generateTabBar() {
        viewControllers = [
            generateVC(
                viewController: HomeViewController(),
                title: "Home",
                image: UIImage(systemName: "house")
            ),
            generateVC(
                viewController: SearchViewController(),
                title: "Search",
                image: UIImage(systemName: "magnifyingglass")
            ),
            generateVC(
                viewController: QrViewController(),
                title: "Scan",
                image: UIImage(systemName: "qrcode")
            ),
            generateVC(
                viewController: MapViewController(),
                title: "Map",
                image: UIImage(systemName: "map")
            ),
            generateVC(
                viewController: PersonViewController(),
                title: "Person",
                image: UIImage(systemName: "person")
            ),
            
        ]
    }
    
    private func generateVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
    
}

