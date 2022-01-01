//
//  ViewController.swift
//  ChatApp
//
//  Created by 林森 on 3/11/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationViewController: UIViewController {
    
    //private var users = [[String: String]]()
    private var isFetched = false
    private let spinner = JGProgressHUD(style: .dark)
    private let conversationViewController = NewConversationViewController()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        self.navigationController?.navigationBar.backgroundColor = .systemBlue
        
        let navbarAppearance = UINavigationBarAppearance()
        navbarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                .font: UIFont.systemFont(ofSize: 22, weight: .semibold)]
        navbarAppearance.backgroundColor = .systemBlue
        
        self.navigationController?.navigationBar.scrollEdgeAppearance = navbarAppearance

        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.backButtonTitle = "All Chats"
        
        if(!isFetched){
            print("Debug: begin to fetch users")
            DatabaseManager.shared.fetchUsers {[weak self] result in
                switch result{
                case .failure(_):
                    print("Debug: cannot fetch users from the database")
                case .success(let usersCollection):
                    //self?.users = usersCollection
                    self?.isFetched = true
                    self?.spinner.dismiss(animated: true)
                    self?.conversationViewController.users = usersCollection
                }
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapNewChatItem))

    }
    
    @objc func didTapNewChatItem(){

        self.conversationViewController.completion = {[weak self] result in
            self?.createNewConversation(result: result)
        }
        
        let nav = UINavigationController(rootViewController: conversationViewController)
        present(nav, animated: true, completion: nil)
        
        if(!self.isFetched){
            spinner.show(in: nav.view)
        }

    }
    
    func createNewConversation(result: [String: String]){
        
        guard let otherUserEmail = result["email"], let otherUserName = result["name"] else{
            print("Debug: cannot get user email or user name")
            return
        }
        
        let vc = ChatViewController(otherUserEmail: otherUserEmail)
        vc.title = otherUserName
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func validateAuth(){
        if(FirebaseAuth.Auth.auth().currentUser == nil){
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }

}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ConversationTableViewCell else{
            return UITableViewCell()
        }
        
        cell.configure(with: <#T##String#>)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController(otherUserEmail: "Test@James")
        vc.title = "James Bond"
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
}
