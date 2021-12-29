//
//  Chatuser.swift
//  ChatApp
//
//  Created by Sen Lin on 29/12/2021.
//

import Foundation

struct ChatAppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureName: String{
        return "\(safeEmail)_profile_picture.png"
    }

}
