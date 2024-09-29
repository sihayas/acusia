//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import Combine
import SwiftUI


struct EntryModel : Identifiable {
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
        userImage: "https://picsum.photos/300/300",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/6a/0c/2e/6a0c2e21-e649-0ea3-07ff-b2a66daf7ac5/24UMGIM24898.rgb.jpg/600x600bb.jpg",
        name: "In A Landscape",
        artistName: "Max Richter",
        text: "Strikes a pleasing equilibrium between music to admire and music to enjoy",
        rating: 2
    ),
    EntryModel(
        username: "indie_fan",
        userImage: "https://picsum.photos/300/300",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music114/v4/df/8d/f1/df8df1a2-34b2-9588-b059-ff81d1525dd5/656605144269.jpg/600x600bb.jpg",
        name: "Stranger In The Alps",
        artistName: "Phoebe Bridgers",
        text: "Don't get the big deal with this one tbh",
        rating: 0
    ),
    EntryModel(
        username: "florence_fanatic",
        userImage: "https://picsum.photos/300/300",
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
            VStack(spacing: 32) {
                ForEach(entries) { entry in // Use entries directly
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
