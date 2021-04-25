//
//  VideoData.swift
//  Gameraider
//
//  Created by user173323 on 11/21/20.
//

import UIKit

class VideoData: NSObject, Codable {
    var source = ""
    var type = ""
    var video = ""
    
    enum CodingKeys: String, CodingKey {
        case source
        case type
        case video
    }
}
