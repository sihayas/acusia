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

    static let shared = MusicKitManager()

    // Authorize MusicKit
    @MainActor
    func requestMusicAuthorization() async {
        let authorizationStatus = await MusicAuthorization.request()
        if authorizationStatus == .authorized {
            isAuthorizedForMusicKit = true
        } else {
            // User denied permission.
            print("User denied permission.")
        }
    }

    // Load recently played containers
    func loadRecentlyPlayed() async {
        do {
            let request = MusicRecentlyPlayedContainerRequest()
            let response = try await request.response()
            
            print("Recently played containers: \(response.items)")
        } catch {
            print("Failed to load recently played: \(error)")
        }
    }

    // Load recently played songs
    func loadRecentlyPlayedSongs() async {
        do {
            let request = MusicRecentlyPlayedRequest<Song>()
            let response = try await request.response()
            recentlyPlayedSongs = response.items.map { song in
                SongModel(
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
            print("\(recentlyPlayedSongs)")
        } catch {
            print("Failed to load recently played songs: \(error)")
        }
    }
    
    // Load catalog search top results
    func loadCatalogSearchTopResults(searchTerm: String) async -> [SearchResult] {
        var searchRequest = MusicCatalogSearchRequest(
            term: searchTerm,
            types: [
                Album.self,
                Song.self
            ]
        )
        
        searchRequest.includeTopResults = true
        
        do {
            let searchResponse = try await searchRequest.response()
            
            // Map Album results
            let albumResults = searchResponse.albums.map { album in
                SearchResult.album(
                    AlbumModel(
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
                )
            }
            
            // Map Song results
            let songResults = searchResponse.songs.map { song in
                SearchResult.song(
                    SongModel(
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
                )
            }
            
            // Combine songs and albums into a single list
            return songResults + albumResults
            
        } catch {
            print("Failed to load catalog search top results: \(error)")
            return []
        }
    }
}
