//
//  SearchModel.swift
//  InstagramTransition
//
//  Created by decoherence on 5/7/24.
//
//
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchResults: [SearchResultItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let searchAPI = SearchAPI()
    
    @MainActor
    func performSearch(query: String) async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let response = try await SearchAPI.search(query: query)
            searchResults = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct SearchAPIResponse: Decodable, Hashable {
    let data: [SearchResultItem]
}


struct UserResult: Decodable, Hashable {
    let id: String
    let username: String
    let image: String
}

enum SearchResultItem: Decodable, Hashable {
    case sound(APIAppleSoundData)
    case user(UserResult)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let sound = try? container.decode(APIAppleSoundData.self) {
            self = .sound(sound)
        } else if let user = try? container.decode(UserResult.self) {
            self = .user(user)
        } else {
            throw DecodingError.typeMismatch(SearchResultItem.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown search result type"))
        }
    }
    
    var id: String {
        switch self {
        case .sound(let sound):
            return sound.id
        case .user(let user):
            return user.id
        }
    }
    
    var imageUrl: URL {
        switch self {
        case .sound(let sound):
            let urlString = sound.artworkUrl.replacingOccurrences(of: "{w}x{h}", with: "128x128")
            return URL(string: urlString)!
        case .user(let user):
            return URL(string: user.image)!
        }
    }
    
    var title: String {
        switch self {
        case .sound(let sound):
            return sound.name
        case .user(let user):
            return user.username
        }
        
    }
    
    var type: String {
        switch self {
        case .sound:
            return "sound"
        case .user:
            return "user"
        }
    }
    
    // only for sounds
    var subtitle: String {
        switch self {
        case .sound(let sound):
            return sound.artistName
        case .user:
            return ""
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .sound:
            return 8
        case .user:
            return 24
        }
    }
}

