//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 8/12/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

// Command + shift + O

// Google Sign in : https://developers.google.com/identity/sign-in/ios/sign-in

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    // Google login
    let signInConfig = GIDConfiguration.init(clientID: "554575304460-5jg3ukppipppashb0pm1l3mqanguhpep.apps.googleusercontent.com")
    
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
        field.text = "123@qq.com"
        
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
    
    // FaceBook log in button
    let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    let googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
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
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        

        
        
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
        
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.frame.origin.y + loginButton.frame.size.height + 15,
                                           width: scrollView.frame.size.width - 60, height: 52)
        
        googleLoginButton.center = scrollView.center
        googleLoginButton.frame = CGRect(x: 30,
                                           y: facebookLoginButton.frame.origin.y + facebookLoginButton.frame.size.height + 15,
                                           width: scrollView.frame.size.width - 60, height: 52)
        
        
        
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
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard error == nil else{
                print("Debug: log in error")
                return
            }
            
    
//            let vc = ConversationViewController()
//            let nv = UINavigationController(rootViewController: vc)
//            nv.modalPresentationStyle = .fullScreen
//            self.present(nv, animated: true, completion: nil)
            
            UserDefaults.standard.set(email, forKey: "user_email")

            DatabaseManager.shared.fetchUserData(email: K.currentUserSafeEmail) { result in
                switch result{
                case .failure(_):
                    break
                case .success(let data):
                    guard let firstName = data["firstName"] as? String,
                          let lastName = data["lastName"] as? String else {
                              return
                          }
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "user_name")
                }
            }
            
            print("Debug: login user email \(UserDefaults.standard.string(forKey: "user_email"))")
            self?.navigationController?.dismiss(animated: true, completion: nil)
            
            
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
    
    // Google signin button
    @objc func googleSignIn() {
        
    self.spinner.show(in: self.view)
        
      GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in

        guard error == nil else { return }
          guard let user = user, error == nil else{
              print("Debug: Failed to log user with Google sign in: \(error?.localizedDescription)")
              return
          }
          
          guard let email = user.profile?.email,
                let firstName = user.profile?.givenName,
                let lastName = user.profile?.familyName else{
                    print("Debug: Failed to retrieve user profile with Google sign in")
                    return
                }
          
          let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
          
          DatabaseManager.shared.userExists(with: chatUser.safeEmail) { exist in
              if(!exist){
                  DatabaseManager.shared.insertUser(with: chatUser){success in
                      if(success){
                          // upload image
                          
                          if (user.profile!.hasImage){
                              guard let url = user.profile?.imageURL(withDimension: 200) else{
                                  print("Debug: cannot get Google profile image URL")
                                  return
                              }
                              
                              URLSession.shared.dataTask(with: url) { data, res, error in
                                  guard let data = data else { return }
                                  StorageManager.shared.uploadPictureToStorage(with: data, uploadType: .profileImages, fileName: chatUser.profilePictureName) { result in
                                      switch result {
                                      case .success(let profileUrl):
                                          UserDefaults.standard.set(profileUrl, forKey: "profile_picture")
                                          print("Debug: Google sign in profile image: \(profileUrl)")
                                      case .failure(let error):
                                          print("Debug: cannot get Google sign in profileUrl: \(error.localizedDescription)")
                                      
                                      }
                                  }
                              }.resume()

                          }
                          
                          
                      }
                  }
              }
              
              let authentication = user.authentication
              guard let idToken = authentication.idToken else{
                       print("Debug: Failed to get user token with Google sign in")
                       return
                   }
             let googleCredential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                  accessToken: authentication.accessToken)

              FirebaseAuth.Auth.auth().signIn(with: googleCredential) {[weak self] result, error in
                 guard let user = result?.user, error == nil else{
                     print("Debug: Failed to login user with Google sign in")
                     return
                 }
                  
                  DispatchQueue.main.async {
                      self?.spinner.dismiss(animated: true)
                  }
                  

                  UserDefaults.standard.set(email, forKey: "user_email")

                  DatabaseManager.shared.fetchUserData(email: K.currentUserSafeEmail) { result in
                      switch result{
                      case .failure(_):
                          break
                      case .success(let data):
                          guard let firstName = data["firstName"] as? String,
                                let lastName = data["lastName"] as? String else {
                                    return
                                }
                          
                          UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "user_name")
                      }
                  }
                  
                  
                  self?.navigationController?.dismiss(animated: true, completion: nil)
             }
          }
      }
    }
}

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

extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("Debug: Error getting token")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture,type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { connection, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Debug: Failed to make facebook graph request")
                return
            }
            
            //print("Debug: graph request result: \(result)")
            
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let picData = picture["data"] as? [String: Any],
                  let pictureUrl = picData["url"] as? String else{
                      print("Debug: failed to get email and name from facebook")
                      return
                  }

            
            DatabaseManager.shared.userExists(with: email) { exist in
                if(!exist){
                    
                    let fbUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: fbUser){success in
                        if(success){
                            // Upload image of FB
                            
                            guard let url = URL(string: pictureUrl) else { return }
                            
                            URLSession.shared.dataTask(with: url) { data, res, error in
                                guard let data = data else { return }
                                
                                StorageManager.shared.uploadPictureToStorage(with: data, uploadType: .profileImages, fileName: fbUser.profilePictureName) { result in
                                    switch result{
                                    case .success(let imageUrl):
                                        print("Debug : download url\(imageUrl)")
                                    case .failure(let error):
                                        print("Debug: failed to upload profile picture")
                                    }
                                }
                            }.resume()

                        }
                    }
                }
            }
            
            // Credential: 3rd party token
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                guard let strongSelf = self else{ return }
                
                guard authResult != nil, error == nil else{
                    if let error = error {
                        print("Debug: Error Loging with Facebook - \(error.localizedDescription)")
                    }
                    return
                }
                
                print("Debug: successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
    
}
