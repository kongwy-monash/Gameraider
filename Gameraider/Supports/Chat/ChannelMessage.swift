//
//  ChannelMessage.swift
//  Gameraider
//
//  Created by user173323 on 11/22/20.
//

import UIKit
import MessageKit

class ChannelMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, message: String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(message)
    }
}
