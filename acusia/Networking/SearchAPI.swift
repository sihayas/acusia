//
//  SearchAPI.swift
//  InstagramTransition
//
//  Created by decoherence on 5/23/24.
//

import Foundation
import SwiftUI

class SearchAPI {
    static func search(query: String) async throws -> SearchAPIResponse {
        let urlString = "\(apiurl)/api/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SearchAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let searchResponse = try JSONDecoder().decode(SearchAPIResponse.self, from: data)
        
        return searchResponse
    }
}
