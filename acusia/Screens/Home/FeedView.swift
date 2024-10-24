//
//  FeedScreen.swift
//  acusia
//
//  Created by decoherence on 6/12/24.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var windowState: WindowState

    @State private var tappedEntry: EntryModel?
    @State private var tappedPosition: CGPoint = .zero
    @State private var tappedSize: CGSize = .zero

    var body: some View {
        ScrollView {
            // GridView(
            //     id: "3f6a2219-8ea1-4ff1-9057-6578ae3252af",
            //     username: "decoherence",
            //     image: "https://i.pinimg.com/474x/45/8a/ce/458ace69027303098cccb23e3a43e524.jpg"
            // )

            LazyVStack(spacing: 64) {
                ForEach(entries) { entry in
                    ZStack {
                        if entry.rating == 2 {
                            WispView(entry: entry)
                        } else {
                            ArtifactView(entry: entry)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        GeometryReader { geometry in
                            Color.black.onTapGesture {
                                if tappedEntry != nil {
                                    withAnimation(.smooth) {
                                        tappedEntry = nil
                                    }
                                } else {
                                    withAnimation(.smooth) {
                                        tappedEntry = (tappedEntry == entry) ? nil : entry
                                    }
                                    tappedPosition = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY)
                                    tappedSize = geometry.size
                                }
                            }
                        })
                    .scaleEffect(tappedEntry != nil && tappedEntry != entry ? 0.96 : 1)
                    .animation(.interactiveSpring(duration: 0.4, extraBounce: 0.5), value: tappedEntry)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollClipDisabled(true)
        .frame(width: windowState.size.width, height: windowState.size.height)
        .overlay(
            ZStack {
                if tappedEntry != nil {
                    RadialVariableBlurView(radius: 4, position: tappedPosition, size: tappedSize)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    RadialGradientMask(center: tappedPosition, size: tappedSize)
                }
            }
            .allowsHitTesting(false)
        )
        .onScrollGeometryChange(for: CGFloat.self) { proxy in
            proxy.contentOffset.y
        } action: { _, newValue in
            if newValue > windowState.size.height {
                windowState.symmetryState = .feed
            } else {
                windowState.symmetryState = .collapsed
            }
        }
    }
}

struct EntryModel: Equatable, Identifiable {
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
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/09/7d/b0/097db06f-8403-3cf7-7510-139e570ca66b/196871341882.jpg/1000x1000bb.jpg",
        name: "Utopia",
        artistName: "Travis Scott",
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
    ),
    EntryModel(
        username: "florence_fanatic",
        userImage: "https://i.pinimg.com/474x/43/07/28/430728c5b11e576df3e85652a96b7afb.jpg",
        imageUrl: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/bd/f6/83/bdf683a5-28de-08cb-cb91-2940c1e6270b/196871853729.jpg/1000x1000bb.jpg",
        name: "Cowboy Carter",
        artistName: "Beyonce",
        text: "Florence is a queen. I can go on and on about what she means to me but I won’t",
        rating: 0
    ),
    EntryModel(
        username: "bey",
        userImage: "https://wallpapers.com/images/hd/oscar-zahn-skeleton-headphones-unique-cool-pfp-rboah21ctf7m37o0.jpg",
        imageUrl: "https://i.scdn.co/image/ab67616d0000b2736c7112082b63beefffe40151",
        name: "Kid A",
        artistName: "Radiohead",
        text: "This album is closest a band can get to perfection. Abstract yet poignant, Kid A is an album filled with contradiction fusing elements of acid, rock, folk, trance and house together to create a truly experimental and epic album.",
        rating: 0
    )
]
