//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 8/12/2021.
//

import UIKit
import FirebaseAuth

// Command + shift + O

class LoginViewController: UIViewController {
    
    // container
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = .white
        
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.text = "joe@aq.com"
        
        // padding
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: field.frame.size.height))
        field.leftViewMode = .always
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.text = "12345678"
        
        // padding
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: field.frame.size.height))
        field.leftViewMode = .always
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        navigationController?.view.clipsToBounds = true
        
        
        navigationController?.navigationBar.tintColor = .white
        
        title = "Log In"
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        
        scrollView.addSubview(imageView)
        scrollView.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        
        // https://stackoverflow.com/questions/56556254/in-ios13-the-status-bar-background-colour-is-different-from-the-navigation-bar-i
        let navBarAppearance = UINavigationBarAppearance()
        //navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                .font: UIFont.systemFont(ofSize: 22, weight: .semibold)]
        //navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .systemBlue
        //navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        imageView.center = CGPoint(x: view.frame.size.width/2-50,
        //                                   y: view.frame.size.height/2-50)
        //        imageView.frame.size.width = 100
        //        imageView.frame.size.height = 100
        
        scrollView.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y,
                                  width:  view.frame.size.width, height: view.frame.size.height)
        
        let size = scrollView.frame.size.width / 5
        imageView.frame = CGRect(x: (scrollView.frame.size.width - size)/2, y: 40, width: size, height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.frame.size.height + imageView.frame.origin.y + 45,
                                  width: scrollView.frame.size.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.frame.size.height + emailField.frame.origin.y + 15,
                                     width: scrollView.frame.size.width - 60, height: 52)
        
        loginButton.frame = CGRect(x: 30, y: passwordField.frame.size.height + passwordField.frame.origin.y + 15,
                                   width: scrollView.frame.size.width - 60 , height: 52)
        
        
        
        
    }
    
    @objc private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty,
              password.count >= 6 else{
                  alterUserLoginError()
                  return
              }
        
        print("Debug: email and password are ok")
        
        //Firbase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard error == nil else{
                print("Debug: log in error")
                return
            }
            
            print("Debug: login user: \(authResult?.user)")
            
            let vc = ConversationViewController()
            let nv = UINavigationController(rootViewController: vc)
            nv.modalPresentationStyle = .fullScreen
            self.present(nv, animated: true, completion: nil)
            
            
        }
    }
    
    func alterUserLoginError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all information to log in.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}


// Swift // // 将下列代码添加到文件的头文件中，例如：在 ViewController.swift 中导入 FBSDKLoginKit // 将下列代码添加到正文类 ViewController：UIViewController { override func viewDidLoad() { super.viewDidLoad() let loginButton = FBLoginButton() loginButton.center = view.center view.addSubview(loginButton) } }



extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField == emailField){
            passwordField.becomeFirstResponder()
        }
        
        if(textField == passwordField){
            loginButtonTapped()
        }
        
        return true
    }
}
