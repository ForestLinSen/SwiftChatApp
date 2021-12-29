//
//  Message.swift
//  ChatApp
//
//  Created by Sen Lin on 29/12/2021.
//

import Foundation
import MessageKit

struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var dateString: String{
        let formatter = DateFormatter()
        
    }
    var kind: MessageKind
}
