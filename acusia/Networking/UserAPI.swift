//
//  UserAPI.swift
//  acusia
//
//  Created by decoherence on 6/11/24.
//
import SwiftUI

struct UserAPI {
    private let baseURL = URL(string: "\(apiurl)/api")!
    
    func fetchUserData(id: String, pageUserId: String? = nil) async throws -> UserResponse {
        let endpoint = pageUserId != nil ? "user" : "user/auth"
        let queryItems = pageUserId != nil
            ? [URLQueryItem(name: "userId", value: id), URLQueryItem(name: "pageUserId", value: pageUserId)]
            : [URLQueryItem(name: "authUserId", value: id)]
        
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(UserResponse.self, from: data)
    }
    
    
    func followUser(currentUserId: String, targetUserId: String, username: String) async throws {
        try await sendRequest(endpoint: "user/follow", body: ["userId": currentUserId, "targetUserId": targetUserId, "username": username])
    }
    
    func unfollowUser(currentUserId: String, targetUserId: String) async throws {
        try await sendRequest(endpoint: "user/unfollow", body: ["userId": currentUserId, "targetUserId": targetUserId])
    }
    
    func sendDeviceTokenToServer(data: Data, userId: String) async throws {
        let deviceToken = data.map { String(format: "%02.2hhx", $0) }.joined()
        try await sendRequest(endpoint: "devices", body: ["device_token": deviceToken, "user_id": userId])
    }
    
    private func sendRequest(endpoint: String, body: [String: Any]) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
