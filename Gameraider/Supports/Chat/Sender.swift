//
//  Sender.swift
//  Gameraider
//
//  Created by user173323 on 11/22/20.
//

import UIKit
import MessageKit

class Sender: SenderType {
    var senderId: String
    var displayName: String
    
    init(id: String, name: String) {
        senderId = id
        displayName = name
    }
}
