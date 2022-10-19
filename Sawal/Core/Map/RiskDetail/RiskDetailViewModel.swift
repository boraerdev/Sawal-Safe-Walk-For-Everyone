//
//  RiskDetailViewModel.swift
//  Sawal
//
//  Created by Bora Erdem on 16.10.2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol RiskDetailViewModelInterface: AnyObject {
    func uploadComment()
    func deletePost()
}

class RiskDetailViewModel {
    let commentText: BehaviorRelay<String> = .init(value: "")
    weak var view: RiskDetailViewControllerInterface?
    
}

extension RiskDetailViewModel: RiskDetailViewModelInterface {
    
    func deletePost() {
        PostService.shared.deletePost(post: (view?.post)!)
    }
    
    func uploadComment() {
        PostService.shared.uploadComment(for: (view?.post.id)!, comment: commentText.value)
    }
    
}
