//
//  AddGameDelegate.swift
//  Gameraider
//
//  Created by user173323 on 11/17/20.
//

import Foundation

protocol AddGameDelegate: AnyObject {
    func addGame(newGame: Game) -> Bool
}
