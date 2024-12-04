//
//  Keychain.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//

import Security
import Foundation

func saveTokenToKeychain(token: String) {
    let tokenData = token.data(using: .utf8)!
    let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: "authToken" as CFString,
        kSecValueData: tokenData
    ]

    // Delete any existing item with the same key
    SecItemDelete(query as CFDictionary)

    // Add the new token
    let status = SecItemAdd(query as CFDictionary, nil)
    if status == errSecSuccess {
        print("Token saved successfully.")
    } else {
        print("Failed to save token: \(status)")
    }
}

func loadTokenFromKeychain() -> String? {
    let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: "authToken" as CFString,
        kSecReturnData: true,
        kSecMatchLimit: kSecMatchLimitOne
    ]

    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    if status == errSecSuccess, let data = dataTypeRef as? Data {
        return String(data: data, encoding: .utf8)
    }
    return nil
}

func deleteTokenFromKeychain() {
    let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrAccount: "authToken" as CFString
    ]

    let status = SecItemDelete(query as CFDictionary)
    if status == errSecSuccess {
        print("Token deleted successfully.")
    } else {
        print("Failed to delete token: \(status)")
    }
}
