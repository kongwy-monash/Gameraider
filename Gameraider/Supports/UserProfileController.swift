//
//  UserProfileController.swift
//  Gameraider
//
//  Created by Weiyi Kong on 17/11/20.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class UserProfileController: NSObject {
    
    var usersRef: CollectionReference?
    
    override init() {
        super.init()
        usersRef = Firestore.firestore().collection("users")
    }
    
    func setProfile(uid: String, username: String, displayName: String, onCompletion: @escaping (Error?) -> Void) {
        let data = [
            "username": username,
            "lowerUsername": username.lowercased(),
            "displayName": displayName
        ]
        usersRef!.document(uid).setData(data, completion: onCompletion)
    }
    
    func getProfile(uid: String, onCompletion: @escaping ([String: Any?]?, Error?) -> Void) {
        usersRef!.document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                onCompletion(nil, error)
                return
            }
            let userProfile: [String: Any?] = [
                "username": documentSnapshot!.get("username"),
                "displayName": documentSnapshot!.get("displayName")
            ]
            onCompletion(userProfile, error)
        }
    }
    
    func deleteProfile(uid: String, onCompletion: @escaping (Error?) -> Void) {
        usersRef!.document(uid).delete(completion: onCompletion)
    }
    
    func verifyUsername(newUsername: String, uid: String?, onCompletion: @escaping (Bool?, Error?) -> Void) {
        let usernameQuery = usersRef!.whereField("lowerUsername", isEqualTo: newUsername.lowercased())
        usernameQuery.getDocuments(completion: { (querySnapshot, error) in
            var isAvailable: Bool? = nil
            if let querySnapshot = querySnapshot {
                if querySnapshot.isEmpty {
                    isAvailable = true
                } else if let uid = uid {
                    for document in querySnapshot.documents {
                        isAvailable = document.documentID == uid ? true : false
                    }
                } else {
                    isAvailable = false
                }
            }
            onCompletion(isAvailable, error)
        })
    }
    
    func setAvatar(uid: String, imagePngData: Data?, onCompletion: @escaping (Error?) -> Void) {
        let userAvatarRef = Storage.storage().reference(withPath: "user_avatar/\(uid).png")
        guard let imagePngData = imagePngData else {
            userAvatarRef.delete(completion: onCompletion)
            return
        }
        userAvatarRef.putData(imagePngData, metadata: nil) { (storageMetadata, error) in
            onCompletion(error)
        }
    }
    
    func getAvatar(uid: String, onCompletion: @escaping (Data?, Error?) -> Void) {
        let userAvatarRef = Storage.storage().reference(withPath: "user_avatar/\(uid).png")
        userAvatarRef.getData(maxSize: 50 * 1024 * 1024, completion: onCompletion)
    }
}
