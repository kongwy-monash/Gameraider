//
//  ChannelsTableViewController.swift
//  Gameraider
//
//  Created by user173323 on 11/22/20.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChannelsTableViewController: UITableViewController {
    
    let CHANNEL_SEGUE = "channelSegue"
    let CHANNEL_CELL = "channelCell"
    var currentSender: Sender?
    var channels = [Channel]()
    let userProfileController = UserProfileController()
    
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database = Firestore.firestore()
        channelsRef = database.collection("channels")
        
        navigationItem.title = "Channels List"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var name: String = ""
        
        guard let currentUser = Auth.auth().currentUser else {
            let alert = UIAlertController(title: "Logging In Required", message: "You must sign in to use the chats. Please sign in or sign up.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sign In / Up", style: .default, handler: { (action) in
                self.signInOrSignUpPrompt()
            }))
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.tabBarController?.selectedIndex = 3
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.userProfileController.getProfile(uid: Auth.auth().currentUser!.uid) { (data, error) in
            if let error = error {
                print(error)
                return
            }
            name = (data?["displayName"] as? String) ?? ""
        }
        
        self.currentSender = Sender(id: Auth.auth().currentUser!.uid, name: name)
        
        databaseListener = channelsRef?.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            
            self.channels.removeAll()
            
            querySnapshot?.documents.forEach({snapshot in
                let id = snapshot.documentID
                let name = snapshot["name"] as! String
                let channel = Channel(id: id, name: name)
                
                self.channels.append(channel)
            })
            
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        databaseListener?.remove()
    }
    
    func signInOrSignUpPrompt() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { (UIAlertAction) in
            let signInTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SignInTableView")
            self.present(signInTableViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: { (UIAlertAction) in
            let signUpTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SignUpTableView")
            self.present(signUpTableViewController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection
                                section: Int) -> Int {
        return channels.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt
                                indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CHANNEL_CELL,
                                                 for: indexPath)
        let channel = channels[indexPath.row]
        
        cell.textLabel?.text = channel.name
        
        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt
                                indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt
                                indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: CHANNEL_SEGUE, sender: channel)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CHANNEL_SEGUE {
            let channel = sender as! Channel
            let destinationVC = segue.destination as! ChatMessagesViewController
            
            destinationVC.sender = currentSender
            destinationVC.currentChannel = channel
        }
    }
    
    @IBAction func addChannel(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Channel",
                                                message: "Enter channel name below", preferredStyle: .alert)
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            let channelName = alertController.textFields![0]
            
            var doesExist = false
            
            for channel in self.channels {
                if channel.name.lowercased() == channelName.text!.lowercased() {
                    doesExist = true
                }
            }
            
            if !doesExist {
                self.channelsRef?.addDocument(data: [
                    "name" : channelName.text!
                ])
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true)
    }
}




