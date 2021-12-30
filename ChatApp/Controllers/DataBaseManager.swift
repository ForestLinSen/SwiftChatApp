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

// MARK: - Upload or Fetch Messages from the Database
extension DatabaseManager{
    // Path: safeEmail -> conversations (array)
    // Data structure: [conversationID: String, content: String, date: Date(), senderEmail: String]
    // id: conversation_email1_email2_date
    public func uploadMessage(safeEmail: String, message: Message){
        
        database.child(safeEmail).child("conversation").observeSingleEvent(of: .value) {[weak self] snapShot in
            // if conversation doesn't exist, then create one
            var conversation: [[String: Any]]
            
            let newMessage : [String : Any] = [
                "id": message.messageId,
                "latest_message" :
                    [
                        "content": message.message,
                        "date": message.dateString
                    ],
                "other_user_email": message.otherUserId]
            
            if !snapShot.exists(){
                print("Debug: No conversation list exist. Create a new one")
                conversation = [newMessage]
            }else{
                guard let data = snapShot.value else{
                    print("Debug: failed to get user message data \(snapShot.value ?? "")")
                    return
                }
                
                print("Debug: fetch conversation data: \(data)")
                
                conversation = data as? [[String : Any]] ?? [[:]]
                conversation.append(newMessage)
            }
            
            self?.database.child(safeEmail).child("conversation").setValue(conversation) { error, _ in
                guard error == nil else {
                    print("Debug: Failed to upload message \(error!.localizedDescription)")
                    return
                }
                
            }
            
        }
    }
    
    /// Fetch messages from the database
    public func fetchMessages(userEmail: String, otherUserEmail: String,
                              completion: @escaping (Result<[[String: Any]], Error>) -> Void){
        database.child(userEmail).child("conversation").observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value else {
                print("Debug: failed to fetch messages from the database")
                completion(.failure(DataBaseManagerError.fetchMessagesError))
                return
            }
            
            if let messages = value as? [[String: Any]]{
                completion(.success(messages))
            }else{
                print("Debug: Cannot convert data to messages collection \(value)")
                completion(.failure(DataBaseManagerError.fetchMessagesError))
            }
        }
    }
}


// MARK: - Search Users
extension DatabaseManager{
    public func fetchUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        self.database.child("users").observeSingleEvent(of: .value) { snapShot in
            guard let result = snapShot.value as? [[String: String]] else{
                print("Debug: cannot fetch users")
                completion(.failure(FetchError.failedToFetchUsers))
                return
            }
            
            //print("Debug: successful getting users:  \(result)")
            completion(.success(result))
        }
    }
}

public enum FetchError: Error{
    case failedToFetchUsers
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
        }
        
        self.database.child("users").observeSingleEvent(of: .value) { snapShot in
            
            var usersCollection: [[String: String]]
            
            let newElement = [
                "name": user.firstName + " " + user.lastName,
                "email": user.safeEmail
            ]
            
            if var fetchCollection = snapShot.value as? [[String: String]] {
                // append to the existing array
                
                usersCollection = fetchCollection
                usersCollection.append(newElement)
            }else{
                
                // create a new array
                usersCollection = [
                    [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                ]
            }
            
            self.database.child("users").setValue(usersCollection) { error, reference in
                guard error == nil else{
                    print("Debug: cannot set the user collection \(error)")
                    return
                }
                
                completion(true)
            }
            
        }
        
    }
}


enum DataBaseManagerError: Error{
    case fetchMessagesError
}
