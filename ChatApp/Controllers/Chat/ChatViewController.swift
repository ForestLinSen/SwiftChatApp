//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 20/12/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import PhotosUI

struct Sender: SenderType{
    var senderId: String
    var displayName: String
    var photoURL: String
}


class ChatViewController: MessagesViewController{
    
    private var messages = [Message]()
    
    // TODO: selfSender and the targetSender
    private let selfSender = Sender(senderId: K.currentUserSafeEmail,
                                    displayName: UserDefaults.standard.string(forKey: "user_name") ?? "",
                                    photoURL: "")
    
    private let safeEmail = K.currentUserSafeEmail
    
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
        
//        messages.append(Message(sender: selfSender,
//                                messageId: "2",
//                                sentDate: Date(), otherUserId: "Dummy Id",
//                                kind: .text("Hello world")))
//
//        messages.append(Message(sender: selfSender,
//                                messageId: "2",
//                                sentDate: Date(), otherUserId: "Dummy Id",
//                                kind: .text("Hello world Hello world Hello world")))
        
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        self.messageInputBar.delegate = self
        self.setupInputButton()
        
        DatabaseManager.shared.fetchMessages(userEmail: self.safeEmail, otherUserEmail: self.otherUserEmail) {[weak self] result in
            switch result{
            case .failure(_):
                print("Debug: cannot fetch user messages")
            case .success(let conversation):
                let fetchedMessages = conversation.messages
                self?.messages = [Message]()
                for message in fetchedMessages {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                    let date = dateFormatter.date(from: message.date)
    
                    // self?.selfSender as! SenderType
                    
                    //if message.senderEm
                    var sender: SenderType
                    
                    print("Debug: message senderEmail \(message.text)")
                    
                    if(message.senderEmail == self?.selfSender.senderId){
                        
                        sender = self?.selfSender as! SenderType
                        print("Debug: this message sender ID \(sender.senderId)")
                    }else{
                        
                        sender = Sender(senderId: message.senderEmail, displayName: self?.otherUserName ?? "", photoURL: "")
                    }

                    self?.messages.append(Message(sender: sender,
                                                  messageId: sender.senderId,
                                                  sentDate: date ?? Date(),
                                                  otherUserId: "",
                                                  kind: .text(message.text)))

                }
                
                self?.messagesCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.messageInputBar.inputTextView.becomeFirstResponder()
        
    }
    
    private func setupInputButton(){
        //let button = InputBarButtonItem(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach media", message: "What would you like attach", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
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
        
        print("Debug: current safe email \(safeEmail)")
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), otherUserId: self.otherUserEmail, kind: .text(text))
        
        DatabaseManager.shared.uploadMessage(safeEmail: safeEmail,
                                             message: message,
                                             otherUserEmail: self.otherUserEmail,
                                             otherUserName: otherUserName,
                                             senderEmail: safeEmail)
        
        DatabaseManager.shared.uploadMessage(safeEmail: self.otherUserEmail,
                                             message: message,
                                             otherUserEmail: safeEmail,
                                             otherUserName: selfSender.displayName,
                                             senderEmail: safeEmail)
    }
}


extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            //TODO: use the image data
            guard let result = results.first else{ return }
            let provider = result.itemProvider
            
            provider.loadObject(ofClass: UIImage.self) { imageMaybe, error in
                if let image = imageMaybe {
                    print("Debug: here is the image \(image)")
                }else{
                    print("Debug: cannot load the image user picked")
                }
            }
        }
        
    }
    
}
