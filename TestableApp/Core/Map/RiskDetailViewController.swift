//
//  RiskDetailViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 14.10.2022.
//

import UIKit
//TODO
class RiskDetailViewController: UIViewController {

    //MARK: Def
    var post: Post! = nil
    
    //MARK: UI
    let desc = UILabel(text: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        desc.text = post.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.stack(desc)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        desc.removeFromSuperview()
        post = nil
    }
 
}
