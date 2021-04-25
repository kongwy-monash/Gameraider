//
//  FindViewController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 20/11/20.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseFirestore

class FindViewController: UIViewController {
    
    var locationManager: CLLocationManager!
    var placesClient: GMSPlacesClient!
    var mapView: GMSMapView!
    
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .places
    var allPlaces: [Place] = []
    var markerToGplace: [GMSMarker: GMSPlace] = [:]
    var markerToPlace: [GMSMarker: Place] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        
        let melbourneLocation = CLLocationCoordinate2D(latitude: -37.81305931721498, longitude: 144.96759594585936)
        let melbourneCamera = GMSCameraPosition.camera(withTarget: melbourneLocation, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: melbourneCamera)
        mapView.delegate = self
        self.view.addSubview(mapView)
        
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaceListSegue" {
            let placeListViewController = segue.destination as! PlaceListTableViewController
            placeListViewController.delegate = self
            placeListViewController.allPlaces = allPlaces
        }
    }

}

extension FindViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways,
             .authorizedWhenInUse:
            manager.startUpdatingLocation()
            self.mapView.settings.myLocationButton = true
            self.mapView.isMyLocationEnabled = true
        default:
            self.mapView.settings.myLocationButton = false
            self.mapView.isMyLocationEnabled = false
        }
    }
}

extension FindViewController: DatabaseListener {
    func onCollectionChange(change: DatabaseChange, collectionGames: [Game]) {
        // PASS
    }
    
    func onGameListChange(change: DatabaseChange, games: [Game]) {
        // PASS
    }
    
    func onPlaceListChange(change: DatabaseChange, places: [Place]) {
        allPlaces = places
        for place in allPlaces {
            placesClient.lookUpPlaceID(place.placeID) { (gPlace, error) in
                if let error = error {
                    print(error)
                    return
                }
                let marker = GMSMarker(position: gPlace!.coordinate)
                marker.title = gPlace!.name
                marker.snippet = gPlace!.formattedAddress
                marker.map = self.mapView
                self.markerToPlace[marker] = place
                self.markerToGplace[marker] = gPlace
            }
        }
    }
}

extension FindViewController: PlaceListDelegate {
    func pushViewController(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension FindViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let placeTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PlaceView") as! PlaceTableViewController
        placeTableViewController.place = markerToPlace[marker]
        placeTableViewController.gPlace = markerToGplace[marker]
        self.navigationController!.pushViewController(placeTableViewController, animated: true)
    }
}


