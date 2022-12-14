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
import LBTATools
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

protocol ThrowMessage {
    func throwMessage(title: String, _ message: String)
}

protocol SignInViewControllerInterface: AnyObject {
    func layoutSubviews()
    func prepareButtons()
    func prepareStacks()
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
    
    private lazy var spinner = UIActivityIndicatorView()
    
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
        field.placeholder = "Mail"
        return field
    }()
    
    private lazy var forgotTextField = IndentedTextField(placeholder: "Email", padding: 10, cornerRadius: 4, backgroundColor: .secondarySystemBackground, isSecureTextEntry: false)
    
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
        field.placeholder = "Password"
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
    
    private lazy var signInButton: MainButton = {
        let btn = MainButton(title: "Sign In", tintColor: .systemBackground)
        btn.backgroundColor = .main3
        return btn
    }()
    
    private lazy var registerInButton: UIButton = {
       let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(UIColor.main3, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        btn.layer.borderWidth = 1
        return btn
    }()
    
    private var signStack: UIStackView!
    
    private var tmpForgotView: UIView? = nil
    
    private lazy var forgotBtn: UIButton = {
       let btn = UIButton()
        btn.setTitle("Forgot Password?", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.addTarget(self, action: #selector(didTapForgot), for: .touchUpInside)
        return btn
    }()
    
    private lazy var googleSignInBtn: UIView = {
        let btn = UIView()
        let attirbutedLabel = UILabel(text: "Contiune with Google", font: .systemFont(ofSize: 15), textColor: .systemBlue, numberOfLines: 1)
        btn.layer.cornerRadius = 8
        let imhV = UIImageView(image: .init(named: "googlepng"), contentMode: .scaleAspectFit)
        btn.stack(btn.hstack(imhV.withWidth(25), attirbutedLabel, spacing: 10), alignment: .center)
        btn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setupGoogle)))
        btn.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        btn.layer.borderWidth = 1
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
        layoutSubviews()
        
        DispatchQueue.main.async {
            self.handleButtonGradients()
        }
        
        spinner = view.setupSpinner()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        signInAnimation.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        signInAnimation.pause()
    }
    
    internal func layoutSubviews() {
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
            googleSignInBtn.heightAnchor.constraint(equalToConstant: 45),
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func didTapForgot() {
        tmpForgotView?.removeFromSuperview()
        let bg = UIView(backgroundColor: .black.withAlphaComponent(0.2))
        bg.frame = view.frame
        bg.center = view.center
        bg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCloseResetField)))
        view.addSubview(bg)
        
        let container = UIView(backgroundColor: .systemBackground)
        container.frame = .init(x: 0, y: 0, width: 300, height: 150)
        container.center = view.center
        container.layer.cornerRadius = 8
        bg.addSubview(container)
        
        let resetBtn = UIButton(title: "Send Mail", titleColor: .systemBackground, font: .systemFont(ofSize: 17), backgroundColor: .main3, target: self, action: #selector(didTapSendForgot))
        resetBtn.layer.cornerRadius = 4
        
        container.hstack(
            container.stack(
                forgotTextField.withHeight(45),
                resetBtn.withHeight(45),
                spacing: 10
            ).withMargins(.allSides(20)),
            alignment: .center
        )
        
        tmpForgotView = bg
    }
    
    @objc func didTapCloseResetField() {
        tmpForgotView?.removeFromSuperview()
    }
    
    @objc func didTapSendForgot() {
        guard forgotTextField.text?.isEmpty == false else {return}
        viewModel.resetPassword(email: forgotTextField.text ?? "") { result in
            switch result {
            case .success(_):
                self.tmpForgotView?.removeFromSuperview()
            case .failure(let err):
                self.throwMessage(title: "Error", err.localizedDescription)
            }
        }
    }
    
    internal func prepareButtons() {
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
                    self.throwMessage(title: "Error", error.localizedDescription)
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
    
    func prepareStacks() {
        //MailField-PassField-Buttons Stack
        signStack = .init(arrangedSubviews: [
            signField,
            passField,
            signInButton,
            googleSignInBtn,
            UILabel(text: "or", font: .systemFont(ofSize: 11), textColor: .secondaryLabel, textAlignment: .center, numberOfLines: 1),
            registerInButton
        ])
        signStack.axis = .vertical
        signStack.distribution = .fill
        signStack.spacing = 10
        signStack.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension SignInViewController{
    
    func showTextInputPrompt(withMessage message: String,
                              completionBlock: @escaping ((Bool, String?) -> Void)) {
       let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
       let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
         completionBlock(false, nil)
       }
       weak var weakPrompt = prompt
       let okAction = UIAlertAction(title: "OK", style: .default) { _ in
         guard let text = weakPrompt?.textFields?.first?.text else { return }
         completionBlock(true, text)
       }
       prompt.addTextField(configurationHandler: nil)
       prompt.addAction(cancelAction)
       prompt.addAction(okAction)
       present(prompt, animated: true, completion: nil)
     }
    @objc func setupGoogle(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
              throwMessage(title: "Error", error.localizedDescription)
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

          // ...

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                  let authError = error as NSError
                  if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError
                      .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                      displayNameString += tmpFactorInfo.displayName ?? ""
                      displayNameString += " "
                    }
                    self.showTextInputPrompt(
                      withMessage: "Select factor to sign in\n\(displayNameString)",
                      completionBlock: { userPressedOK, displayName in
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                          if displayName == tmpFactorInfo.displayName {
                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                          }
                        }
                        PhoneAuthProvider.provider()
                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                             multiFactorSession: resolver
                                               .session) { verificationID, error in
                            if error != nil {
                              print(
                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                              )
                            } else {
                              self.showTextInputPrompt(
                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                completionBlock: { userPressedOK, verificationCode in
                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                    .credential(withVerificationID: verificationID!,
                                                verificationCode: verificationCode!)
                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                    .assertion(with: credential!)
                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                                    if error != nil {
                                      print(
                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                      )
                                    } else {
                                      self.navigationController?.popViewController(animated: true)
                                    }
                                  }
                                }
                              )
                            }
                          }
                      }
                    )
                  } else {
                      self.throwMessage(title: "Error", error.localizedDescription)
                    return
                  }
                  // ...
                  return
                }
                // User is signed in
                // ...
                let data = ["mail": authResult?.user.email, "fullName": authResult?.user.displayName] as [String: Any]
                Firestore.firestore().collection("users").document(authResult?.user.uid ?? "").setData(data) { err in
                    guard err == nil else {
                        print("burada hata")
                        return
                    }
                    AuthManager.shared.fetchUser { _ in}
                    let vc = UINavigationController(rootViewController: HomeViewController())
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                    print("Sucessfully login in")

                }
                
            }
        }
    }
}

extension SignInViewController: ThrowMessage {
    func throwMessage(title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
}
