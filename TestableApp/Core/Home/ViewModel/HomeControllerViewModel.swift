//
//  HomeControllerViewModel.swift
//  TestableApp
//
//  Created by Bora Erdem on 28.09.2022.
//

import Foundation

protocol HomeControllerViewModelDelegate: AnyObject{
    var viewDelegate: HomeViewControllerDelegate? {get set}
    func viewDidLoad()
    
}

final class HomeControllerViewModel{
    weak var viewDelegate: HomeViewControllerDelegate?
}

extension HomeControllerViewModel: HomeControllerViewModelDelegate {
    func viewDidLoad(){
        
    }
}
