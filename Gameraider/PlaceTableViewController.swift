//
//  PlaceTableViewController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 22/11/20.
//

import UIKit
import GooglePlaces

class PlaceTableViewController: UITableViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var redirectButton: UIBarButtonItem!
    
    var place: Place?
    var gPlace: GMSPlace?
    var games: [Game]?
    var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        games = place!.games
        placesClient = GMSPlacesClient.shared()
        if let photoMetadata = gPlace?.photos?.first {
            placesClient.loadPlacePhoto(photoMetadata) { (image, error) in
                if let error = error {
                    print(error)
                    return
                }
                self.photoImageView.image = image!
            }
        }
        nameLabel.text = place!.name
        addressLabel.text = gPlace?.formattedAddress
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if games!.count == 0 {
            return 1
        }
        return games!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
        
        if games!.count == 0 {
            cell.textLabel?.text = "Don't have information."
            cell.textLabel?.textColor = UIColor.gray
            cell.accessoryType = .none
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        cell.textLabel?.text = games![indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Games"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GameDetailView") as! GameDetailsViewController
        gameViewController.game = games![indexPath.row]
        self.present(gameViewController, animated: true, completion: nil)
        // self.navigationController!.pushViewController(gameViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
