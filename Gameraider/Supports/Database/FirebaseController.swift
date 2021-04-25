//
//  FirebaseController.swift
//  Gameraider
//
//  Created by user173323 on 11/16/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    let DEFAULT_COLLECTION_NAME = "Default Collection"
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var placesRef: CollectionReference?
    var gamesRef: CollectionReference?
    var collectionsRef: CollectionReference?
    var placeList: [Place]
    var gameList: [Game]
    var defaultCollection: Collection
    
    override init() {
        // To use Firebase in our application we first must run the
        // FirebaseApp configure method
        FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        placeList = [Place]()
        gameList = [Game]()
        defaultCollection = Collection()
        
        super.init()
        
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be
        // any time later
        
//        authController.signInAnonymously() { (authResult, error) in
//            guard authResult != nil else {
//                fatalError("Firebase authentication failed")
//            }
//            // Once we have authenticated we can attach our listeners to
//            // the firebase firestore
//            self.setUpGameListener()
//        }
        self.setUpGameListener()
    }
    
    // MARK:- Setup code for Firestore listeners
    func setUpGameListener() {
        gamesRef = database.collection("games")
        gamesRef?.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parseGamesSnapshot(snapshot: querySnapshot)

            // Team listener references heroes, so we need to
            // do it after we have parsed heroes.
            self.setUpCollectionListener()
        }
    }
    
    func setUpCollectionListener() {
        collectionsRef = database.collection("collections")
        collectionsRef?.whereField("name", isEqualTo: DEFAULT_COLLECTION_NAME).addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot,
                  let collectionSnapshot = querySnapshot.documents.first else {
                print("Error fetching collections: \(error!)")
                return
            }
            self.parseCollectionSnapshot(snapshot: collectionSnapshot)
            
            self.setUpPlaceListener()
        }
    }
    
    func setUpPlaceListener() {
        placesRef = database.collection("places")
        placesRef?.addSnapshotListener({ (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching documents: \(error!)")
                return
            }
            self.parsePlaceSnapshot(snapshot: querySnapshot)
        })
    }
    
    // MARK:- Parse Functions for Firebase Firestore responses
    func parseGamesSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let gameID = change.document.documentID
            print(gameID)
            
            var parsedGame: Game?
            
            do {
                parsedGame = try change.document.data(as: Game.self)
            } catch {
                print("Unable to decode game. Is the game malformed?")
                return
            }
            
            guard let game = parsedGame else {
                print("Document doesn't exist")
                return;
            }
            
            game.id = gameID
            if change.type == .added {
                gameList.append(game)
            }
            else if change.type == .modified {
                let index = getGameIndexByID(gameID)!
                gameList[index] = game
            }
            else if change.type == .removed {
                if let index = getGameIndexByID(gameID) {
                    gameList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.games ||
                listener.listenerType == ListenerType.all {
                listener.onGameListChange(change: .update, games: gameList)
            }
        }
    }
    
    func parseCollectionSnapshot(snapshot: QueryDocumentSnapshot) {
        defaultCollection = Collection()
        defaultCollection.name = snapshot.data()["name"] as! String
        defaultCollection.id = snapshot.documentID
        
        if let gameReferences = snapshot.data()["games"] as? [DocumentReference] {
            // If the document has a "games" field, add games.
            for reference in gameReferences {
                if let game = getGameByID(reference.documentID) {
                    defaultCollection.games.append(game)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.collection ||
                listener.listenerType == ListenerType.all {
                listener.onCollectionChange(change: .update, collectionGames: defaultCollection.games)
            }
        }
    }
    
    func parsePlaceSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (documentChange) in
            let id = documentChange.document.documentID
            var place: Place?
            do {
                place = try documentChange.document.data(as: Place.self)
            } catch {
                print(error)
            }
            guard place != nil else {
                print("Failed to parse place.")
                return
            }
            place!.id = id
            
            place!.games = []
            for gameDocRef in place!.availableGames {
                if let game = getGameByID(gameDocRef.documentID) {
                    place!.games!.append(game)
                }
            }
            
            switch documentChange.type {
            case .added:
                placeList.append(place!)
            case .modified:
                let index = getPlaceIndexByID(id)!
                placeList[index] = place!
            case .removed:
                if let index = getPlaceIndexByID(id) {
                    placeList.remove(at: index)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.places ||
                listener.listenerType == ListenerType.all {
                listener.onPlaceListChange(change: .update, places: placeList)
            }
        }
    }
    
    // MARK:- Utility Functions
    func getGameIndexByID(_ id: String) -> Int? {
        if let game = getGameByID(id) {
            return gameList.firstIndex(of: game)
        }
        return nil
    }
    
    func getGameByID(_ id: String) -> Game? {
        for game in gameList {
            if game.id == id {
                return game
            }
        }
        return nil
    }
    
    func getPlaceIndexByID(_ id: String) -> Int? {
        if let place = getPlaceByID(id) {
            return placeList.firstIndex(of: place)
        }
        return nil
    }
    
    func getPlaceByID(_ id: String) -> Place? {
        for place in placeList {
            if place.id == id {
                return place
            }
        }
        return nil
    }
    
    // MARK:- Required Database Functions
    func cleanup() {
        
    }
    
//    func addGame(title: String, cover: String, developer: String, network: String, series: String, year: Int, category: [String], region: [String], videos: [String]) -> Game {
//        let game = Game()
//        game.title = title
//        game.cover = cover
//        game.developer = developer
//        game.network = network
//        game.series = series
//        game.year = year
//        game.category = category
//        game.region = region
//        game.videos = videos
//
//        do {
//            if let gameRef = try gamesRef?.addDocument(from: game) {
//                game.id = gameRef.documentID
//            }
//        } catch {
//            print("Failed to serialize game")
//        }
//        return game
//    }
    
    
//    func deleteGame(game: Game) {
//        if let gameID = game.id {
//            gamesRef?.document(gameID).delete()
//        }
//    }
    
    func addCollection(collectionName: String) -> Collection {
        let collection = Collection()
        collection.name = collectionName
        if let collectionRef = collectionsRef?.addDocument(data: ["name" : collectionName, "games": []]) {
            collection.id = collectionRef.documentID
        }
        return collection
    }
    
    func deleteCollection(collection: Collection) {
        if let collectionID = collection.id {
            collectionsRef?.document(collectionID).delete()
        }
    }
    
    func addGameToCollection(game: Game, collection: Collection) -> Bool {
        guard let gameID = game.id, let collectionID = collection.id,
              collection.games.count < 50 else {
            return false
        }
        
        if let newGameRef = gamesRef?.document(gameID) {
            collectionsRef?.document(collectionID).updateData(
                ["games" : FieldValue.arrayUnion([newGameRef])]
            )
        }
        return true
    }
    
    func removeGameFromCollection(game: Game, collection: Collection) {
        if collection.games.contains(game), let collectionID = collection.id,
           let gameID = game.id {
            if let removedRef = gamesRef?.document(gameID) {
                collectionsRef?.document(collectionID).updateData(
                    ["games": FieldValue.arrayRemove([removedRef])]
                )
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.collection ||
            listener.listenerType == ListenerType.all {
            listener.onCollectionChange(change: .update, collectionGames: defaultCollection.games)
        }
        
        if listener.listenerType == ListenerType.games ||
            listener.listenerType == ListenerType.all {
            listener.onGameListChange(change: .update, games: gameList)
        }
        
        if listener.listenerType == ListenerType.places ||
            listener.listenerType == ListenerType.all {
            listener.onPlaceListChange(change: .update, places: placeList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
}

