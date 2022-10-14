//
//  SignInViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 2.10.2022.
//

import UIKit
import Lottie
import RxSwift
import RxCocoa

protocol SignInViewControllerInterface: AnyObject {
    
}

final class SignInViewController: UIViewController, SignInViewControllerInterface {
    
    //MARK: Def
    let disposeBag = DisposeBag()
    let viewModel = SignInViewModel()

    //MARK: UI
    private lazy var signInAnimation: AnimationView = {
        let ani = AnimationView()
        ani.animation = Animation.named("login")
        ani.loopMode = .playOnce
        ani.tintColor = .label
        ani.translatesAutoresizingMaskIntoConstraints = false
        ani.contentMode = .scaleAspectFit
        
        return ani
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.frame = .init(x: 0, y: 0, width: 100, height: 100)
        let bg = UIView()
        bg.backgroundColor = .secondarySystemBackground
        bg.layer.cornerRadius = 8
        bg.frame = ind.bounds
        ind.layer.insertSublayer(bg.layer, at: 0)
        ind.center = view.center
        return ind
    }()
    
    private lazy var signField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 8
        field.backgroundColor = .systemBackground
        field.layer.borderWidth = 1
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        field.leftViewMode = .always
        field.leftView = .init(frame: .init(x: 0, y: 0, width: 15, height: 0))
        //field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private lazy var signFieldText: UILabel = {
       let lbl = UILabel()
        lbl.text = "Mail"
        lbl.font = .systemFont(ofSize: 11)
        lbl.backgroundColor = .systemBackground
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var passField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 8
        field.backgroundColor = .systemBackground
        field.leftViewMode = .always
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.leftView = .init(frame: .init(x: 0, y: 0, width: 15, height: 0))
        //field.translatesAutoresizingMaskIntoConstraints = false
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        field.isSecureTextEntry = true
        return field
    }()
    
    private lazy var passFieldText: UILabel = {
       let lbl = UILabel()
        lbl.text = "Pass"
        lbl.font = .systemFont(ofSize: 11)
        lbl.backgroundColor = .systemBackground
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var signInButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Sign In", for: .normal)
        btn.layer.cornerRadius = 8
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.clipsToBounds = true
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private lazy var registerInButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(UIColor.main3, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var signStack: UIStackView!
    
    private lazy var forgotBtn: UIButton = {
       let btn = UIButton()
        btn.setTitle("Forgot Password?", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(.label, for: .normal)
        return btn
    }()
    
    //MARK: Core
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        viewModel.delegate = self
        
        prepareStacks()
        prepareButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signInAnimation.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        signInAnimation.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(signInAnimation)
        view.addSubview(signStack)
        view.addSubview(signFieldText)
        view.addSubview(passFieldText)
        view.addSubview(forgotBtn)
        view.addSubview(spinner)
        
        
        NSLayoutConstraint.activate([
            signInAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:  -100),
            signInAnimation.widthAnchor.constraint(equalToConstant: 300),
            signInAnimation.heightAnchor.constraint(equalToConstant: 300),
            
            signField.heightAnchor.constraint(equalToConstant: 45),
            passField.heightAnchor.constraint(equalToConstant: 45),
            registerInButton.heightAnchor.constraint(equalToConstant: 45),
            signInButton.heightAnchor.constraint(equalToConstant: 45),
            
            signFieldText.leadingAnchor.constraint(equalTo: signField.leadingAnchor, constant: 20),
            signFieldText.topAnchor.constraint(equalTo: signField.topAnchor, constant: -5),
            
            passFieldText.leadingAnchor.constraint(equalTo: passField.leadingAnchor, constant: 20),
            passFieldText.topAnchor.constraint(equalTo: passField.topAnchor, constant: -5),

            signStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200),
            
            forgotBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
        
        handleButtonGradients()
    }
}


//MARK: Objc
extension SignInViewController {

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func prepareButtons() {
        registerInButton.rx.tap.subscribe(onNext: { [unowned self] in
            navigationController?.pushViewController(RegisterViewController(), animated: true)
        }).disposed(by: disposeBag)
        
        signField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        passField.rx.text.orEmpty.bind(to: viewModel.pass).disposed(by: disposeBag)
        
        signInButton.rx.tap.do( onNext: { [unowned self] in
            self.signField.resignFirstResponder()
            self.passField.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            
            viewModel.signInUser(email: viewModel.email.value, pass: viewModel.pass.value) {result in
                switch result {
                case .success( _):
                    let vc = UINavigationController(rootViewController: HomeViewController())
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                case .failure(let error):
                    self.throwAlert(message: error.localizedDescription)
                }
            }
            
            viewModel.isLoading.subscribe { [weak self] result in
                result ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
            }
            .disposed(by: disposeBag)
            
        })
        .disposed(by: disposeBag)
        
    }
    
    private func handleButtonGradients(){
        signInButton.applyGradient(colours: [
            UIColor.main3,
            UIColor.main3Light])
    }
    
    private func throwAlert(message: String) {
        let alert = UIAlertController(title: "Try Again", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func prepareStacks() {
        //MailField-PassField-Buttons Stack
        signStack = .init(arrangedSubviews: [
            signField,
            passField,
            signInButton,
            registerInButton
        ])
        signStack.axis = .vertical
        signStack.distribution = .fill
        signStack.spacing = 10
        signStack.translatesAutoresizingMaskIntoConstraints = false
    }
}
