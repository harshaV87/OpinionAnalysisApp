//
//  BiometricServiceManager.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 10/31/23.
//

import Foundation
import LocalAuthentication


class BiometricManager: ObservableObject, biometricService {
    
    private(set) var context = LAContext()
    private(set) var canEvaluatePolicy = false
    
    @Published private(set) var biometryType: LABiometryType = .none
    @Published private(set) var isAuthenticated = false
    @Published private(set) var errorDescription: String?
    @Published private(set) var error: NSError?
    @Published private(set) var authError: BiometricAuthenticationError? = nil
    @Published var showAlert = false
   
    
    init() {
        setPolicyAndGetBiometry()
    }
    
    func setPolicyAndGetBiometry() {
        // we can use other policies to evaluate
        canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        // set biometry type
        biometryType = context.biometryType
    }
    
    func authenticateWithBiometrics() async {
        // lets start with the context and create a new instance of the context
        context = LAContext()
        if let error = error {
            switch error.code {
            case -6:
                authError = .deniedAccess
            case -7:
                if biometryType == .none {
                    authError = .biometricError
                } else if biometryType == .faceID {
                    authError = .faceIDNotEnrolled
                } else if biometryType == .touchID {
                    authError = .touchIDNotEnrolled
                }
            default:  authError = .biometricError
            }
        }
        if canEvaluatePolicy {
            // this means biometrics are available
            var reason = ""
            switch biometryType {
            case .faceID : reason = "Log into your account using your faceid"
            case .touchID : reason = "Log into your account using your touchid"
            default : reason = "Biometric login not available, Please login with your userName and password"
            }
            do {
                let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                if success {
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                    }
                }
            } catch {
                biometryType = .none
                showAlert = true
                errorDescription = error.localizedDescription
                authError = .biometricError
            }
        } else {
            // biometrics are unfortunately not available
            biometryType = .none
        }
    }
}


// lets create a protocol here


protocol biometricService {
    var biometryType: LABiometryType {get}
    var isAuthenticated : Bool {get}
    var authError: BiometricAuthenticationError? {get}
    var showAlert : Bool {get}
    func setPolicyAndGetBiometry()
    func authenticateWithBiometrics() async throws
}



enum BiometricAuthenticationError: Error, LocalizedError,Identifiable {
    case invalidCredentials
    case deniedAccess
    case faceIDNotEnrolled
    case touchIDNotEnrolled
    case biometricError
    case credentialsDoNotExist
    
    var id: String {
        return self.localizedDescription
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return NSLocalizedString("Either your email or password are incorrect", comment: "email password login case")
        case .deniedAccess: return NSLocalizedString("You have denied access. Please go to the settings, locate this application and allow permissions to use your biometrics ", comment: "biometric access denial case")
        case .faceIDNotEnrolled : return NSLocalizedString("You have not registered your faceID yet. Please go to the settings and activate them ", comment: "face id not enrolled")
        case .touchIDNotEnrolled : return NSLocalizedString("You have not registered your touchID yet. Please go to the settings and activate them ", comment: "touch id not enrolled")
        case .biometricError : return NSLocalizedString("Something went wrong with your biometrics. ", comment: "other errors")
        case .credentialsDoNotExist : return NSLocalizedString("Credentials are not saved, Please login with your email and password and select the option of CONTINUE WITH SAVING", comment: "other errors")
        }
    }
}

