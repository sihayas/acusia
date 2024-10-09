//
//  StickerWallView.swift
//  acusia
//
//  Created by decoherence on 8/6/24.
//

import CoreMotion
import MusicKit
import SwiftUI

struct GridView: View {
    // Global Properties
    @EnvironmentObject var musicKitManager: MusicKit

    // Local Properties
    @State private var keyboardOffset: CGFloat = 0
    @State private var showSettings = false
    @State private var searchText = "joji"

    // Animation States
    @State var expandEssentialStates = [false, false, false]
    @State var showRecents = false

    // Parameters
    @Binding var homePath: NavigationPath
    let initialUserData: APIUser?
    let userResult: UserResult?
    let size: CGSize

    var body: some View {
        ZStack {
            // MARK: Sticker Interface

//            ZStack {
//            }

            // MARK: User Data & Buttons

            VStack {
                Spacer()

                ZStack {
                    AvatarView(size: 96, imageURL: "https://i.pinimg.com/474x/45/cb/21/45cb219eecb8feccc9771577666d00c6.jpg")
                    
                    Text("Alia")
                        .font(.callout)
                        .foregroundColor(Color.white)
                        .offset(y: 96 / 2 + 16)
                }

                Spacer()
            }
            .padding(.horizontal, 32)

            // MARK: - Pinned

            VStack {
                Spacer()

                // Essentials
                HStack(alignment: .bottom, spacing: -18) {
                    ForEach(Array(musicKitManager.recentlyPlayedSongs.prefix(3).enumerated()), id: \.offset) { index, song in
                        if let artwork = song.artwork {
                            ArtworkImage(artwork, width: 136, height: 136)
                                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .rotationEffect(index == 0 ? .degrees(-8) : index == 2 ? .degrees(8) : .degrees(0), anchor: .center)
                                .offset(y: index == 1 ? -8 : 0)
                                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
                                .scaleEffect(expandEssentialStates[index] ? 1.0 : 0.2, anchor: index == 0 ? .bottomTrailing : index == 2 ? .bottomLeading : .bottom)
                                .offset(x: expandEssentialStates[index] ? 0 : index == 0 ? 48 : index == 2 ? -48 : 0)
                                .zIndex(Double(index * -1))
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            for index in 0..<3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.07) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                                        expandEssentialStates[index] = true
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            for index in 0..<3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.07) {
                                    withAnimation(.spring()) {
                                        expandEssentialStates[index] = false
                                    }
                                }
                            }
                        }
                )
            }
        }
        .frame(minWidth: size.width, minHeight: size.height)
    }
}
