//
//  Message.swift
//  ChatApp
//
//  Created by Sen Lin on 29/12/2021.
//

import Foundation
import MessageKit

enum TypeOfMessage: String{
    case text = "text"
    case photo = "photo"
    case video = "video"
}

struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var dateString: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        return formatter.string(from: sentDate)
    }
    let otherUserId: String
    
    var kind: MessageKind
    
    var message: String{
        switch kind {
        case .text(let string):
            return string
        case .attributedText(let nSAttributedString):
            break
        case .photo(let mediaItem):
            return mediaItem.url?.absoluteString ?? ""
        case .video(let mediaItem):
            return mediaItem.url?.absoluteString ?? ""
        case .location(let locationItem):
            break
        case .emoji(let string):
            break
        case .audio(let audioItem):
            break
        case .contact(let contactItem):
            break
        case .linkPreview(let linkItem):
            break
        case .custom(let optional):
            break
        }
        
        return ""
    }
}
