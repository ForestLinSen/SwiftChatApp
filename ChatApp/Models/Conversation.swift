//
//  Conversation.swift
//  ChatApp
//
//  Created by Sen Lin on 31/12/2021.
//

import Foundation

struct Conversation{
    let id: String
    let otherUserName: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
    let messages: [Messages]
    
}

struct LatestMessage{
    let date: String
    let text: String
    let isRead: Bool = false
}

struct Messages{
    let date: String
    let text: String
    let senderEmail: String
}
