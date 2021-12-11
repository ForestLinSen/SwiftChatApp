//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 8/12/2021.
//

import UIKit
import PhotosUI

class RegisterViewController: UIViewController{
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "person")
        
        return imageView
    }()
    
    let firstNameField: UITextField = {
        let firstNameField = UITextField()
        firstNameField.placeholder = "First name"
        firstNameField.layer.borderWidth = 1
        firstNameField.layer.borderColor = UIColor.lightGray.cgColor
        firstNameField.layer.cornerRadius = 12
        
        firstNameField.returnKeyType = .continue
        firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: firstNameField.frame.size.height))
        firstNameField.leftViewMode = .always
        
        return firstNameField
    }()
    
    let lastNameField: UITextField = {
        let lastNameField = UITextField()
        lastNameField.placeholder = "Last name"
        lastNameField.layer.borderColor = UIColor.lightGray.cgColor
        lastNameField.layer.borderWidth = 1
        lastNameField.layer.cornerRadius = 12
        
        lastNameField.returnKeyType = .continue
        lastNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: lastNameField.frame.size.height))
        lastNameField.leftViewMode = .always
        
        
        return lastNameField
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
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)

    }
    
    @objc private func didTapChangeProfilePic(){
        print("Profile change button")
        presentPhotoActionSheet()
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = view.frame.size.width / 5
        scrollView.frame = view.bounds
        imageView.frame = CGRect(x: (scrollView.frame.size.width - size) / 2, y: 40, width: size , height: size)
        
        firstNameField.frame = CGRect(x: 30, y: imageView.frame.origin.y + imageView.frame.size.height + 40,
                                  width: scrollView.frame.size.width - 60, height: 52)
        
        lastNameField.frame = CGRect(x: 30, y: firstNameField.frame.origin.y + firstNameField.frame.size.height + 15,
                                  width: scrollView.frame.size.width - 60, height: 52)
        
        emailField.frame = CGRect(x: 30, y: lastNameField.frame.origin.y + lastNameField.frame.size.height + 15,
                                  width: scrollView.frame.size.width - 60, height: 52)
        
        passwordField.frame = CGRect(x: 30, y: emailField.frame.origin.y + emailField.frame.size.height + 15,
                                     width: scrollView.frame.size.width - 60, height: 52)
        
        registerButton.frame = CGRect(x: 30, y: passwordField.frame.origin.y + passwordField.frame.size.height + 15,
                                      width: scrollView.frame.size.width - 60, height: 52)
        
        
        
    }
    

    
    
    @objc private func registerButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text,
              !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count > 6 else{
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

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
    }
    
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present camera
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default){[weak self] _ in
            self?.presentCamera()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default){[weak self] _ in
            self?.presentPhotoPicker()
        })
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    // PHPPicker Tutorial: https://www.biteinteractive.com/picking-a-photo-in-ios-14/
    func presentPhotoPicker(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
