//
//  Game.swift
//  Gameraider
//
//  Created by Weiyi Kong on 22/11/20.
//

import UIKit

class Game: NSObject, Codable {
    var id: String?
    var category = [String]()
    var cover = ""
    var developer = ""
    var network = ""
    var region = [String]()
    var series = ""
    var title = ""
    var videos = [String]()
    var year = 0

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case cover
        case developer
        case network
        case region
        case series
        case title
        case videos
        case year
    }
}
