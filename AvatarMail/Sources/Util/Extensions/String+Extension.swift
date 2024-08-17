//
//  String+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import SwiftKeychainWrapper
import Foundation


extension String {
    public static var deviceID: String {
        let uuidKey = "AvatarMail UUID"
        
        if let storedUUID = KeychainWrapper.standard.string(forKey: uuidKey) {
            return storedUUID
        } else {
            let newUUID = UUID().uuidString
            let success = KeychainWrapper.standard.set(newUUID, forKey: uuidKey)
            
            if success {
                return newUUID
            } else {
                print("Failed to save UUID to Keychain")
                return newUUID
            }
        }
    }
}
