//
//  HomeControllerViewModel.swift
//  TestableApp
//
//  Created by Bora Erdem on 28.09.2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol HomeViewModelInterface: AnyObject {
    func fetchCalls()
}

final class HomeControllerViewModel {
}

extension HomeControllerViewModel: HomeViewModelInterface {
    func fetchCalls() {
        CallService.shared.fetchActiveCalls {  _ in }
    }
}

struct HomeBtnViewModel {
    let title: String
    let subtitle: String
    let imgName: String
}

