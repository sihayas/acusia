//
//  FeedAPI.swift
//  acusia
//
//  Created by decoherence on 6/11/24.
//

import SwiftUI

class FeedAPI {
    private let baseURL = URL(string: apiurl)!
    
    func fetchEntries(userId: String, pageUserId: String?, page: Int) async throws -> APIFeedResponse {
        let endpoint = pageUserId != nil ? "user/feed" : "feed"
        var components = URLComponents(url: baseURL.appendingPathComponent("api/\(endpoint)"), resolvingAgainstBaseURL: true)
        
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "userId", value: userId)
        ]
        
        if let pageUserId = pageUserId {
            queryItems.append(URLQueryItem(name: "pageUserId", value: pageUserId))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(APIFeedResponse.self, from: data)
    }
    
    private func sendRequest(endpoint: String, body: [String: Any]) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("api/\(endpoint)"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
