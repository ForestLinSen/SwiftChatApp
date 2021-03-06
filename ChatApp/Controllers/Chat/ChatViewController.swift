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
import SDWebImage
//import AVFoundation
import AVKit

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
        
        //        let dummyPhotoMessage = PhotoMessage(url: nil,
        //                                             image: UIImage(systemName: "plus"),
        //                                             placeholderImage: UIImage(systemName: "plus")!,
        //                                             size: CGSize(width: 200, height: 200))
        //
        //        messages.append(Message(sender: selfSender,
        //                                messageId: "2",
        //                                sentDate: Date(), otherUserId: "Dummy Id",
        //                                kind: .photo(dummyPhotoMessage)))
        
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        self.messagesCollectionView.messageCellDelegate = self
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
                    
                    if message.type == TypeOfMessage.photo.rawValue{
                        guard let mediaUrl = message.mediaUrl,
                              let url = URL(string: mediaUrl) else{
                                  return
                              }
                        
                        let media = PhotoMessage(url: url,
                                                 image: nil,
                                                 placeholderImage: UIImage(systemName: "rectangle.and.pencil.and.ellipsis")!,
                                                 size: CGSize(width: 200, height: 200))
                        
                        let message = Message(sender: sender,
                                              messageId: sender.senderId,
                                              sentDate: date ?? Date(),
                                              otherUserId: "",
                                              kind: .photo(media))
                        
                        self?.messages.append(message)
                        
                        self?.messagesCollectionView.reloadData()
                        
                    }else if message.type == TypeOfMessage.video.rawValue{
                        guard let mediaUrl = message.mediaUrl,
                              let url = URL(string: mediaUrl) else{
                                  return
                              }
                        
                        let media = PhotoMessage(url: url,
                                                 image: nil,
                                                 placeholderImage: UIImage(named: "VideoPlaceholder")!,
                                                 size: CGSize(width: 200, height: 200))
                        
                        let message = Message(sender: sender,
                                              messageId: dateFormatter.string(from: Date()),
                                              sentDate: date ?? Date(),
                                              otherUserId: "",
                                              kind: .video(media))
                        
                        self?.messages.append(message)
                        
                        self?.messagesCollectionView.reloadData()
                    }
                    
                    else{
                        let message = Message(sender: sender,
                                              messageId: sender.senderId,
                                              sentDate: date ?? Date(),
                                              otherUserId: "",
                                              kind: .text(message.text ?? ""))
                        
                        self?.messages.append(message)
                        self?.messagesCollectionView.reloadData()
                    }
                }
                
                //self?.messagesCollectionView.reloadData()
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
            self?.presentMediaPicker(type: .photo)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentMediaPicker(type: .video)
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentMediaPicker(type: TypeOfMessage){
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        
        switch type {
        case .photo:
            config.filter = .images
        case .video:
            config.filter = .videos
        default:
            break
        }
        
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind{
        case .photo(let mediaUrl):
            guard let url = mediaUrl.url else { return }
            imageView.sd_setImage(with: url, completed: nil)
            
        case .video(let mediaItem):
            
            guard let url = mediaItem.url else { return }
            
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: url)
            present(vc, animated: true, completion: nil)
            
        default:
            break
        }
    }
}

extension ChatViewController: MessageCellDelegate{
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = self.messagesCollectionView.indexPath(for: cell) else { return }
        let message = self.messages[indexPath.row]
        
        switch message.kind{
        case .photo(let mediaUrl):
            guard let url = mediaUrl.url else { return }
            
            let vc = ImageViewController(imgUrl: url)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: false)
            
