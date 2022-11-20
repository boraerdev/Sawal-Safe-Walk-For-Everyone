//
//  CallList.swift
//  Sawal
//
//  Created by Bora Erdem on 20.11.2022.
//

import Foundation
import LBTATools
import RxSwift
import RxCocoa

class CallCell: LBTAListCell<Call> {
    
    let label = UILabel(text: "test")
    let joinBtn = UIButton(title: "Join", titleColor: .systemBackground, font: .systemFont(ofSize: 13), backgroundColor: .main3, target: self, action: #selector(didTapjoin))
    
    override var item: Call! {
        didSet {
            fetchUser(uid: item.authorUid)
        }
    }
    
    @objc func didTapjoin() {
        if let parent = parentController as? CallList {
            parent.joinChannel(uid: item.authorUid)
        }
    }
    
    func fetchUser(uid: String) {
        UserService.shared.getUser(uid: uid) { [unowned self] user in
            label.text = user.fullName
        }
    }
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .clear
        layer.borderColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 0.2
        layer.cornerRadius = 8
        joinBtn.layer.cornerRadius = 4
        hstack(label, UIView(), joinBtn.withWidth(70)).withMargins(.allSides(10))
        
    }
    
}


class CallList: LBTAListController<CallCell, Call>, UICollectionViewDelegateFlowLayout{
    
    weak var delegate: VideoCallViewControllerInterface?
    let videoCallVM = VideoCallViewModel.shared
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        videoCallVM.calls.subscribe { [unowned self] result in
//
//        }.disposed(by: disposeBag)
//    }
    
    func joinChannel(uid: String) {
        delegate?.didTapJoin(role: .audience, channel: uid)
    }
    
}
