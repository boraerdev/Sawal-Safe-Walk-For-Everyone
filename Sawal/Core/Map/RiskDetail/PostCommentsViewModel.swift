//
//  PostCommentsViewModel.swift
//  Sawal
//
//  Created by Bora Erdem on 16.10.2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol PostCommentsViewModelInterface: AnyObject {
    func getAllComments(completion: @escaping ([Comment])->())
    func viewDidLoad()
}

class PostCommentsViewModel {
    weak var view: PostCommentsViewControllerInterface?
    var commentList: BehaviorRelay<[Comment]> = .init(value: [])
}



extension PostCommentsViewModel: PostCommentsViewModelInterface {
    func viewDidLoad() {
    }
    
    func getAllComments(completion: @escaping ([Comment])->()) {
        PostService.shared.getPostComments(of: view?.post.id ?? "") { result in
            switch result {
            case .success(let success):
                completion(success)
            case .failure(_):
                completion([])
            }
        }
    }
    
    
}
