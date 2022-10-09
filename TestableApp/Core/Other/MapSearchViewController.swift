//
//  MapSearchViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 9.10.2022.
//

import UIKit
import LBTATools
import MapKit


class MapSearchCell: LBTAListCell<MKMapItem> {
    
    override var item: MKMapItem! {
        didSet {
            nameLbl.text = item.name
            adressLbl.text = item.address()
        }
    }
    
    let nameLbl = UILabel()
    let adressLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .secondaryLabel, textAlignment: .left, numberOfLines: 2)
    
    override func setupViews() {
        super.setupViews()
        stack(nameLbl, adressLbl).withMargins(.allSides(20))
        addSeparatorView()
    }
}

class MapSearchViewController: LBTAListController<MapSearchCell, MKMapItem> {
    
    var selectionHandler: ((MKMapItem)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performLocalSearch()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
}

extension MapSearchViewController {
    private func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Apple"
        let search = MKLocalSearch(request: request)
        search.start { [weak self] resp, err in
            guard err == nil else {return}
            self?.items = resp?.mapItems ?? []
        }
    }
}


extension MapSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .init(0)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mapItem = self.items[indexPath.item]
        selectionHandler?(mapItem)
    }
}
