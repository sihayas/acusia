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
            print("\(response)")
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
                SongModel(id: song.id.rawValue, title: song.title, artistName: song.artistName, artwork: song.artwork)
            }
        } catch {
            print("Failed to load recently played songs: \(error)")
        }
    }
}
