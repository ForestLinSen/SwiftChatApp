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
    private let otherUserId: String
    
    init(otherUserId: String){
        self.otherUserId = otherUserId
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
        
        // safe email
        guard let email = UserDefaults.standard.string(forKey: "user_email") else {
            print("Debug: cannot get useDefaults user email")
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        
        let message = Message(sender: selfSender, messageId: email, sentDate: Date(), otherUserId: self.otherUserId, kind: .text(text))
        
        DatabaseManager.shared.uploadMessage(safeEmail: safeEmail, message: message)
    }
}
