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
    public func uploadMessage(safeEmail: String, message: Message, otherUserEmail: String){
        
        database.child("\(safeEmail)/conversation/\(otherUserEmail)").observeSingleEvent(of: .value) {[weak self] snapShot in
            // all the messages
            //var messages: [[String: String]]
            
            // new messages
            let sendMessage: [String: String] = [
                "content": message.message,
                "date": message.dateString
            ]
            
            var uploadData: [String: Any]

            
            if !snapShot.exists(){
                let newMessage : [String : Any] = [
                    "id": message.messageId,
                    "latest_message" : sendMessage,
                    "messages": [sendMessage],
                    "other_user_email": message.otherUserId]
                print("Debug: No conversation list exist. Create a new one")
                uploadData = newMessage
            }else{
                guard let data = snapShot.value else{
                    print("Debug: failed to get user message data \(snapShot.value ?? "")")
                    return
                }
                
                guard var fetchData = data as? [String : Any],
                      var messageCollection = fetchData["messages"] as? [[String: String]] else{
                    return
                }
                
                messageCollection.append(sendMessage)
                
                fetchData["messages"] = messageCollection
                uploadData = fetchData
            }
            
            self?.database.child(safeEmail).child("conversation/\(otherUserEmail)").setValue(uploadData) { error, _ in
                guard error == nil else {
                    print("Debug: Failed to upload message \(error!.localizedDescription)")
                    return
                }
                
            }
            
        }
    }
    
}
    
    /// Fetch messages from the database
//    public func fetchMessages(userEmail: String, otherUserEmail: String,
//                              completion: @escaping (Result<[[String: Any]], Error>) -> Void){
//        database.child(userEmail).child("conversation").observeSingleEvent(of: .value) { snapShot in
//            guard let value = snapShot.value else {
//                print("Debug: failed to fetch messages from the database")
//                completion(.failure(DataBaseManagerError.fetchMessagesError))
//                return
//            }
            
//            if let message = value as? [[String: Any]]{
//                let conversationCollection = message.compactMap {
//                    if let latestMessage = $0["latest_message"] as? [String: String]{
//                        Conversation(id: "const", otherUserName: $0[], otherUserEmail: <#String#>, latestMessage: <#LatestMessage#>
//                    }
//
//                }
//            }
            
            
//            if let message = value as? [[String: Any]]{
//
//                if let id = message["id"] as? String,
//                   let latestMessage = message["latest_message"] as? [String: String],
//                   let sentDate = latestMessage["date"] ,
//                   let content = latestMessage["content"] ,
//                   let otherUserId = message["other_user_email"] as? String{
//
//                    let newMessage = Message(sender: self?.selfSender as! SenderType,
//                                             messageId: id,
//                                             sentDate: Date(),
//                                             otherUserId: otherUserId,
//                                             kind: .text(content))
//
//                completion(.success(message))
//            }else{
//                print("Debug: Cannot convert data to messages collection \(value)")
//                completion(.failure(DataBaseManagerError.fetchMessagesError))
//            }
//        }
//    }
        


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
