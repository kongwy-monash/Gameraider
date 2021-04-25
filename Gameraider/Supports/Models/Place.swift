//
//  Place.swift
//  Gameraider
//
//  Created by Weiyi Kong on 22/11/20.
//

import UIKit
import FirebaseFirestore

class Place: NSObject, Codable {
    var id: String?
    var name = ""
    var desc = ""
    var placeID = ""
    var address: Address?
    var availableGames: [DocumentReference] = []
    var games: [Game]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case desc = "description"
        case placeID
        case address
        case availableGames
    }
}

class Address: NSObject, Codable {
    var location: String?
    var street: String?
    var city: String?
    var postcode: String?
    var state: String?
    var country: String?
}
