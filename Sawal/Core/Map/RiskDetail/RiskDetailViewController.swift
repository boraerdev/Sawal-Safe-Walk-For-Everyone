//
//  RiskDetailViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 14.10.2022.
//

import UIKit
import Kingfisher
import CoreLocation
import MapKit
import LBTATools
import RxSwift
import RxCocoa

protocol RiskDetailViewControllerInterface: AnyObject {
    var post: Post! {get set}
}

final class RiskDetailViewController: UIViewController, RiskDetailViewControllerInterface {

    //MARK: Def
    var post: Post! = nil 
    let viewModel = RiskDetailViewModel()
    let disposeBag = DisposeBag()
    var time: CGFloat = 15
    var timer: Timer!
    
    //MARK: UI
    let desc = UILabel(text: "")
    let postImg = UIImageView(image: nil, contentMode: .scaleAspectFill)
    var dateLbl = UILabel(text: "", font: .systemFont(ofSize: 11), textColor: .secondaryLabel)
    let riskDegreeLbl = UILabel(text: "", font: .systemFont(ofSize: 11))
    let descLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .white)
    let mailLbl = UILabel(text: "", font: .systemFont(ofSize: 13), textColor: .secondaryLabel)
    let authorUserNameLbl = UILabel(text: "", font: .boldSystemFont(ofSize: 13), textColor: .white)
    let commentField = IndentedTextField(placeholder: "Comment", padding: 10, cornerRadius: 8, backgroundColor: .clear)
    let commentBtn = UIButton(image: .init(systemName: "text.bubble")!, tintColor: .secondaryLabel, target: self, action: #selector(didTapUploadComment))
    let goCommentsBtn = UIButton(title: " Comments ", titleColor: .secondaryLabel, font: .systemFont(ofSize: 17), backgroundColor: .clear, target: self, action: #selector(didTapGoComments))
    let settingsBtn = UIButton(image: .init(systemName: "ellipsis")!, tintColor: .secondaryLabel, target: self, action: #selector(didTapSettings))
    let progressBar = UIProgressView()
    
    
    private func prepareStacks() {
        
        view.stack(
            progressBar,
            postImg,
            view.hstack(
                commentField.withHeight(45),
                commentBtn,
                settingsBtn,
                spacing: 5).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10)),
            view.hstack(goCommentsBtn),
            spacing: 10)
        .withMargins(.init(top: 0, left: 0, bottom: 10, right: 0))
        .fillSuperviewSafeAreaLayoutGuide()
        
        
        let headContainer = UIView(backgroundColor: .clear)
        headContainer.withHeight(40)
        headContainer.hstack(
            headContainer.stack(
                authorUserNameLbl,
                mailLbl),
            headContainer.stack(
                riskDegreeLbl,
                dateLbl,
                alignment: .trailing),
            alignment: .center)
        
        postImg.stack(headContainer,UIView())
            .withMargins(.allSides(10))
        

    }
    
    private func handleBind() {
        commentField.rx.text.orEmpty.bind(to: viewModel.commentText).disposed(by: disposeBag)
    }
    
    private func getUserInfo() {
        UserService.shared.getUser(uid: post.authorUID) { [weak self] user in
            DispatchQueue.main.async {
                self?.authorUserNameLbl.text = user.fullName
                self?.mailLbl.text = user.mail
            }
        }
    }
    
    private func configureSomeUI() {
        commentBtn.withWidth(30)
        commentField.layer.borderColor = UIColor.secondaryLabel.cgColor
        commentField.layer.borderWidth = 1
        
        progressBar.backgroundColor = .secondaryLabel.withAlphaComponent(0.2)
        progressBar.tintColor = .secondaryLabel.withAlphaComponent(0.4)
        progressBar.progressViewStyle = .bar
        progressBar.progress = 1
        
        overrideUserInterfaceStyle = .dark
        UIApplication.shared.statusBarStyle = .lightContent
        
        goCommentsBtn.setImage(.init(systemName: "chevron.up")!, for: .normal)
        goCommentsBtn.tintColor = .secondaryLabel

    }
    
    private func configureData() {
        desc.text = post.description
        postImg.kf.setImage(with: URL(string: post.imageURL ?? ""))
        
        let cor = post.location
        let location = CLLocation(latitude: cor.latitude, longitude: cor.longitude)
        location.fetchLocationInfo { [weak self] locationInfo, error in
            self?.title = locationInfo?.name
        }
        
        riskDegreeLbl.text = post.riskDegree == 0 ? "Low Risk Area" : post.riskDegree == 1 ? "Medium Risk Area" : "High Risk Area"
        riskDegreeLbl.textColor = post.riskDegree == 0 ? .systemOrange : post.riskDegree == 1 ? .systemRed : .main2

        dateLbl.text = post.date.formatted(date: .abbreviated, time: .shortened)
        
        descLbl.text = post.description
        

    }
    
    func handleCloseKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
    }
    
}

//MARK: Core
extension RiskDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        handleBind()
        getUserInfo()
        configureSomeUI()
        prepareStacks()
        configureData()
        handleCloseKeyboard()
        viewModel.view = self
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(handleProgress), userInfo: nil, repeats: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        view.subviews.forEach { returned in
            returned.removeFromSuperview()
        }
    }
}

//MARK: Objc
extension RiskDetailViewController {
    
    @objc func handleProgress() {
        time -= 1
        progressBar.setProgress(Float(time) / 15, animated: true)
        if time <= 0 {
            timer.invalidate()
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func didTapUploadComment() {
        guard commentField.text != "" else {return}
        viewModel.uploadComment()
        commentField.text = ""
    }
    
    @objc func didTapGoComments() {
        let vc = PostCommentsViewController()
        vc.post = post
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    @objc func didTapSettings() {
        print("ok")
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        timer.invalidate()
    }
}
