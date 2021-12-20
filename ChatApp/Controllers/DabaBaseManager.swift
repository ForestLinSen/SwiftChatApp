//
//  DabaBaseManager.swift
//  ChatApp
//
//  Created by Sen Lin on 12/12/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
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
    public func insertUser(with user: ChatAppUser){
        print("Debug: safe email address \(user.safeEmail)")
        self.database.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ])

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
    
    //let profilePictureUrl: String
}
    
//    public func test(){
//        print("Debug: TEST DATABASE")
//        database.child("foo").setValue(["something": "yess"])
//        database.child("bar").setValue(["handler": "yess"]) { error, reference in
//            guard error == nil else{
//                print("Debug: Error writing in database\(error?.localizedDescription)")
//                return
//            }
//
//            print("Debug: success \(reference)")
//        }
//    }

