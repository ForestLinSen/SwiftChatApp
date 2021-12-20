//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 14/12/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn


class ProfileViewController: UIViewController, UITableViewDataSource{

    let data = ["Log Out"]
    
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .link
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
    }
}

extension ProfileViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = data[indexPath.row]
        content.textProperties.alignment = .center
        content.textProperties.color = .red
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "Confirm",
                                            message: "Do you want to log out your account?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else{ return }
            
            // Log out facebook
            FBSDKLoginKit.LoginManager().logOut()
            GIDSignIn.sharedInstance.signOut()
            
            do{
                try FirebaseAuth.Auth.auth().signOut()
                print("Debug: the current user has signed out")
                
                let vc = LoginViewController()
                let nv = UINavigationController(rootViewController: vc)
                nv.modalPresentationStyle = .fullScreen
                strongSelf.present(nv, animated: true, completion: nil)
            }
            
            catch{
               print("Debug: an error occuring while signing out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
}
