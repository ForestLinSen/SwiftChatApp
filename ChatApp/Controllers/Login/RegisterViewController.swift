//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 8/12/2021.
//

import UIKit

class RegisterViewController: UIViewController{
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        
        return imageView
    }()
    
    let emailField: UITextField = {
        let emailField = UITextField()
        emailField.placeholder = "Email address"
        emailField.layer.cornerRadius = 12
        emailField.layer.borderColor = UIColor.lightGray.cgColor
        emailField.layer.borderWidth = 1
        emailField.returnKeyType = .continue
        
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: emailField.frame.size.height))
        emailField.leftViewMode = .always
        
        return emailField
    }()
    
    let passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "Password..."
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.returnKeyType = .continue
        
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: passwordField.frame.size.height))
        passwordField.leftViewMode = .always
        
        
        return passwordField
    }()
    
    let registerButton: UIButton = {
        let registerButton = UIButton()
        registerButton.backgroundColor = .link
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 12
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

        
        return registerButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Register"
        view.backgroundColor = .red
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = view.frame.size.width / 5
        scrollView.frame = view.bounds
        imageView.frame = CGRect(x: (scrollView.frame.size.width - size) / 2, y: 40, width: size , height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.frame.origin.y + imageView.frame.size.height + 40,
                                  width: scrollView.frame.size.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.frame.origin.y + emailField.frame.size.height + 15,
                                     width: scrollView.frame.size.width - 60, height: 52)
        
        registerButton.frame = CGRect(x: 30, y: passwordField.frame.origin.y + passwordField.frame.size.height + 15,
                                      width: scrollView.frame.size.width - 60, height: 52)
        
    }
    
    @objc private func registerButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count > 6 else{
            alertUserRegister()
            return
        }
    }
    
    func alertUserRegister(){
        let alert = UIAlertController(title: "Woops", message: "Something is wrong with the information you provided", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}


extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == emailField){
            passwordField.becomeFirstResponder()
        }
        
        if(textField == passwordField){
            registerButtonTapped()
        }
        
        return true
    }
}
