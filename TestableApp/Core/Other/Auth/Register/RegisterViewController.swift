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

protocol RegisterViewControllerInterface: AnyObject {
    
}

final class RegisterViewController: UIViewController, RegisterViewControllerInterface {
    
    //MARK: Def
    var viewModel = RegisterViewModel()
    let disposeBag = DisposeBag()

    //MARK: UI
    private lazy var signInAnimation: AnimationView = {
        let ani = AnimationView()
        ani.animation = Animation.named("login")
        ani.loopMode = .playOnce
        ani.translatesAutoresizingMaskIntoConstraints = false
        ani.contentMode = .scaleAspectFit
        return ani
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
    
    private lazy var spinner: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .large)
        ind.frame = .init(x: 0, y: 0, width: 100, height: 100)
        ind.center = view.center
        return ind
    }()
    
    private lazy var fullNameField: UITextField = {
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
    
    private lazy var fullNameFieldText: UILabel = {
       let lbl = UILabel()
        lbl.text = "Full Name"
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
    
    private lazy var registerButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.layer.cornerRadius = 8
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = true
        btn.clipsToBounds = true
        return btn
    }()
    
    private var signStack: UIStackView!
    
    private lazy var termsBtn: UIButton = {
       let btn = UIButton()
        btn.setTitle("Terms & Policy", for: .normal)
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
        bindFields()
    }
    
    private func bindFields() {
        fullNameField.rx.text.orEmpty.bind(to: viewModel.fullName)
        signField.rx.text.orEmpty.bind(to: viewModel.email)
        passField.rx.text.orEmpty.bind(to: viewModel.pass)
        
        registerButton.rx.tap.do( onNext: { [unowned self] in
            self.fullNameField.resignFirstResponder()
            self.signField.resignFirstResponder()
            self.passField.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            
            viewModel.registerUser(fullName: viewModel.fullName.value, email: viewModel.email.value, pass: viewModel.pass.value) {result in
                switch result {
                case .success( _):
                    let vc = MainTabBarController()
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
        view.addSubview(fullNameFieldText)
        view.addSubview(termsBtn)
        view.addSubview(spinner)
        
        
        NSLayoutConstraint.activate([
            signInAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:  -100),
            signInAnimation.widthAnchor.constraint(equalToConstant: 300),
            signInAnimation.heightAnchor.constraint(equalToConstant: 300),
            
            signField.heightAnchor.constraint(equalToConstant: 45),
            passField.heightAnchor.constraint(equalToConstant: 45),
            registerButton.heightAnchor.constraint(equalToConstant: 45),
            fullNameField.heightAnchor.constraint(equalToConstant: 45),
            
            signFieldText.leadingAnchor.constraint(equalTo: signField.leadingAnchor, constant: 20),
            signFieldText.topAnchor.constraint(equalTo: signField.topAnchor, constant: -5),
            
            passFieldText.leadingAnchor.constraint(equalTo: passField.leadingAnchor, constant: 20),
            passFieldText.topAnchor.constraint(equalTo: passField.topAnchor, constant: -5),
            
            fullNameFieldText.leadingAnchor.constraint(equalTo: fullNameField.leadingAnchor, constant: 20),
            fullNameFieldText.topAnchor.constraint(equalTo: fullNameField.topAnchor, constant: -5),

            
            signStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200),
            
            
            termsBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            termsBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
        handleButtonGradients()
    }
}

//MARK: Funcs
extension RegisterViewController {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func handleButtonGradients() {
        registerButton.applyGradient(colours: [
            UIColor.main3,
            UIColor.main3Light])
    }
    
    private func prepareStacks() {
        //MailField-PassField-Buttons Stack
        signStack = .init(arrangedSubviews: [
            fullNameField,
            signField,
            passField,
            registerButton,
        ])
        signStack.axis = .vertical
        signStack.distribution = .fill
        signStack.spacing = 10
        signStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func throwAlert(message: String) {
        let alert = UIAlertController(title: "Try Again", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

}

