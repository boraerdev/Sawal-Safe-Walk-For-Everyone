//
//  MapSearchViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 9.10.2022.
//

import UIKit
import LBTATools
import MapKit
import RxSwift
import RxCocoa
import AVFAudio
import Speech

final class MapSearchViewController: LBTAListController<MapSearchCell, MKMapItem> {
    
    //MARF: Def
    var selectionHandler: ((MKMapItem)->())?
    var prepareCurrentLocationForSearch: (()->())?
    var navBarHeight: CGFloat = 65
    var searchText: BehaviorRelay<String> = .init(value: "")
    let disposeBag = DisposeBag()
    
    //Voice search
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var detectedLabel: String = ""
    var micView: UIView? = nil
    let micStatusImg = UIImageView(image: .init(systemName: "mic.fill"))

    
    //MARK: UI
    private lazy var searchField = SearchTextField(placeholder: "Search...", padding: 10)
    
    private lazy var currentLocationBtn: MainButton = {
       let btn = MainButton(title: "Current Location", imgName: "circle.circle")
        btn.addTarget(self, action: #selector(didTapCurrentLocation), for: .touchUpInside)
        return btn
    }()

    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        performLocalSearch()
        prepareNavBar()
        prepareMainView()
        view.handleSafeAreaBlurs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
}


//MARK: Funcs
extension MapSearchViewController {
    
    //For  voice search
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        node.removeTap(onBus: 1)
        let recordingFormat = node.outputFormat(forBus: 1)
        node.installTap(onBus: 1, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let err {
            print(err.localizedDescription)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            print("myrecognizer has not initiliazied")
            return
        }
        
        if !myRecognizer.isAvailable {
            print("my recognizer has been already in usage")
            return
        }
        
        //Add mic view to center of main view
        handleSpeechView()
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, err in
            guard err == nil, let result = result else {return}
            let bestString =  result.bestTranscription.formattedString
            self.detectedLabel = bestString
            self.searchField.text = bestString
            self.searchText.accept(bestString)
            
            for segment in result.bestTranscription.segments {
                let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
            }
        })
    }
    
    private func handleSpeechView() {
        micView?.removeFromSuperview()
        
        //Dark Bg
        let bg = UIView(backgroundColor: .black.withAlphaComponent(0.2))
        bg.frame = view.frame
        bg.center = view.center
        view.addSubview(bg)

        //Mic View
        let micField = UIView(backgroundColor: .systemBackground)
        micField.frame = .init(x: 0, y: 0, width: 200, height: 200)
        micField.center = view.center
        bg.addSubview(micField)
        
        micField.layer.cornerRadius = 8
        micStatusImg.contentMode = .scaleAspectFit
        micStatusImg.tintColor = .main3
        
        let btn = UIButton(title: "Stop", titleColor: .label, font: .systemFont(ofSize: 15), backgroundColor: .secondarySystemBackground, target: self, action: #selector(didTapStopRecord))
        btn.layer.cornerRadius = 4
        
        micField.stack(micStatusImg, btn)
            .withMargins(.allSides(12))
        micView = bg
    }
    
    private func prepareMainView() {
        collectionView.verticalScrollIndicatorInsets = .init(top: navBarHeight, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = .systemBackground
        
        if (prepareCurrentLocationForSearch == nil) {
            searchField.becomeFirstResponder()
        }
        
        searchField.rx.text.orEmpty
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(to: searchText)
            .disposed(by: disposeBag)
    }
    
    private func performLocalSearch() {
        let request = MKLocalSearch.Request()
        var search: MKLocalSearch!
        searchText.subscribe { result in
            request.naturalLanguageQuery = result.element
            search = MKLocalSearch(request: request)
            search.start { [weak self] resp, err in
                guard err == nil else {return}
                self?.items = resp?.mapItems ?? []
            }
        }.disposed(by: disposeBag)
    }
    
    private func prepareNavBar() {
        let navBar = UIView(backgroundColor: .systemBackground)
        view.addSubview(navBar)

        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -navBarHeight, right: 0))
        
        let containver = UIView(backgroundColor: .clear)
        navBar.addSubview(containver)
        containver.fillSuperviewSafeAreaLayoutGuide()
        
        let backBtn = UIButton(image: .init(systemName: "chevron.backward")!, tintColor: .main3, target: self, action: #selector(didTapBack))
        
        let micBtn = UIButton(image: .init(systemName: "mic.fill")!, tintColor: .main3, target: self, action: #selector(didTapMic))
        
        setupCurLocBtn()
        containver.hstack(
            backBtn.withWidth(25),
            searchField.withHeight(45),
            micBtn.withWidth(25),
            spacing: 10).withMargins(.init(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    func setupCurLocBtn() {
        guard prepareCurrentLocationForSearch != nil else {return}
        view.addSubview(currentLocationBtn)
        currentLocationBtn.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 20, bottom: 20, right: 20))
        currentLocationBtn.withHeight(45)
    }
    
    
}

//MARK: Objc
extension MapSearchViewController {
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapMic() {
        recordAndRecognizeSpeech()
    }
    
    @objc func didTapCurrentLocation() {
        prepareCurrentLocationForSearch?()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapStopRecord() {
        self.audioEngine.stop()
        self.request.endAudio()
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
        micView?.removeFromSuperview()
        self.searchField.text = detectedLabel
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: navBarHeight, left: 0, bottom: 0, right: 0)
    }
}
