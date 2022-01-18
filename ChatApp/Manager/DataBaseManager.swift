//
//  DabaBaseManager.swift
//  ChatApp
//
//  Created by Sen Lin on 12/12/2021.
//

import Foundation
import FirebaseDatabase
import CoreMedia
import AVFoundation
import MessageKit


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
    public func uploadMessage(safeEmail: String,
                              message: Message,
                              otherUserEmail: String,
                              otherUserName: String,
                              senderEmail: String,
                              type: TypeOfMessage = .text){
        
        database.child("\(safeEmail)/conversation/\(otherUserEmail)").observeSingleEvent(of: .value) {[weak self] snapShot in
            // all the messages
            //var messages: [[String: String]]
            
            // new messages
            let sendMessage: [String: String] = [
                "content": message.message,
                "date": message.dateString,
                "senderEmail": senderEmail,
                "type": type.rawValue
            ]
            
            var uploadData: [String: Any]

            
            if !snapShot.exists(){
                let newMessage : [String : Any] = [
                    "id": message.messageId,
                    "latest_message" : sendMessage,
                    "messages": [sendMessage],
                    "other_user_email": otherUserEmail,
                    "other_user_name": otherUserName]
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
                fetchData["latest_message"] = sendMessage
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
    
    public func fetchMessages(userEmail: String, otherUserEmail: String, completion: @escaping (Result<Conversation, Error>) -> Void){
        
        self.database.child("\(userEmail)/conversation/\(otherUserEmail)").observe(.value) { snapShot in
            
            print("Debug: debug value \(snapShot.value)")
            
            guard let data = snapShot.value as? [String: Any],
            let id = data["id"] as? String,
   
            let latestMessageDict = data["latest_message"] as? [String: String],
            let date =  latestMessageDict["date"],
            let content = latestMessageDict["content"],
            let otherUserName = data["other_user_name"] as? String,
            let otherUserEmail = data["other_user_email"] as? String,
            let messagesDict = data["messages"] as? [[String: String]] else{
                print("Debug: cannot fetch the conversation")
                completion(.failure(DataBaseManagerError.fetchMessagesError))
                return
            }
            
            let latestMessage = LatestMessage(date: date, text: content)
            
            let messages = messagesDict.compactMap {Messages(date: $0["date"] ?? "No date found",
                                                             text: $0["content"] ?? "",
                                                             mediaUrl: $0["content"] ?? "",
                                                             type: $0["type"] ?? TypeOfMessage.text.rawValue,
                                                             senderEmail: $0["senderEmail"] ?? "no sender email found")}
            
            let conversation = Conversation(id: id, otherUserName: otherUserName, otherUserEmail: otherUserEmail, latestMessage: latestMessage, messages: messages)
            
            completion(.success(conversation))
        }

    }
    
    public func fetchAllConversations(userEmail: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        self.database.child("\(userEmail)/conversation").observe(.value, with: { snapShot in
   
            //print("Debug: snapShot value: \(snapShot.value)")
            
            guard let allData = snapShot.children.allObjects as? [DataSnapshot] else {
                print("Debug: cannot get conversation data from firebase \(snapShot.children.allObjects)")
                completion(.failure(DataBaseManagerError.fetchMessagesError))
                return
            }
 
            let conversationCollection = allData.compactMap { data -> Conversation? in
                
                guard let dataElement = data.value as? [String: Any],
                    let id = dataElement["id"] as? String,
                      let otherUserName = dataElement["other_user_name"] as? String,
                      let otherUserEmail = dataElement["other_user_email"] as? String,
                      let latestMessage = dataElement["latest_message"] as? [String: String],
                      let content = latestMessage["content"],
                      let date = latestMessage["date"],
                      let messages = dataElement["messages"] as? [[String: String]] else {
                          completion(.failure(DataBaseManagerError.fetchMessagesError))
                          print("Debug: cannot fetch conversations - DatabaseManager")
                          return nil
                      }
                
                let messagesCollection = messages.compactMap{Messages(date: $0["date"] ?? "no date",
                                                                      text: $0["content"] ?? "no content",
                                                                      mediaUrl: $0["content"] ?? "no content",
                                                                      type: $0["type"] ?? TypeOfMessage.text.rawValue,
                                                                      senderEmail: $0["senderEmail"] ?? "no sender email found")}
                
                let conv = Conversation(id: id, otherUserName: otherUserName, otherUserEmail: otherUserEmail, latestMessage: LatestMessage(date: date, text: content), messages: messagesCollection)
                
                return conv
            }
            
            completion(.success(conversationCollection))
        })
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
    
    public func fetchUserData(email: String, completion: @escaping (Result<[String: Any], Error>) -> Void){
        self.database.child(email).getData { _, snapShot in
            guard let userData = snapShot.value as? [String: Any] else{
                print("Debug: Cannot get the user data ")
                completion(.failure(FetchError.failedToFetchUsers))
                return
            }
            
            completion(.success(userData))
            
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
