//
//  RiskViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 12.10.2022.
//

import UIKit
import RxSwift
import RxCocoa
import LBTATools
import AVFoundation


class RiskView: UIView {
    var player: AVAudioPlayer?
    private lazy var title = UILabel(text: "Test",font: .systemFont(ofSize: 34), textColor: .secondaryLabel)
    let disposeBag = DisposeBag()
    let warningImage = UIImageView(image: .init(systemName: "exclamationmark.triangle"), contentMode: .scaleAspectFit)
    let warnLbl = UILabel(text: "Please be careful, the distance between you and the risk:", font: .boldSystemFont(ofSize: 22),textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        warnLbl.withWidth(300)
        
        
        hstack(
            stack(
                warningImage,
                warnLbl,
                title,
                spacing: 10,
                alignment: .center),
            alignment: .center)
        warningImage.withSize(.init(width: 200, height: 200))
        bindTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "warning", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }
            player.numberOfLoops = 4
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func bindTitle() {
        PlanATripViewController.viewModel.distance.subscribe { [weak self] result in
            if let res = result.element {
                if let r = res {
                    self?.title.text = String(format: "%.1f m", r)
                }
            }
        }.disposed(by: disposeBag)
    }
    
}




