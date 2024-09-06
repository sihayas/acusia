//
//  MusicKitModel.swift
//  acusia
//
//  Created by decoherence on 8/20/24.
//
import MusicKit
import SwiftUI

struct SongModel: Identifiable {
    let id: String
    let artwork: Artwork?
    let customArtwork: CustomArtwork?
    let artistName: String
    let lastPlayedDate: Date?
    let libraryAddedDate: Date?
    let releaseDate: Date?
    let title: String
    let albumName: String?
    let isrc: String?
    let playCount: Int?
}

struct AlbumModel: Identifiable {
    let id: String
    let artwork: Artwork?
    let artistName: String
    let isSingle: Bool?
    let lastPlayedDate: Date?
    let libraryAddedDate: Date?
    let releaseDate: Date?
    let title: String
    let upc: String?
}

enum SearchResult: Identifiable, Equatable, Hashable {
    case song(SongModel)
    case album(AlbumModel)
    
    var id: String {
        switch self {
        case .song(let song):
            return song.id
        case .album(let album):
            return album.id
        }
    }
    
    var artwork: Artwork? {
        switch self {
        case .song(let song):
            return song.artwork
        case .album(let album):
            return album.artwork
        }
    }
    
    var title: String {
        switch self {
        case .song(let song):
            return song.title
        case .album(let album):
            return album.title
        }
    }
    
    var artistName: String {
        switch self {
        case .song(let song):
            return song.artistName
        case .album(let album):
            return album.artistName
        }
    }
    
    var type: String {
        switch self {
        case .song:
            return "Song"
        case .album:
            return "Album"
        }
    }
    
    static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
