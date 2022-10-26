//
//  ShowRouteViewController.swift
//  Sawal
//
//  Created by Bora Erdem on 26.10.2022.
//

import UIKit
import LBTATools
import MapKit
import RxSwift
import RxCocoa

final class ShowRouteViewController: LBTAListController<DirectionCell, MKRoute.Step>, UICollectionViewDelegateFlowLayout {
    
    //MARK: Def
    let tripVM = PlanATripViewModel.shared
    let disposeBag = DisposeBag()
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instructions"
        collectionView.contentInset.top = 10
        handleScrollToDirection()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .systemBackground
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 100)
    }
    
    private func handleScrollToDirection() {
        tripVM.currentStep.subscribe { result in
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: .init(item: result.element ?? 0, section: 0), at: .top, animated: true)
                guard let cell = self.collectionView.cellForItem(at: .init(item: result.element ?? 0, section: 0)) as? DirectionCell else {return}
                cell.container.layer.borderWidth = 2
                cell.container.layer.borderColor = UIColor.main3Light.cgColor
                cell.container.dropShadow()
            }
        }.disposed(by: disposeBag)
    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
    
}
