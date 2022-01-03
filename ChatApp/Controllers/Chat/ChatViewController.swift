//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 20/12/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType{
    var senderId: String
    var displayName: String
    var photoURL: String
}


class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    // TODO: selfSender and the targetSender
    private let selfSender = Sender(senderId: "1", displayName: "Mu", photoURL: "")
    
    private let safeEmail: String = {
        // safe email
        guard let email = UserDefaults.standard.string(forKey: "user_email") else {
            print("Debug: cannot get useDefaults user email")
            return ""
        }
        return DatabaseManager.safeEmail(email: email)
    }()
    
    private let otherUserEmail: String
    private let otherUserName: String
    
    init(otherUserEmail: String, otherUserName: String = "Name: Foo"){
        self.otherUserEmail = otherUserEmail
        self.otherUserName = otherUserName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender,
                                messageId: "2",
                                sentDate: Date(), otherUserId: "Dummy Id",
                                kind: .text("Hello world")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "2",
                                sentDate: Date(), otherUserId: "Dummy Id",
                                kind: .text("Hello world Hello world Hello world")))
        
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        self.messageInputBar.delegate = self
        
        DatabaseManager.shared.fetchMessages(userEmail: self.safeEmail, otherUserEmail: self.otherUserEmail) {[weak self] result in
            switch result{
            case .failure(let _):
                print("Debug: cannot fetch user messages")
            case .success(let conversation):
                let fetchedMessages = conversation.messages
                for message in fetchedMessages {
                    self?.messages.append(Message(sender: self?.selfSender as! SenderType, messageId: "", sentDate: Date(), otherUserId: "", kind: .text(message.text)))
                }
                
                self?.messagesCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        return self.selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print("Debug: user input \(text)")
        // Upload the text to the database
        // Database design:

        let date = Date()
        let calendar = Calendar.current
        let time = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                           from: date)
        
        guard let year = time.year, let month = time.month,
              let day = time.day, let hour = time.hour, let minute = time.minute, let second = time.second else{
                  print("Debug: cannot convert time \(time)")
                  return
              }
        
        let messageId = "conversation_\(safeEmail)_to_\(self.otherUserEmail)_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)"
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), otherUserId: self.otherUserEmail, kind: .text(text))
        
        DatabaseManager.shared.uploadMessage(safeEmail: safeEmail,
                                             message: message,
                                             otherUserEmail: self.otherUserEmail, otherUserName: otherUserName)
    }
}
