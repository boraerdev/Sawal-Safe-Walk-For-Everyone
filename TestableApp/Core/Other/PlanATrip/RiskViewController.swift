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


final class RiskView: UIViewController {
    
    var player: AVAudioPlayer?
    private lazy var meter = UILabel(text: "Test",font: .systemFont(ofSize: 34), textColor: .secondaryLabel)
    let disposeBag = DisposeBag()
    let warningImage = UIImageView(image: .init(systemName: "exclamationmark.triangle"), contentMode: .scaleAspectFit)
    let warnLbl = UILabel(text: "Please be careful, the distance between you and the risk:", font: .boldSystemFont(ofSize: 22),textColor: .black, textAlignment: .center, numberOfLines: 0)
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        warnLbl.withWidth(300)

        view.hstack(
            view.stack(
                warningImage,
                warnLbl,
                meter,
                spacing: 10,
                alignment: .center),
            alignment: .center)
        warningImage.withSize(.init(width: 200, height: 200))
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
    }
    
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "warning", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.numberOfLoops = 10
            //TODO ram managment
            bindTitle()
            //player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func bindTitle() {
        PlanATripViewController.viewModel.distance.subscribe { [weak self] result in
            if let res = result.element {
                if let r = res {
//                    self?.meter.text = String(format: "%.1f m", r)
                }
            }
            
        }.disposed(by: disposeBag)
    }
}




