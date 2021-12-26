//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 22/12/2021.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    private var users = [[String: String]]()
    private var searchResults = [[String: String]]()
    private var isFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelSearch))
        view.backgroundColor = .white
        
        searchBar.becomeFirstResponder()
        
        view.addSubview(tableView)

    }
    
    @objc private func didCancelSearch(){
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }

}

extension NewConversationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard !(searchBar.text?.isEmpty ?? true) else { return }
        
        if(!isFetched){
            print("Debug: begin to fetch users")
            DatabaseManager.shared.fetchUsers {[weak self] result in
                switch result{
                case .failure(let error):
                    print("Debug: cannot fetch users from the database")
                case .success(let usersCollection):
                    self?.users = usersCollection
                    self?.isFetched = true
                    
                    self?.filterUser(query: searchBar.text ?? "")
                }
            }
        }else{
            filterUser(query: searchBar.text ?? "")
        }
    }
    
    func filterUser(query: String){
        self.searchResults = self.users.filter{
            guard let name = $0["name"]?.lowercased() else { return false}
            return name.contains(query)
        }
        
        self.updateUI()
    }
    
    func updateUI(){
        self.tableView.reloadData()
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = searchResults[indexPath.row]["name"]
        
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
