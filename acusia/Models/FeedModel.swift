//
//  FeedModel.swift
//  vaela
//
//  Created by decoherence on 4/29/24.
//

import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var entries: [APIEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var canLoadMore = true
    
    private let feedAPI: FeedAPI
    private let userId: String
    private let pageUserId: String?
    
    init(userId: String, pageUserId: String? = nil) {
        self.userId = userId
        self.pageUserId = pageUserId
        self.feedAPI = FeedAPI()
    }
    
    var hasMorePages: Bool {
        return entries.count % 8 == 0 && entries.count > 0
    }
    
    func removeEntry(id: String) {
        entries.removeAll { $0.id == id }
    }
    
    @MainActor
    func fetchEntries() async {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        
        do {
            let response = try await feedAPI.fetchEntries(userId: userId, pageUserId: pageUserId, page: currentPage)
            entries.append(contentsOf: response.entries)
            currentPage += 1
            canLoadMore = response.pagination.hasNextPage
        } catch {
            errorMessage = error.localizedDescription
            canLoadMore = false
        }
        
        isLoading = false
    }
}

struct APIFeedResponse: Codable {
    let entries: [APIEntry]
    let pagination: Pagination
}

struct Pagination: Codable {
    let currentPage: Int
    let hasNextPage: Bool
    let nextPage: Int?
}

struct APIEntry: Codable, Identifiable, Hashable {
    let id: String
    let sound: APISound
    let type: String
    let authorId: String
    let text: String
    let rating: Double
    let loved: Bool
    let replay: Bool
    let heartCount: Int
    let flameCount: Int
    let thumbsDownCount: Int
    let createdAt: String
    let author: APIUser
    let isHeartTapped: Bool
    let isFlameTapped: Bool
    let isThumbsDownTapped: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case sound
        case type
        case authorId = "author_id"
        case text
        case rating
        case loved
        case replay
        case heartCount = "heart_count"
        case flameCount = "flame_count"
        case thumbsDownCount = "thumbs_down_count"
        case createdAt = "created_at"
        case author
        case isHeartTapped
        case isFlameTapped
        case isThumbsDownTapped
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        sound = try container.decode(APISound.self, forKey: .sound)
        type = try container.decode(String.self, forKey: .type)
        authorId = try container.decode(String.self, forKey: .authorId)
        text = try container.decode(String.self, forKey: .text)
        rating = try container.decode(Double.self, forKey: .rating)
        loved = try container.decode(Bool.self, forKey: .loved)
        replay = try container.decode(Bool.self, forKey: .replay)
        heartCount = try container.decode(Int.self, forKey: .heartCount)
        flameCount = try container.decode(Int.self, forKey: .flameCount)
        thumbsDownCount = try container.decode(Int.self, forKey: .thumbsDownCount)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        author = try container.decode(APIUser.self, forKey: .author)
        isHeartTapped = try container.decode(Bool.self, forKey: .isHeartTapped)
        isFlameTapped = try container.decode(Bool.self, forKey: .isFlameTapped)
        isThumbsDownTapped = try container.decode(Bool.self, forKey: .isThumbsDownTapped)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(sound, forKey: .sound)
        try container.encode(type, forKey: .type)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(text, forKey: .text)
        try container.encode(rating, forKey: .rating)
        try container.encode(loved, forKey: .loved)
        try container.encode(replay, forKey: .replay)
        try container.encode(heartCount, forKey: .heartCount)
        try container.encode(flameCount, forKey: .flameCount)
        try container.encode(thumbsDownCount, forKey: .thumbsDownCount)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(author, forKey: .author)
        try container.encode(isHeartTapped, forKey: .isHeartTapped)
        try container.encode(isFlameTapped, forKey: .isFlameTapped)
        try container.encode(isThumbsDownTapped, forKey: .isThumbsDownTapped)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: APIEntry, rhs: APIEntry) -> Bool {
        lhs.id == rhs.id
    }
}


struct APISound: Codable {
    let id: String
    let appleId: String
    let type: String
    let appleData: APIAppleSoundData?
    
    enum CodingKeys: String, CodingKey {
        case id, type
        case appleId = "apple_id"
        case appleData = "apple_data"
    }
}


struct APIAppleSoundData: Codable, Hashable {
    let id: String
    let type: String
    let name: String
    let artistName: String
    let albumName: String?
    let releaseDate: String
    let artworkUrl: String
    let artworkBgColor: String
    let identifier: String
    let trackCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, type, name
        case artistName = "artist_name"
        case albumName = "album_name"
        case releaseDate = "release_date"
        case artworkUrl = "artwork_url"
        case artworkBgColor = "artwork_bgColor"
        case identifier
        case trackCount = "track_count"
    }
}
