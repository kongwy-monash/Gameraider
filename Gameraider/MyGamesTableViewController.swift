//
//  MyGamesTableViewController.swift
//  Gameraider
//
//  Created by user173323 on 11/16/20.
//

import UIKit


class MyGamesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddGameDelegate, DatabaseListener  {
    @IBOutlet weak var gameTableView: UITableView!
    
    let SECTION_PARTY = 0;
    let SECTION_INFO = 1;
    let CELL_GAME = "gameCell"
    let CELL_INFO = "partySizeCell"
    
    var currentCollection: [Game] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .collection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameTableView.delegate = self
        gameTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Database Listener
    func onGameListChange(change: DatabaseChange, games: [Game]) {
        // Do nothing not called
    }
    
    func onCollectionChange(change: DatabaseChange, collectionGames: [Game]) {
        currentCollection = collectionGames
        gameTableView.reloadData()
    }
    
    func onPlaceListChange(change: DatabaseChange, places: [Place]) {
        // PASS
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_PARTY:
            return currentCollection.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_PARTY {
            let partyCell =
                tableView.dequeueReusableCell(withIdentifier: CELL_GAME, for: indexPath)
                as! MyGamesTableViewCell
            let game = currentCollection[indexPath.row]
            
            partyCell.nameLabel.text = game.title
            partyCell.yearLabel.text = String(game.year)
            
            //from tutorial
            let imageURL = URL(string: (game.cover))
            let imageTask = URLSession.shared.dataTask(with:imageURL!){
                (data,response, error)in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                DispatchQueue.main.async{
                    partyCell.gameImage!.image = UIImage(data: data!)
                }
            }
            imageTask.resume()
            
            partyCell.sizeToFit()
            
            return partyCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        
        cell.textLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        if currentCollection.count > 0 {
            cell.textLabel?.text = "\(currentCollection.count)/50 games in collection"
        } else {
            cell.textLabel?.text = "No games in collection. Click + to add some."
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        let game = currentCollection[indexPath.row]
        performSegue(withIdentifier: "gameDetailSegue", sender: game)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_PARTY {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_PARTY {
            self.databaseController?.removeGameFromCollection(game: currentCollection[indexPath.row], collection:
                                                                databaseController!.defaultCollection)
        }
    }
    
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "searchGameSegue" {
            let destination = segue.destination as! AllGamesTableViewController
            destination.gameDelegate = self
        }
        if segue.identifier == "gameDetailSegue" {
            let destination = segue.destination as! GameDetailsViewController
            destination.game = sender as! Game
        }
    }
    
    // MARK: - AddGame Delegate
    func addGame(newGame: Game) -> Bool {
        return databaseController!.addGameToCollection(game: newGame, collection: databaseController!.defaultCollection)
        
    }
    
}
