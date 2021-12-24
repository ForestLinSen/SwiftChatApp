//
//  DabaBaseManager.swift
//  ChatApp
//
//  Created by Sen Lin on 12/12/2021.
//

import Foundation
import FirebaseDatabase
import CoreMedia

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(email: String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}


// MARK: - Account management
extension DatabaseManager{
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)){
        
        database.child(email).observeSingleEvent(of: .value) { snapShot in
            guard snapShot.exists() else{
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping ((Bool) -> Void)){

        self.database.child(user.safeEmail).setValue(["firstName": user.firstName,
                                                      "lastName": user.lastName]) { error, reference in
            guard error == nil else{
                print("Debug: failed to insert the user")
                completion(false)
                return
            }
            
            completion(true)
        }

    }
}

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
    
    //let profilePictureUrl: String
}
