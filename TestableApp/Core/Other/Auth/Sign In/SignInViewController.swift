//
//  SignInViewController.swift
//  TestableApp
//
//  Created by Bora Erdem on 2.10.2022.
//

import UIKit
import Lottie

final class SignInViewController: UIViewController {

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
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var registerInButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.layer.cornerRadius = 8
        btn.setTitleColor(.systemBlue, for: .normal)
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
        prepareStacks()
        prepareButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signInAnimation.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        signInAnimation.pause()
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
    
    private func prepareButtons() {
        registerInButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(signInAnimation)
        view.addSubview(signStack)
        view.addSubview(signFieldText)
        view.addSubview(passFieldText)
        view.addSubview(forgotBtn)
        
        
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
        
    }
    
}


//MARK: Objc
extension SignInViewController {
    @objc func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Register"
        navigationController?.pushViewController(vc, animated: true)
    }
}
