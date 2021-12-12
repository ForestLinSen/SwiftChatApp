//
//  ViewController.swift
//  ChatApp
//
//  Created by 林森 on 3/11/2021.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        DatabaseManager.shared.test()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        validateAuth()
    }
    
    func validateAuth(){
        if(FirebaseAuth.Auth.auth().currentUser != nil){
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }


}

