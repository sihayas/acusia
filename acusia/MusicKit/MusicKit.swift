//
//  MusicKit.swift
//  acusia
//
//  Created by decoherence on 8/20/24.
//

import MusicKit
import SwiftUI

class MusicKitManager: ObservableObject {
    @Published var isAuthorizedForMusicKit = false
    @Published var recentlyPlayedSongs: [SongModel] = []
    @Published var searchResults: [SearchResult] = []

    // Singleton instance
    static let shared = MusicKitManager()

    // MARK: - Authorization

    @MainActor
    func requestMusicAuthorization() async {
        let authorizationStatus = await MusicAuthorization.request()
        isAuthorizedForMusicKit = (authorizationStatus == .authorized)
        if !isAuthorizedForMusicKit {
            print("User denied permission.")
        }
    }

    // MARK: - Recently Played

    func loadRecentlyPlayed() async {
        do {
            let request = MusicRecentlyPlayedContainerRequest()
            let response = try await request.response()
            print("Recently played containers: \(response.items)")
        } catch {
            print("Failed to load recently played: \(error)")
        }
    }

    func loadRecentlyPlayedSongs() async {
        do {
            let request = MusicRecentlyPlayedRequest<Song>()
            let response = try await request.response()
            recentlyPlayedSongs = response.items.map { song in
                SongModel(from: song)
            }
            print("\(recentlyPlayedSongs)")
        } catch {
            print("Failed to load recently played songs: \(error)")
        }
    }
    
    // MARK: - Search

    func loadCatalogSearchTopResults(searchTerm: String) async -> [SearchResult] {
        var searchRequest = MusicCatalogSearchRequest(
            term: searchTerm,
            types: [Album.self, Song.self]
        )
        searchRequest.includeTopResults = true
        
        do {
            let searchResponse = try await searchRequest.response()
            
            let combinedResults = searchResponse.albums.map { album in
                SearchResult.album(AlbumModel(from: album))
            } + searchResponse.songs.map { song in
                SearchResult.song(SongModel(from: song))
            }
            
            DispatchQueue.main.async {
                self.searchResults = combinedResults
            }
            
            return combinedResults
            
        } catch {
            print("Failed to load catalog search top results: \(error)")
            DispatchQueue.main.async {
                self.searchResults = []
            }
            return [] // Return an empty array on error
        }
    }
}

// MARK: - Models

extension SongModel {
    init(from song: Song) {
        self.init(
            id: song.id.rawValue,
            artwork: song.artwork,
            artistName: song.artistName,
            lastPlayedDate: song.lastPlayedDate,
            libraryAddedDate: song.libraryAddedDate,
            releaseDate: song.releaseDate,
            title: song.title,
            albumName: song.albumTitle,
            isrc: song.isrc,
            playCount: song.playCount
        )
    }
}

extension AlbumModel {
    init(from album: Album) {
        self.init(
            id: album.id.rawValue,
            artwork: album.artwork,
            artistName: album.artistName,
            isSingle: album.isSingle,
            lastPlayedDate: album.lastPlayedDate,
            libraryAddedDate: album.libraryAddedDate,
            releaseDate: album.releaseDate,
            title: album.title,
            upc: album.upc
        )
    }
}
