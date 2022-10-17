//
//  PostCommentsViewController.swift
//  Sawal
//
//  Created by Bora Erdem on 16.10.2022.
//

import UIKit
import LBTATools

protocol PostCommentsViewControllerInterface: AnyObject {
    var post: Post! {get set}
}

class ListCommentCell: LBTAListCell<Comment> {
    
    let comment = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .secondaryLabel, numberOfLines: 0)
    let userFullName = UILabel(text: "", font: .boldSystemFont(ofSize: 13), textColor: .label, numberOfLines: 1)
    let dateLbl = UILabel(text: "", font: .systemFont(ofSize: 11), textColor: .secondaryLabel, numberOfLines: 1)
    
    
    override var item: Comment! {
        didSet {
            comment.text = item.comment
            dateLbl.text = item.date.formatted(date: .numeric, time: .shortened)
            fetchUser(id: item.authorUid)
        }
    }
    
    override func setupViews() {
        super.setupViews()
        hstack(stack(hstack(userFullName, dateLbl), comment).withMargins(.allSides(12)), alignment: .center)
        addSeparatorView()
    }
    
    func fetchUser(id: String) {
        UserService.shared.getUser(uid: id) { [weak self] user in
            self?.userFullName.text = user.fullName
        }
    }
}

final class PostCommentsViewController: LBTAListController<ListCommentCell, Comment>, PostCommentsViewControllerInterface {
    
    //MARK: Def
    let viewModel = PostCommentsViewModel()
    var post: Post! = nil
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        title = "Comments"
        prepareMainView()
        getAllCommnets()
        viewModel.viewDidLoad()
    }
}

//MARK: Funcs
extension PostCommentsViewController {
    private func prepareMainView() {
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    private func getAllCommnets() {
        viewModel.getAllComments { [weak self] list in
            self?.items = list
        }
    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
}

extension PostCommentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}
