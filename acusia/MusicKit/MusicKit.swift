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

    func requestMusicAuthorization() {
        Task {
            let authorizationStatus = await MusicAuthorization.request()
            if authorizationStatus == .authorized {
                isAuthorizedForMusicKit = true
            } else {
                // User denied permission.
            }
        }
    }
    
    func loadRecentlyPlayedSongs() async {
        do {
            let request = MusicRecentlyPlayedRequest<Song>()
            let response = try await request.response()
            print("\(response)")
        } catch {
            print("Failed to load recently played songs: \(error)")
        }
    }
    
    // Loading recently played containers
    func loadRecentlyPlayed() async {
        do {
            let request = MusicRecentlyPlayedContainerRequest()
            let response = try await request.response()
            print("\(response)")
        } catch {
            print("Failed to load recently played: \(error)")
        }
    }
}
