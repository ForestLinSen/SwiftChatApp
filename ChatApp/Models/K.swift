//
//  K.swift
//  ChatApp
//
//  Created by Sen Lin on 8/1/2022.
//

import Foundation

struct K{
    static let currentUserEmail: String = {
        guard let userEmail = UserDefaults.standard.string(forKey: "user_email") else{
            return ""
        }
        return userEmail
    }()
    
    static let currentUserSafeEmail: String = {
        let safeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        return safeEmail
    }()
    
}
