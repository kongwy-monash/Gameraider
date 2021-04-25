//
//  SignInTableViewController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 16/11/20.
//

import UIKit
import FirebaseAuth

class SignInTableViewController: UITableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    
    var authController: Auth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authController = Auth.auth()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespaces)
            let passwd = passwdTextField.text!
            if validateForm() {
                let loadingAlert = self.showLoadingAlert(title: "Logging in...", message: nil)
                authController?.signIn(withEmail: email, password: passwd, completion: { (authResult, error) in
                    loadingAlert.dismiss(animated: true, completion: nil)
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        tableView.deselectRow(at: indexPath, animated: true)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func validateForm() -> Bool {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespaces)
        let passwd = passwdTextField.text!
        if email.isEmpty || passwd.isEmpty {
            self.showAlert(title: "Missing Credential", message: "Please Enter both Email and password.")
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            self.showAlert(title: "Invalid Email", message: "Please enter a valid Email address.")
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
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 25, y: 5, width: 50, height: 50))
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
