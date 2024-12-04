//
//  JWT.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import Foundation

func decodeJWT(_ token: String) -> String? {
    let parts = token.split(separator: ".")
    guard parts.count == 3 else {
        print("JWT does not have the required three parts.")
        return nil
    }
    
    let payload = String(parts[1])
    let paddedPayload = payload.padding(toLength: ((payload.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
    
    guard let payloadData = Data(base64Encoded: paddedPayload) else {
        print("Failed to decode base64 payload.")
        return nil
    }
    
    do {
        if let payloadJSON = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
           let userId = payloadJSON["sub"] as? String
        {
            print("Decoded JWT payload: \(payloadJSON)")
            return userId
        } else {
            print("Payload does not contain 'sub'.")
        }
    } catch {
        print("Failed to parse JSON payload: \(error)")
    }
    
    return nil
}
