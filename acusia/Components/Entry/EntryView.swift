//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import BigUIPaging
import SwiftUI

struct Entry: View {
    @EnvironmentObject private var safeAreaInsetsManager: SafeAreaInsetsManager

    let entry: APIEntry
    let onDelete: (String) async -> Void

    @Binding var expandedEntryId: String?

    // Entry is halfway past scrollview.
    @State private var isVisible: Bool = false

    // First controls the sheet visibility. Second controls animation.
    @State private var showReplySheet = false
    @State private var animateReplySheet = false

    // Helps to offset the selected entry to the top of the screen.
    @State private var repliesOffset: CGFloat = 0
    @State private var entryHeight: CGFloat = 0

    var body: some View {
        let imageUrl = entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"

        // Entry
        // Avatar, Text, and Thread Line
        HStack(alignment: .bottom, spacing: 12) {
            AvatarView(size: animateReplySheet ? 24 : 36, imageURL: entry.author.image)

            CardDeck(entry: entry)
                .frame(width: 204, height: 280)

//                if !sampleComments.isEmpty {
//                    GeometryReader { geometry in
//                        VStack {
//                            Spacer()
//
//                            BottomCurvePath()
//                                .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
//                                .frame(width: 40, height: geometry.size.height / 2)
//                                .rotationEffect(.degrees(180))
//                                .padding(.bottom, 8)
//                                .overlay(
//                                    ZStack {
//                                        ForEach(0 ..< 3) { index in
//                                            AvatarView(size: 16, imageURL: "https://picsum.photos/200/300")
//                                                .clipShape(Circle())
//                                                .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
//                                                .offset(tricornOffset(for: index))
//                                        }
//                                    }
//                                    .frame(width: 40, height: 40)
//                                    .offset(x: 0, y: 48),
//                                    alignment: .bottom
//                                )
//                        }
//                        .opacity(animateReplySheet ? 0 : 1)
//                        .onTapGesture {
//                            showReplySheet = true
//                        }
//                    }
//                    .frame(width: 40)
//                }
        }
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .padding(.horizontal, 24)
        .onScrollVisibilityChange(threshold: 0.5) { visibility in
            isVisible = visibility
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        entryHeight = geometry.size.height
                    }
                    .onChange(of: showReplySheet) { _, new in
                        withAnimation {
                            if new {
                                // Measure the top of the entry from the top of the screen.
                                repliesOffset = geometry.frame(in: .global).minY - 32
                                animateReplySheet = true
                                expandedEntryId = entry.id
                            } else {
                                repliesOffset = 0
                                animateReplySheet = false
                                expandedEntryId = nil
                            }
                        }
                    }
            }
        )
        /// Move the entry view to the top of the screen.
        .offset(y: animateReplySheet ? 32 - repliesOffset : 0)
        .sheet(isPresented: $showReplySheet) {
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 45, bottomLeadingRadius: 55, bottomTrailingRadius: 55, topTrailingRadius: 45, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
                    .fill(Color.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(1)
                    .ignoresSafeArea()

                // Sheet content
                ScrollView {
                    // Content
                    LazyVStack(alignment: .leading) {
                        CommentsListView(replies: sampleComments)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .presentationDetents([.fraction(0.85), .large])
            .presentationCornerRadius(45)
            .presentationBackground(.black)
            .presentationDragIndicator(.visible)
        }
    }
}

struct CardDeck: View {
    @Namespace private var namespace
    let entry: APIEntry
    @State private var selection: Int = 1

    var body: some View {
        let imageUrl = entry.sound.appleData?.artworkUrl.replacingOccurrences(of: "{w}", with: "720").replacingOccurrences(of: "{h}", with: "720") ?? "https://picsum.photos/300/300"

        // Use ForEach with a collection of identifiable data
        PageView(selection: $selection) {
            ForEach([1, 2], id: \.self) { index in
                if index == 1 {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .foregroundStyle(
                            .ultraThickMaterial
                        )
                        .background(
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Rectangle()
                            }
                        )
                        .overlay(alignment: .topLeading) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(entry.text)
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .semibold))
                                    .multilineTextAlignment(.leading)

                                Spacer()
                                VStack(alignment: .leading) {
                                    Text(entry.sound.appleData?.artistName ?? "Unknown")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 11, weight: .regular))
                                        .lineLimit(1)

                                    Text(entry.sound.appleData?.name ?? "Unknown")
                                        .foregroundColor(.white)
                                        .font(.system(size: 11, weight: .regular))
                                        .lineLimit(1)
                                }
                            }
                            .padding(20)
                        }
                } else {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .background(.clear)
                        .overlay(alignment: .bottom) {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 32))
                            } placeholder: {
                                Rectangle()
                            }
                        }
                }
            }
        }
        .pageViewStyle(.customCardDeck)
        .pageViewCardCornerRadius(32.0)
        .pageViewCardShadow(.visible)
    }

    var indicatorSelection: Binding<Int> {
        .init {
            selection - 1
        } set: { newValue in
            selection = newValue + 1
        }
    }
}

struct VerticalSquigglyLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let amplitude: CGFloat = 5 // Lower amplitude for less squiggle
        let wavelength: CGFloat = 40 // Higher wavelength for gentler squiggle

        // Start straight
        path.move(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height * 0.1)) // 10% of the height as straight

        // Draw squiggly part
        var y: CGFloat = rect.height * 0.1
        while y < rect.height * 0.9 {
            let x = sin(y / wavelength * .pi * 2) * amplitude + rect.midX
            path.addLine(to: CGPoint(x: x, y: y))
            y += 1
        }

        // End straight
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))

        return path
    }
}
