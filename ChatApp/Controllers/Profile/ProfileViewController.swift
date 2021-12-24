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
import SDWebImage


class ProfileViewController: UIViewController, UITableViewDataSource{

    let data = ["Log Out"]
    
    @IBOutlet var tableview: UITableView!
    


    
    override func viewDidLoad(){
        super.viewDidLoad()
//        view.backgroundColor = .link
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                             .font: UIFont.systemFont(ofSize: 22, weight: .semibold) ]
        navAppearance.backgroundColor = .systemBlue
        
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.tableHeaderView = createTableHeader()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    func createTableHeader() -> UIView?{
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                        width: view.frame.size.width,
                                        height: 300))
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.frame.size.width - 150 )/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
//        imageView.image = UIImage(systemName: "person.crop.rectangle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        
        headerView.backgroundColor = .systemBlue
//        tableview.addSubview(headerView)
        headerView.addSubview(imageView)
        
        guard let email = UserDefaults.standard.string(forKey: "user_email") else{
            
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = "images/\(safeEmail)_profile_picture.png"
        
        print("Debug: profile image file name \(fileName)")
        
        StorageManager.shared.getProfileImage(path: fileName) { url in
            
            guard let imageUrl = URL(string: url) else { return }
            
            imageView.sd_setImage(with: imageUrl, completed: nil)
        }
        
        return headerView
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
