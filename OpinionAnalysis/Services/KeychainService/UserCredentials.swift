//
//  UserCredentials.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 11/1/23.
//

import Foundation
import SwiftKeychainWrapper

struct Credentials: Codable {
    var email : String = ""
    var password: String = ""
    
    func encoded() -> String? {
        let encoder = JSONEncoder()
       if let credentialsData = try? encoder.encode(self)
        {
           return String(data: credentialsData, encoding: .utf8)!
       } else {
           return nil
       }
       
    }
    
    static func decode(credsentialString: String) -> Credentials {
        let decoder = JSONDecoder()
        let jsonData = credsentialString.data(using: .utf8)!
        return try! decoder.decode((Credentials.self), from: jsonData)
    }
}

enum KeychainStorage {
    static let key = "credentials"
    
    static func getCredentials() -> Credentials? {
        if let myCredentialString = KeychainWrapper.standard.string(forKey: Self.key) {
            return Credentials.decode(credsentialString: myCredentialString)
        }
        return nil
    }
    
    static func saveCredentials(_ credentials: Credentials) -> Bool {
        if KeychainWrapper.standard.set(credentials.encoded()!, forKey: Self.key) {
            return true
        }
        return false
    }
    
    static func deleteCredentials() {
        KeychainWrapper.standard.removeObject(forKey: Self.key)
    }
}