        default:
            break
        }
        
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
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              otherUserId: self.otherUserEmail,
                              kind: .text(text))
        
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
        
        // https://developer.apple.com/forums/thread/652496
        
        picker.dismiss(animated: true) {
            //TODO: use the image data
            guard let result = results.first else{ return }
            let provider = result.itemProvider
 
            // UTType.movie.identifier
            if(provider.hasItemConformingToTypeIdentifier("public.movie")){
                provider.loadItem(forTypeIdentifier: "public.movie", options: nil) {[weak self] videoURL, error in
                    guard let url = videoURL as? NSURL,
                          let fileUrl = url.filePathURL else { return }
                    guard let strongSelf = self else { return }
                    
                    print("Debug: video file url \(fileUrl)")
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                    let date = dateFormatter.string(from: Date())
                    let fileName = "conversation_\(strongSelf.safeEmail)_to_\(strongSelf.otherUserEmail)_\(date)"
                    
                    
                    StorageManager.shared.uploadMediaToStorage(with: fileUrl, uploadType: .chatVideos, fileName: fileName) { result in
                        switch result{
                        case .failure(_):
                            break
                        case .success(let viedeoUrl):
                            guard let videoUrl = URL(string: viedeoUrl) else { return }
                            let mediaItem = PhotoMessage(url: videoUrl,
                                                         image: nil,
                                                         placeholderImage: UIImage(systemName: "circle.bottomhalf.filled")!,
                                                         size: CGSize(width: 200, height: 200))
                            
                            let toUploadMessage = Message(sender: strongSelf.selfSender,
                                                          messageId: dateFormatter.string(from: Date()),
                                                          sentDate: Date(),
                                                          otherUserId: "Dummy Id",
                                                          kind: .video(mediaItem))
                            
                            strongSelf.messages.append(toUploadMessage)
                            
                            DatabaseManager.shared.uploadMessage(safeEmail: strongSelf.safeEmail,
                                                                 message: toUploadMessage,
                                                                 otherUserEmail: strongSelf.otherUserEmail ,
                                                                 otherUserName: strongSelf.otherUserName,
                                                                 senderEmail: strongSelf.safeEmail,
                                                                 type: .video)
                            
                            DispatchQueue.main.async {
                                print("Debug: appended video")
                                strongSelf.messagesCollectionView.reloadData()
                            }
                        }
                    }
                    
                    
                    
                }
            }else{
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    
                    guard let strongSelf = self else { return }
                    
                    if let image = image as? UIImage{
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                        let date = dateFormatter.string(from: Date())
                        
                        let fileName = "conversation_\(strongSelf.safeEmail)_to_\(strongSelf.otherUserEmail)_\(date)"
                        
                        StorageManager.shared.uploadMediaToStorage(with: image.pngData()!,
                                                                     uploadType: .chatImages,
                                                                     fileName: fileName) { result in
                            switch result{
                            case .success(let imageUrl):
                                print("Debug: chat image uploaded \(imageUrl)")
                                
                                guard let url = URL(string: imageUrl) else { return }
                                
                                URLSession.shared.dataTask(with: url) { data, _, _ in
                                    guard let data = data else { return }
                                    
                                    let dummyPhotoMessage = PhotoMessage(url: url,
                                                                         image: UIImage(data: data),
                                                                         placeholderImage: UIImage(systemName: "circle.bottomhalf.filled")!,
                                                                         size: CGSize(width: 200, height: 200))
                                    
                                    
                                    let toUploadMessage = Message(sender: strongSelf.selfSender,
                                                                  messageId: dateFormatter.string(from: Date()),
                                                                  sentDate: Date(),
                                                                  otherUserId: "Dummy Id",
                                                                  kind: .photo(dummyPhotoMessage))
                                    
                                    strongSelf.messages.append(toUploadMessage)
                                    
                                    DatabaseManager.shared.uploadMessage(safeEmail: strongSelf.safeEmail,
                                                                         message: toUploadMessage,
                                                                         otherUserEmail: strongSelf.otherUserEmail ,
                                                                         otherUserName: strongSelf.otherUserName,
                                                                         senderEmail: strongSelf.safeEmail,
                                                                         type: .photo)
                                    
                                    print("Debug: image message has been added to array \(data)")
                                    
                                    DispatchQueue.main.async {
                                        strongSelf.messagesCollectionView.reloadData()
                                    }
                                    
                                    
                                }.resume()
                                
                                
                            case .failure(_):
                                print("Debug: cannot upload chat image")
                            }
                        }
                    }else{
                        print("Debug: cannot load the image user picked: \(image)")
                    }
                }
            }
            
            
        }
    }
    
    
}
