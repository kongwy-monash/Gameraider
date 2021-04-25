//
//  PlaceListTableViewController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 22/11/20.
//

import UIKit
import GooglePlaces

class PlaceListTableViewController: UITableViewController {
    
    var allPlaces: [Place]?
    var placesClient: GMSPlacesClient?
    
    var delegate: PlaceListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        placesClient = GMSPlacesClient.shared()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allPlaces!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)

        cell.textLabel?.text = allPlaces![indexPath.row].name
        cell.detailTextLabel?.text = "\(allPlaces![indexPath.row].address!.city ?? "") \(allPlaces![indexPath.row].address!.state ?? "")"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        placesClient?.lookUpPlaceID(allPlaces![indexPath.row].placeID, callback: { (gPlace, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let placeTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaceView") as! PlaceTableViewController
            placeTableViewController.place = self.allPlaces![indexPath.row]
            placeTableViewController.gPlace = gPlace
            self.dismiss(animated: true) {
                self.delegate?.pushViewController(viewController: placeTableViewController)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol PlaceListDelegate {
    func pushViewController(viewController: UIViewController) -> Void
}
