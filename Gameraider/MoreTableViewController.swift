//
//  MoreTableViewController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 16/11/20.
//

import UIKit
import FirebaseAuth

class MoreTableViewController: UITableViewController {
    
    @IBOutlet weak var profileTabelViewCell: UITableViewCell!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var authController: Auth?
    var handle: AuthStateDidChangeListenerHandle?
    let userProfileController = UserProfileController()
    var isSignedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authController = Auth.auth()
        handle = authController!.addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userProfileController.getProfile(uid: user.uid) { (data, error) in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    self.nameLabel.text = (data?["displayName"] as? String) ?? ""
                    self.usernameLabel.text = "@\((data?["username"] as? String) ?? "")"
                    self.userProfileController.getAvatar(uid: user.uid) { (data, error) in
                        if let data = data {
                            self.avatarImageView.image = UIImage(data: data)
                        } else {
                            self.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
                        }
                    }
                }
                self.nameLabel.font = UIFont.systemFont(ofSize: self.nameLabel.font.pointSize, weight: .semibold)
                self.nameLabel.textColor = .label
                self.profileTabelViewCell.accessoryType = .disclosureIndicator
                self.isSignedIn = true
            } else {
                self.nameLabel.text = "Sign In / Sign Up"
                self.usernameLabel.text = "To enable full features"
                self.nameLabel.font = UIFont.systemFont(ofSize: self.nameLabel.font.pointSize, weight: .regular)
                self.nameLabel.textColor = .link
                self.profileTabelViewCell.accessoryType = .none
                self.isSignedIn = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController!.removeStateDidChangeListener(handle!)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if isSignedIn {
                let profileTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EditProfileTableView")
                self.navigationController!.pushViewController(profileTableViewController, animated: true)
            } else {
                signInOrSignUpPrompt()
            }
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        if indexPath.section == 2 {
            showAlert(title: "About", message: "This app is a FIT5140 Assignment 3 project. Developed by Yifei Xie and Weiyi Kong.")
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
