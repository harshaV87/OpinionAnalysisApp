//
//  LoginService.swift
//  OpinionAnalysis
//
//  Created by Venkata harsha Balla on 11/8/23.
//


import Foundation
import UIKit
import SwiftUI

// enum for preferred authentication method

enum PreferredAuthMethod {
    // phone auth
    case phone(number: String)
    // email auth like firebase or any other backend
    case email(_ email: String?, _ password: String?)
    // third party auths
    case google
    case facebook
    case apple
    // new cases added here
}

// lets define a protocol

protocol AuthService {
    // property as enum
    var authType: PreferredAuthMethod {get}
    // sign in and sign out
    func authenticate() async throws
    func deauthenticate() async throws
    func getUserSession()
    func createUser() async throws
    func deleteUser() async throws
    func sendPasswordReset() async throws
}

// delegate for auth

protocol AuthServiceDelegate: AnyObject {
    var userAuthenticator: UserAuthenticator {get}
    var userAlreadyLoggedIn: Bool { get set}
    var userInfo: UserInfo? { get set }
    // adding methods for auth success and failure
    func authService(_ authService: PreferredAuthMethod, didAuthenticate user: UserInfo)
    func authService(_ authService: PreferredAuthMethod, didFailToAuthenticate error: Error?)
}

// extend auth method

extension PreferredAuthMethod {
    func getService(delegate: AuthServiceDelegate?) -> AuthService{
        switch self {
        case .phone(let number):
            return AppleAuthService(delegate: delegate)
        case .email(let email, let password):
            return FirebaseAuthService(delegate: delegate, email: email, passWord: password)
        case .google:
            return AppleAuthService(delegate: delegate)
        case .facebook:
            return AppleAuthService(delegate: delegate)
        case .apple:
            return AppleAuthService(delegate: delegate)
        }
        
    }
}

// we can create a service for the respective sdks

// For apple as example 

class AppleAuthService : NSObject, AuthService {
    
    var authType: PreferredAuthMethod = .apple
    // init with viewController and serice delegate
    
    var delegate: AuthServiceDelegate?
    // Backend Service
    var backendAuth: BackendService?
    
    init(delegate: AuthServiceDelegate?) {
        self.delegate = delegate
        self.backendAuth = fireBaseBackend(service: delegate)
    }
    
    func authenticate() {
        //backendAuth?.authenticateWithFirebase(emailID: "", password: <#String#>)
    }
    
    func deauthenticate() {
       // backendAuth?.deAuthenticateWithFirebase()
    }
    
    func getUserSession() {
        // autologin for this service
    }
    
    func createUser() {
    }
    
    func deleteUser() async throws { 
    }
    
    func sendPasswordReset() async throws { 
    }
}

// extension for apple auth service

extension AppleAuthService {
    // extensions to be passed here , including protocols
}


class FirebaseAuthService: NSObject, AuthService {
    
    var email: String?
    var passWord: String?
    
    // init with viewController and service delegate
    var delegate: AuthServiceDelegate?
    var backendAuth: BackendService?
    
    lazy var authType: PreferredAuthMethod = .email(email ?? "", passWord ?? "")
    
    init(delegate: AuthServiceDelegate?, email: String?, passWord: String?) {
        self.email = email
        self.passWord = passWord
        self.delegate = delegate
        self.backendAuth = fireBaseBackend(service: delegate)
    }
    
    func authenticate() async throws {
         try? await backendAuth?.authenticateWithFirebase(emailID: email ?? "", password: passWord ?? "")
    }
    
    func deauthenticate() async throws {
       try? await backendAuth?.deAuthenticateWithFirebase()
    }
    
    func getUserSession() {
        backendAuth?.checkUserAuthStatus()
    }
    
    func createUser() async throws {
        try? await backendAuth?.createAndAuthenticateUser(email: email ?? "", password: passWord ?? "")
    }
    
    func deleteUser() async throws {
        try? await backendAuth?.deleteUser(email: email ?? "", password: passWord ?? "")
    }
    
    func sendPasswordReset() async throws {
        try? await backendAuth?.resetPassword(email: email ?? "")
    }
}


//Typealias
typealias AuthenticationViewSource = AuthServiceDelegate

// Mediator
class UserAuthenticator {
    private weak var source: AuthenticationViewSource?
    private var service: AuthService?
    
    init(delegate: AuthenticationViewSource?) {
        self.source = delegate
    }
    
    func authenticate(type: PreferredAuthMethod) async throws {
        service = type.getService(delegate: source)
        try? await service?.authenticate()
    }
    
    func deauthenticate(type: PreferredAuthMethod) async throws {
        service = type.getService(delegate: source)
        try? await service?.deauthenticate()
    }
    
    func userSessionCheck(type: PreferredAuthMethod?) {
        service = type?.getService(delegate: source)
        service?.getUserSession()
    }
    
    func makeUserAndAuthenticate(type: PreferredAuthMethod?) async throws {
        service = type?.getService(delegate: source)
        try? await service?.createUser()
    }
    
    func deleteUser(type: PreferredAuthMethod?) async throws {
        service = type?.getService(delegate: source)
        try? await service?.deleteUser()
    }
    
    func sendPasswordReset(type: PreferredAuthMethod?) async throws {
        service = type?.getService(delegate: source)
        try? await service?.sendPasswordReset()
    }
}

// Abstraction for any service provider here



struct UserInfo {
    var userId: String
    var userEmail: String
}

struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String

}
