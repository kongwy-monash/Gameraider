//
//  DatabaseProtocol.swift
//  Gameraider
//
//  Created by user173323 on 11/5/20.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case collection
    case games
    case places
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onCollectionChange(change: DatabaseChange, collectionGames: [Game])
    func onGameListChange(change: DatabaseChange, games: [Game])
    func onPlaceListChange(change: DatabaseChange, places: [Place])
}

protocol DatabaseProtocol: AnyObject {
    var defaultCollection: Collection {get}
    
    func cleanup()
//    func addGame(title: String, cover: String, developer: String, network: String, series: String, year: Int, category: [String], region: [String], videos: [String]) -> Game
    func addCollection(collectionName: String) -> Collection
    func addGameToCollection(game: Game, collection: Collection) -> Bool
//    func deleteGame(game: Game)
    func deleteCollection(collection: Collection)
    func removeGameFromCollection(game: Game, collection: Collection)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
