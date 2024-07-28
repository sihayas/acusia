//
//  MusicKit.swift
//  acusia
//
//  Created by decoherence on 7/16/24.
//

import MusicKit
import SwiftUI

class MusicPlayer: ObservableObject {
    private let applicationPlayer = ApplicationMusicPlayer.shared
    @Published var isAuthorized = false
    @Published var canPlayCatalogContent = false
    @Published var currentQueueIndex: Int = 0

    init() {
        Task {
            await checkAuthorization()
        }
    }

    func checkAuthorization() async {
        let status = await MusicAuthorization.request()
        DispatchQueue.main.async {
            self.isAuthorized = status == .authorized
        }
        await updateSubscriptionStatus()
    }

    func updateSubscriptionStatus() async {
        do {
            let subscription = try await MusicSubscription.current
            DispatchQueue.main.async {
                self.canPlayCatalogContent = subscription.canPlayCatalogContent
            }
        } catch {
            print("Error fetching subscription status: \(error)")
        }
    }
    
    func updateQueue(with entries: [APIEntry]) async {
        guard isAuthorized && canPlayCatalogContent else {
            print("Not authorized or cannot play catalog content")
            return
        }

        var queueEntries: [ApplicationMusicPlayer.Queue.Entry] = []

        for entry in entries {
            guard let appleData = entry.sound.appleData else { continue }

            let musicItemID = MusicItemID(appleData.id)
            
            do {
                switch appleData.type {
                case "songs":
                    let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                    let response = try await request.response()
                    if let song = response.items.first {
                        queueEntries.append(.init(song))
                    }
                case "albums":
                    var albumRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: musicItemID)
                    albumRequest.properties = [.tracks]
                    let albumResponse = try await albumRequest.response()
                    
                    if let album = albumResponse.items.first, let tracks = album.tracks {
                        for track in tracks {
                            queueEntries.append(.init(track))
                        }
                    }
                default:
                    continue
                }
            } catch {
                print("Error fetching music item: \(error)")
            }
        }

        applicationPlayer.queue = ApplicationMusicPlayer.Queue(queueEntries)
    }

    func jumpToItem(at index: Int) {
        Task {
            do {
                try await applicationPlayer.skipToNextEntry()
                currentQueueIndex = index
                try await applicationPlayer.play()
            } catch {
                print("Error jumping to queue item: \(error)")
            }
        }
    }

    func playSong(withId songId: String) {
        guard isAuthorized && canPlayCatalogContent else {
            print("Not authorized or cannot play catalog content")
            return
        }

        Task {
            do {
                let musicItemID = MusicItemID(songId)
                
                let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                let response = try await request.response()
                
                if let song = response.items.first {
                    applicationPlayer.queue = [song]
                    try await applicationPlayer.play()
                } else {
                    print("Song not found")
                }
            } catch {
                print("Error playing song: \(error)")
            }
        }
    }
}

struct PlayButtonView: View {
    @StateObject private var musicPlayer = MusicPlayer()
    
    let songId: String

    var body: some View {
        Button(action: {
            musicPlayer.playSong(withId: songId)
        }) {
            Image(systemName: "play.fill")
                .font(.system(size: 12))
                .foregroundColor(Color.lightBlue)
                .frame(width: 28, height: 28)
                .background(Color.darkBlue)
                .clipShape(Circle())
        }
        .disabled(!musicPlayer.isAuthorized || !musicPlayer.canPlayCatalogContent)
        .onAppear {
            Task {
                await musicPlayer.checkAuthorization()
            }
        }
    }
}
