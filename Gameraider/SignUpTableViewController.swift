//
//  SignUpTableViewController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 17/11/20.
//

import UIKit
import FirebaseAuth

class SignUpTableViewController: UITableViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var repeatPasswdTextField: UITextField!
    
    var authController: Auth?
    let userProfileController = UserProfileController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController = Auth.auth()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespaces)
            let passwd = passwdTextField.text!
            let name = nameTextField.text!
            let username = usernameTextField.text!
            
            if validateFrom() {
                let loadingAlert = self.showLoadingAlert(title: "Creating Account...", message: nil)
                
                userProfileController.verifyUsername(newUsername: username, uid: nil) { (isAvailable, error) in
                    if let error = error {
                        loadingAlert.dismiss(animated: true, completion: nil)
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    if !isAvailable! {
                        loadingAlert.dismiss(animated: true, completion: nil)
                        self.showAlert(title: "Error", message: "Username has already been taken.")
                        return
                    }
                    
                    self.authController!.createUser(withEmail: email, password: passwd, completion: { (authResult, error) in
                        if let error = error {
                            loadingAlert.dismiss(animated: true, completion: nil)
                            self.showAlert(title: "Error", message: error.localizedDescription)
                            return
                        }
                        
                        self.userProfileController.setProfile(uid: authResult!.user.uid, username: username, displayName: name) { (error) in
                            if let error = error {
                                authResult!.user.delete(completion: nil)
                                loadingAlert.dismiss(animated: true, completion: nil)
                                self.showAlert(title: "Error", message: error.localizedDescription)
                                return
                            }
                            
                            loadingAlert.dismiss(animated: true, completion: nil)
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func validateFrom() -> Bool {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespaces)
        let passwd = passwdTextField.text!
        let repeatPasswd = repeatPasswdTextField.text!
        let name = nameTextField.text!
        let username = usernameTextField.text!
        
        if email.isEmpty ||
            passwd.isEmpty ||
            repeatPasswd.isEmpty ||
            name.isEmpty ||
            username.isEmpty {
            self.showAlert(title: "Missing Fields", message: "Please enter all fields.")
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            self.showAlert(title: "Invalid Email", message: "Please enter a valid Email address.")
            return false
        }
        
        if passwd != repeatPasswd {
            self.showAlert(title: "Recheck Password", message: "You entered two diffrent passwords.")
            return false
        }
        
        if username.count < 5 {
            self.showAlert(title: "Invalid Username", message: "Username cannot be shorter than 5 characters.")
        }
        
        let usernameRegex = "[A-Za-z0-9_]+"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        if !usernamePredicate.evaluate(with: username) {
            self.showAlert(title: "Invalid Username", message: "Username can only consist of characters, numbers and underline.")
            return false
        }
        
        return true
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingAlert(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 16, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        alert.addAction(UIAlertAction(title: "Hide", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        return alert
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
