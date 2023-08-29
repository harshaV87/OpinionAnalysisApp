
//
//  FirebaseService.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 7/1/23.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestoreSwift

// Actual Backend concrete flow

class fireBaseBackend: BackendService {
   
    var service: AuthServiceDelegate?
    var userSession: Bool? {
        willSet {
            service?.userAlreadyLoggedIn = newValue ?? false
        }
        
        didSet {
            service?.userInfo = UserInfo(userId: Auth.auth().currentUser?.uid ?? "", userEmail: Auth.auth().currentUser?.email ?? "")
        }
    }
    
     init(service: AuthServiceDelegate?) {
         self.service = service
    }
    
    func authenticateWithFirebase(emailID: String, password: String) async throws{
        do {
            let result = try await Auth.auth().signIn(withEmail: emailID, password: password)
            service?.authService(.email(nil, nil), didAuthenticate: UserInfo(userId: result.user.uid, userEmail: result.user.email ?? ""))
            userSession = true
        } catch {
            service?.authService(.email(nil, nil), didFailToAuthenticate: error)
            userSession = false
        }
    }
    
    func createAndAuthenticateUser(email: String, password: String) async throws {
        do {
            let result =  try await Auth.auth().createUser(withEmail: email, password: password)
            service?.authService(.email(nil, nil), didAuthenticate: UserInfo(userId: result.user.uid, userEmail: result.user.email ?? ""))
            userSession = true
        // Writing to DB
//            let userValue = User(id: result.user.uid, fullName: email, email: email)
//            // from Firebasefirestoreswift
//            let encodedUser = try Firestore.Encoder().encode(userValue)
//            try await Firestore.firestore().collection("users").document(result.user.uid).setData(encodedUser)
            // property can be set only if it is success
        } catch {
            service?.authService(.email(nil, nil), didFailToAuthenticate: error)
            userSession = false
        }
    }
    
    func deAuthenticateWithFirebase() async throws {
        //service?.authService(.apple, didFailToAuthenticate: nil)
        // here is where we logout
        do {
            try Auth.auth().signOut()
            userSession = false
        } catch {
            service?.authService(.email(nil, nil), didFailToAuthenticate: error)
        }
    }
    
    func checkUserAuthStatus() {
        userSession = true
        if Auth.auth().currentUser != nil {
            userSession = true
        } else {
            userSession = false
        }
    }
    
    func deleteUser(email: String, password: String) async throws {
        let user = Auth.auth().currentUser
        let userCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user?.reauthenticate(with: userCredential)
            do {
                try await user?.delete()
                // here lets also make sure that we log the user out as well
                do {
                    try await deAuthenticateWithFirebase()
                } catch {
                    service?.authService(.email(nil, nil), didFailToAuthenticate: error)
                }
            } catch {
                service?.authService(.email(nil, nil), didFailToAuthenticate: error)
            }
        } catch {
            service?.authService(.email(nil, nil), didFailToAuthenticate: error)
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            service?.authService(.email(nil, nil), didFailToAuthenticate: error)
        }
    }
}

protocol BackendService {
    func authenticateWithFirebase(emailID: String, password: String) async throws
    func createAndAuthenticateUser(email: String, password: String) async throws
    func deAuthenticateWithFirebase() async throws
    func checkUserAuthStatus()
    func deleteUser(email: String, password: String) async throws
    func resetPassword(email: String) async throws
}

// just as above, we can have a backend service that confirms to the backend service protocol
