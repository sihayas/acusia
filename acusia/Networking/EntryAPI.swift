//
//  EntryAPI.swift
//  acusia
//
//  Created by decoherence on 7/14/24.
//
import SwiftUI

struct EntryAPI {
    private let baseURL = URL(string: "\(apiurl)/api")!
    
    func submitEntry(userId: String, text: String, appleData: APIAppleSoundData, rating: Int, soundId: String?) async throws -> GenericResponse {
        let appleDataJSON = try JSONEncoder().encode(appleData)
        let appleDataDict = try JSONSerialization.jsonObject(with: appleDataJSON, options: []) as? [String: Any] ?? [:]
        
        var body: [String: Any] = [
            "userId": userId,
            "text": text,
            "apple_data": appleDataDict,
            "rating": rating
        ]
        
        if let soundId = soundId {
            body["soundId"] = soundId
        }
        
        let (data, _) = try await sendRequest(endpoint: "entry/submit", body: body)
        return try JSONDecoder().decode(GenericResponse.self, from: data)
    }
    
    func deleteEntry(userId: String, entryId: String) async throws -> GenericResponse {
        let body: [String: Any] = [
            "userId": userId,
            "entryId": entryId
        ]
        
        let (data, _) = try await sendRequest(endpoint: "entry/delete", body: body)
        return try JSONDecoder().decode(GenericResponse.self, from: data)
    }
    
    func tapEntry(userId: String, tapType: String, targetId: String, targetType: String,  targetAuthorId: String, soundId: String) async throws -> GenericResponse {
         let body: [String: Any] = [
             "userId": userId,
             "tapType": tapType,
                "targetId": targetId,
                "targetType": targetType,
                "targetAuthorId": targetAuthorId,
                "soundId": soundId
         ]
         
         let (data, _) = try await sendRequest(endpoint: "tap", body: body)
         return try JSONDecoder().decode(GenericResponse.self, from: data)
     }
     
     func untapEntry(userId: String, tapType: String, targetId: String, targetType: String,  targetAuthorId: String, soundId: String) async throws -> GenericResponse {
         let body: [String: Any] = [
            "userId": userId,
            "tapType": tapType,
            "targetId": targetId,
            "targetType": targetType,
            "targetAuthorId": targetAuthorId,
            "soundId": soundId
         ]
         
         let (data, _) = try await sendRequest(endpoint: "untap", body: body)
         return try JSONDecoder().decode(GenericResponse.self, from: data)
     }
    
    private func sendRequest(endpoint: String, body: [String: Any]) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return try await URLSession.shared.data(for: request)
    }
}

struct GenericResponse: Codable {
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case success
    }
}
