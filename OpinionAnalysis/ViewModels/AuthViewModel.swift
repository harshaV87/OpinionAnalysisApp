//
//  AuthViewModel.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 6/28/23.
//

import Foundation
import SwiftUI

class AuthViewModel: ObservableObject, AuthDelegate {
    // MARK: User auth interface
    lazy var userAuthenticator = UserAuthenticator(delegate: self)
    // MARK: Biometric Service
    var biometricManager: biometricService?
   // MARK: Properties
    @Published var userSessionActive: Bool?
    @Published var userInfoOnStart: UserInfo?
    @Published var outputError: ErrorItem? = nil
    @Published var showAlertError: Bool?
    @Published var showFaceIdCredntialSave: Bool?
    @Published var biometryType: Int = 0
    // MARK: User info to get that on start of the auth model
     var userInfo: UserInfo? {
        get {
            return userInfoOnStart
        }
        set {
            // MARK: Set up userinfo and also biometric type
            DispatchQueue.main.async { [weak self] in
                self?.userInfoOnStart = newValue
                self?.biometryType = self?.biometricManager?.biometryType.rawValue ?? 0
                if KeychainStorage.getCredentials() == nil {
                    self?.showFaceIdCredntialSave = true
                }
            }
        }
    }
    // MARK: Init
    init(biometricManager: biometricService) {
        // MARK: User session check on start
        userAuthenticator.userSessionCheck(type: .email(nil, nil))
        self.biometricManager = biometricManager
    }
    
    // MARK: Signing in
    func signIn(withEmail email: String, withPassword password: String, usingBiometrics: Bool, saveCredentials: Bool) async throws {
        // MARK: Key chain storage for credentials for biometrics
        let credentials = KeychainStorage.getCredentials()
        // MARK: Biometric Option
        if usingBiometrics {
            try? await biometricManager?.authenticateWithBiometrics()
            if biometricManager?.isAuthenticated == true {
       // MARK: Biometric Auth success - Credntial nil , save an alert or else just get credentials and login
                if credentials == nil {
                    // MARK: No Credentials in key chain
                    DispatchQueue.main.async { [weak self] in
                        self?.outputError = ErrorItem(error: BiometricAuthenticationError.credentialsDoNotExist) // MARK: Show alert credntials do not exist and we need to save after next login
                    }
                } else {
                   // MARK: Otherwise you can try and login - credntials can be saved or not
                    try? await userAuthenticator.authenticate(type: .email( credentials?.email, credentials?.password))
                    DispatchQueue.main.async {
                        self.showFaceIdCredntialSave = false
                    }
                }
            } else {
               // MARK: Error - Biometric error, Biometry Failed
                let errorFromBiometrics = biometricManager?.authError
                if errorFromBiometrics != nil {
                    DispatchQueue.main.async { [weak self] in
                        self?.outputError = ErrorItem(error: errorFromBiometrics!)
                    }
                }
            }
        } else {
            // MARK: Biometrics - Not using BIOMETRICS - Save Credntials
            if saveCredentials {
               // MARK: Credential save - Save Credentials first and when it is success then authenticate
                let credentialsToSave = Credentials(email: email, password: password)
                if KeychainStorage.saveCredentials(credentialsToSave) {
                    try? await userAuthenticator.authenticate(type: .email( email, password))
                } else {
                    // Error
                }
            } else {
                // MARK: No Credntial - Only login
                try? await userAuthenticator.authenticate(type: .email( email, password))
            }
        }
    }
    
    // MARK: Create user
    func createUser(withEmail email: String, withPassword: String) async throws {
        try? await userAuthenticator.makeUserAndAuthenticate(type: .email(email, withPassword))
    }
    
    // MARK: Sign the user out
    func signOut() async throws {
        try? await userAuthenticator.deauthenticate(type: .email(nil, nil))
    }
    
    // MARK: Delete the account
    func deleteAccount(withEmail email: String, withPassword password: String) async throws {
       try? await userAuthenticator.deleteUser(type: .email(email, password))
    }
    
   // MARK: Reset password
    func resetPassword(withEmail email: String) async throws {
        try? await userAuthenticator.sendPasswordReset(type: .email(email, nil))
    }
}


extension AuthViewModel: AuthServiceDelegate {
    
    // MARK: Computed property - User logged in
    var userAlreadyLoggedIn: Bool {
        get {
           return false
        }
        set {
            DispatchQueue.main.async { [weak self] in
                self?.userSessionActive = newValue
            }
        }
    }
    
    // MARK: Auth Success
    func authService(_ authService: PreferredAuthMethod, didAuthenticate user: UserInfo) {
        DispatchQueue.main.async {
            self.userInfo = user
            self.showFaceIdCredntialSave = false
        }
    }
    
    // MARK: Auth Failure - Error
    func authService(_ authService: PreferredAuthMethod, didFailToAuthenticate error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.outputError = ErrorItem(error: error!)
            self?.showAlertError = true
         // Any Errror, ,lets delete the saved credentials
             KeychainStorage.deleteCredentials()
            if KeychainStorage.getCredentials() == nil {
                self?.showFaceIdCredntialSave = true
            }
        }
    }
}

protocol AuthDelegate: ObservableObject {
    var biometryType: Int {get}
    var showFaceIdCredntialSave: Bool? {get}
    var userSessionActive: Bool? {get set}
    var outputError: ErrorItem? {get set}
    var showAlertError: Bool? {get set}
    func signIn(withEmail email: String, withPassword: String, usingBiometrics: Bool, saveCredentials: Bool) async throws
    func createUser(withEmail email: String, withPassword password: String) async throws
    func signOut() async throws
    func deleteAccount(withEmail email: String, withPassword password: String) async throws
    func resetPassword(withEmail email: String) async throws
}









// MARK: VIEW MODEL
// MARK: AUTHVIEWMODEL - UserAuthenticator(delegate: self) (userauthenticator is a class)- DELEGATE IS AuthServiceDelegate AS AuthViewModel comfrims to that protocol
// MARK: Then the UserAuthenticator has a service AuthService and in the viewmodels we call as userAuthenticator.userSessionCheck
// MARK: About the service - service: AuthService?, we initialise it differently in different methods such as service = type.getService(delegate: source) and then call that service -  try? await service?.deauthenticate() - Service depends on the source
// MARK: THEN IN preferred method , we can set the source - such as this - case .email(let email, let password): FirebaseAuthService(delegate: delegate, email: email, passWord: password) - so everytime we use the source of email and pasword, we are esentially ising firebase like the above
// MARK: Then in the firebaseauthservice - we have - delegate: AuthServiceDelegate? and backendAuth: BackendService?
// MARK: IN THE Firebaseauthservice we have a backend auth - fireBaseBackend(service: delegate)
// MARK: and in the fireBaseBackend we have the service AuthServiceDelegate and inject that into this delegate
// MARK: The service can inject enything they want into it 
// MARK: The viewmodels can actually confirm to the Authservice delegate that gives all the return values in AuthServiceDelegate - which is the self in UserAuthenticator(delegate: self)
