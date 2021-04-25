//
//  EditProfileTableViewController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 17/11/20.
//

import UIKit
import FirebaseAuth

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var newPasswdTextField: UITextField!
    @IBOutlet weak var repeatNewPasswdTextField: UITextField!
    
    var authController: Auth?
    var handle: AuthStateDidChangeListenerHandle?
    var currentUser: User?
    
    let userProfileController = UserProfileController()
    var currentProfile: [String: String] = [:]
    var saveButton: UIBarButtonItem?
    var isAvatarChanged: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = nil
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped(_:)))
        nameTextField.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        newPasswdTextField.delegate = self
        repeatNewPasswdTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authController = Auth.auth()
        handle = authController?.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.currentUser = user
                self.currentProfile["email"] = user.email
                self.emailTextField.text = user.email
                self.userProfileController.getProfile(uid: user.uid) { (data, error) in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.currentProfile["displayName"] = (data?["displayName"] as? String) ?? ""
                    self.title = (data?["displayName"] as? String) ?? ""
                    self.nameTextField.text = (data?["displayName"] as? String) ?? ""
                    self.currentProfile["username"] = (data?["username"] as? String) ?? ""
                    self.usernameTextField.text = (data!["username"] as? String) ?? ""
                }
                self.userProfileController.getAvatar(uid: user.uid) { (data, error) in
                    if let data = data {
                        self.avatarImageView.image = UIImage(data: data)
                        self.avatarButton.setTitle("Edit Image", for: .normal)
                    }
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        authController!.removeStateDidChangeListener(handle!)
    }
    
    @IBAction func avatarButtonTapped(_ sender: Any) {let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        
        let selectAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            selectAlert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            selectAlert.addAction(UIAlertAction(title: "Open Gallery", style: .default, handler: { (action) in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
        let placeholderAvatar = UIImage(systemName: "person.crop.circle.fill")
        if self.avatarImageView.image != placeholderAvatar {
            selectAlert.addAction(UIAlertAction(title: "Remove Image", style: .destructive, handler: { (action) in
                self.avatarImageView.image = placeholderAvatar
                self.avatarButton.setTitle("Add Image", for: .normal)
                self.isAvatarChanged = true
                self.navigationItem.rightBarButtonItem = self.saveButton
            }))
        }
        selectAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(selectAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            do {
                try authController!.signOut()
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.showAlert(title: "Error", message: error.localizedDescription)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        }
        
        if indexPath.section == 3 {
            let alert = UIAlertController(title: "Confirm to Delete?", message: "Once an account is deleted, the account itself and all data of it cannot be restored.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alertAction) in
                self.reauthenticate { (isSucessful) in
                    if isSucessful {
                        self.currentUser!.delete(completion: { (error) in
                            if let error = error {
                                self.showAlert(title: "Error", message: error.localizedDescription)
                            }
                            self.userProfileController.deleteProfile(uid: self.currentUser!.uid) { (error) in
                                if let error = error {
                                    self.showAlert(title: "Error", message: error.localizedDescription)
                                }
                            }
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        if validateForm() {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespaces)
            let newPasswd = newPasswdTextField.text!
            let name = nameTextField.text!
            let username = usernameTextField.text!
            let isEmailChanged = (email != self.currentUser!.email)
            let isPasswdChanged = (!newPasswd.isEmpty)
            
            var isFaild = false
            
            if isEmailChanged || isPasswdChanged {
                reauthenticate { (isSuccessful) in
                    if !isSuccessful {
                        self.showAlert(title: "Update Faild", message: "Current password must be provided to perform security-sensitive actions.")
                        return
                    }
                    if isEmailChanged {
                        self.currentUser!.updateEmail(to: email, completion: { (error) in
                            if let error = error {
                                self.showAlert(title: "Error", message: error.localizedDescription)
                                isFaild = true
                            }
                        })
                        if isFaild { return }
                    }
                    if isPasswdChanged {
                        self.currentUser!.updatePassword(to: newPasswd) { (error) in
                            if let error = error {
                                self.showAlert(title: "Error", message: error.localizedDescription)
                                isFaild = true
                            }
                        }
                        if isFaild { return }
                    }
                }
            }
            userProfileController.verifyUsername(newUsername: username, uid: currentUser!.uid) { (isAvailable, error) in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    isFaild = true
                    return
                }
                if isAvailable! {
                    self.userProfileController.setProfile(uid: self.currentUser!.uid, username: username, displayName: name) { (error) in
                        if let error = error {
                            self.showAlert(title: "Error", message: error.localizedDescription)
                            isFaild = true
                        }
                    }
                } else {
                    self.showAlert(title: "Invalid Username", message: "The username has already been taken.")
                    isFaild = true
                }
            }
            if isFaild { return }
            if isAvatarChanged {
                let newAvatarData = avatarImageView.image == UIImage(systemName: "person.crop.circle.fill") ? nil : avatarImageView.image!.pngData()
                userProfileController.setAvatar(uid: currentUser!.uid, imagePngData: newAvatarData) { (error) in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        isFaild = true
                    }
                }
                if isFaild { return }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func reauthenticate(onCompletion: @escaping (Bool) -> Void) {
        var doEscape = false
        let passwordPromptAlert = UIAlertController(title: "Authentication Needed", message: "To perform security-sensitive actions, please enter your current password.", preferredStyle: .alert)
        passwordPromptAlert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        passwordPromptAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            doEscape = true
            onCompletion(false)
        }))
        passwordPromptAlert.addAction(UIAlertAction(title: "Authenticate", style: .default, handler: { (action) in
            let passwd = passwordPromptAlert.textFields![0].text!
            let credential = EmailAuthProvider.credential(withEmail: self.currentUser!.email!, password: passwd)
            self.currentUser!.reauthenticate(with: credential) { (result, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        doEscape = true
                        onCompletion(false)
                    }))
                    alert.addAction(UIAlertAction(title: "Re-try", style: .default, handler: { (action) in
                        self.reauthenticate(onCompletion: onCompletion)
                        return
                    }))
                    self.present(alert, animated: true, completion: nil)
                    if doEscape { return }
                }
                onCompletion(true)
            }
        }))
        self.present(passwordPromptAlert, animated: true, completion: nil)
        if doEscape { return }
    }
    
    func validateForm() -> Bool {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespaces)
        let newPasswd = newPasswdTextField.text!
        let repeatNewPasswd = repeatNewPasswdTextField.text!
        let name = nameTextField.text!
        let username = usernameTextField.text!
        
        if email.isEmpty ||
            name.isEmpty ||
            username.isEmpty {
            self.showAlert(title: "Missing Fields", message: "Please enter all fields.")
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
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            self.showAlert(title: "Invalid Email", message: "Please enter a valid Email address.")
            return false
        }
        
        if newPasswd != repeatNewPasswd {
            self.showAlert(title: "Recheck Password", message: "You entered two diffrent passwords.")
            return false
        }
        
        return true
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

extension EditProfileTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
}

extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        avatarImageView.image = (info[.editedImage] as! UIImage)
        avatarButton.setTitle("Edit Image", for: .normal)
        picker.dismiss(animated: true, completion: nil)
        self.isAvatarChanged = true
        self.navigationItem.rightBarButtonItem = self.saveButton
    }
}
