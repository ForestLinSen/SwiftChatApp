//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 22/12/2021.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelSearch))
        view.backgroundColor = .white

    }
    
    @objc private func didCancelSearch(){
        dismiss(animated: true)
    }
    



}
