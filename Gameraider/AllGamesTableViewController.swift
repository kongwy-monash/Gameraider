//
//  AllGamesTableViewController.swift
//  Gameraider
//
//  Created by user173323 on 11/17/20.
//

import UIKit


class AllGamesTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    
    let SECTION_GAMES = 0
    let SECTION_INFO = 1
    let CELL_GAME = "searchGameCell"
    let CELL_INFO = "totalGamesCell"
    
    var allGames: [Game] = []
    var filteredGames: [Game] = []
    weak var gameDelegate: AddGameDelegate?
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .all
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filteredGames = allGames
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Games"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Search Controller Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        if searchText.count > 0 {
            filteredGames = allGames.filter({ (game: Game) -> Bool in
                return game.title.lowercased().contains(searchText)
            })
        } else {
            filteredGames = allGames
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_GAMES {
            return filteredGames.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_GAMES {
            let gameCell = tableView.dequeueReusableCell(withIdentifier: CELL_GAME,
                                                         for: indexPath) as! SearchGamesTableViewCell
            let game = filteredGames[indexPath.row]
            
            gameCell.nameLabel.text = game.title
            gameCell.yearLabel.text = String(game.year)
            
            return gameCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        cell.textLabel?.text = "\(allGames.count) games in the database"
        cell.textLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        return cell
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_INFO {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        if gameDelegate?.addGame(newGame: filteredGames[indexPath.row]) ?? false {
            navigationController?.popViewController(animated: false)
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        displayMessage(title: "Collection Full", message: "Unable to add more games to collection")
    }
    
    
    // MARK: - Database Listener
    func onGameListChange(change: DatabaseChange, games: [Game]) {
        allGames = games
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onCollectionChange(change: DatabaseChange, collectionGames: [Game]) {
        // Do nothing not called
    }
    
    func onPlaceListChange(change: DatabaseChange, places: [Place]) {
        // PASS
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
