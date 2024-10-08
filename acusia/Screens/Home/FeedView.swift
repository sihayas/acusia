//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import Combine
import SwiftUI

struct EntryModel: Identifiable {
    let id = UUID()
    let username: String
    let userImage: String
    let imageUrl: String
    let name: String
    let artistName: String
    let text: String
    let rating: Int
}

let entries: [EntryModel] = [
    EntryModel(
        username: "music_lover123",
        userImage: "https://i.pinimg.com/474x/9f/38/61/9f38614bb1acaad50e1959f4e3d5768c.jpg",
        imageUrl: "https://e.snmc.io/i/600/w/f4af27ec1e80ff187db7e9e8313cfad0/12297609/julie-my-anti-aircraft-friend-Cover-Art.jpg",
        name: "my anti-aircraft friend",
        artistName: "julie",
        text: "Strikes a pleasing equilibrium between music to admire and music to enjoy",
        rating: 2
    ),
    EntryModel(
        username: "starrry",
        userImage: "https://i.pinimg.com/474x/d8/5d/02/d85d022bedcf129ebd23a2b21e97ef19.jpg",
        imageUrl: "https://e.snmc.io/i/600/w/d236196c04741650000aea22a62f5363/12229480/coldplay-moon-music-Cover-Art.jpg",
        name: "Moon Music",
        artistName: "Coldplay",
        text: "The first impression is that there's one decent song, which was the first single, and the rest is all filler, b side material. ",
        rating: 2
    ),
    EntryModel(
        username: "indie_fan",
        userImage: "https://i.pinimg.com/474x/fb/d1/a7/fbd1a7f6066b1c94da2cf5ffdd9dba3d.jpg",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/df/8d/f1/df8df1a2-34b2-9588-b059-ff81d1525dd5/656605144269.jpg/600x600bb.jpg",
        name: "Stranger In The Alps",
        artistName: "Phoebe Bridgers",
        text: "Don't get the big deal with this one tbh",
        rating: 0
    ),
    EntryModel(
        username: "florence_fanatic",
        userImage: "https://i.pinimg.com/474x/43/07/28/430728c5b11e576df3e85652a96b7afb.jpg",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/76/96/d1/7696d110-c929-4908-8fa1-30aad2511c55/00602567485872.rgb.jpg/600x600bb.jpg",
        name: "High as Hope",
        artistName: "Florence + The Machine",
        text: "Florence is a queen. I can go on and on about what she means to me but I won’t",
        rating: 2
    )
]

struct FeedView: View {
    let userId: String

    var body: some View {
        ScrollView {
            VStack(spacing: 64) {
                ForEach(entries) { entry in
                    Entry(
                        entry: entry
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollClipDisabled(true)
        // .onAppear { Task { await viewModel.fetchEntries() } }
    }
}

struct Entry: View {
    let entry: EntryModel

    // Entry is halfway past scrollview.
    @State private var isVisible: Bool = false

    // First controls the sheet visibility. Second controls animation.
    @State private var showReplySheet = false
    @State private var animateReplySheet = false

    var body: some View {
        // Entry
        VStack {
            if entry.rating == 2 {
                WispView(entry: entry)
            } else {
                ArtifactView(entry: entry, showReplySheet: $showReplySheet)
                    .scaleEffect(animateReplySheet ? 0.4 : 1, anchor: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .onScrollVisibilityChange(threshold: 0.5) { visibility in
            isVisible = visibility
        }
    }
}
