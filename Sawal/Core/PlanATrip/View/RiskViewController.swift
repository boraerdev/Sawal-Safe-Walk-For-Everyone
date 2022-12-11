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
import Lottie

final class RiskView: UIViewController {
    
    //MARK: Def
    var player: AVAudioPlayer?
    let disposeBag = DisposeBag()
    
    //MARK: UI
    private lazy var warningAnimation: AnimationView = {
        let ani = AnimationView()
        ani.animation = Animation.named("warning")
        ani.loopMode = .loop
        ani.translatesAutoresizingMaskIntoConstraints = false
        ani.contentMode = .scaleAspectFit
        return ani
    }()
    
    private lazy var warnLbl = UILabel(text: "Please be careful, the distance between you and the risk:", font: .boldSystemFont(ofSize: 22),textColor: .label, textAlignment: .center, numberOfLines: 0)
    
    private lazy var meter = UILabel(text: "Test",font: .systemFont(ofSize: 34), textColor: .secondaryLabel)

    //MARK: Core
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        warnLbl.withWidth(300)
        self.navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        warningAnimation.withSize(.init(width: 250, height: 250))
        warningAnimation.play()
        playSound()
        bindTitle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
        warningAnimation.stop()
        meter.removeFromSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        view.hstack(
            view.stack(
                warningAnimation,
                warnLbl,
                meter,
                spacing: 10,
                alignment: .center),
            alignment: .center)
    }
    
}

//MARK: Funcs
extension RiskView {
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "warning", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.numberOfLoops = 10
            player.play()
            bindTitle()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func bindTitle() {
        PlanATripViewModel.shared.distance.subscribe { [weak self] result in
            if let res = result.element {
                if let r = res {
                    self?.meter.text = String(format: "%.1f m", r)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    @objc func didTapClose() {
        navigationController?.popViewController(animated: true)
    }

}




