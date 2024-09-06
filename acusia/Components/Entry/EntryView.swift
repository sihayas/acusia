//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

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
        VStack(alignment: .leading) {
            // Sound
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .foregroundStyle(.thinMaterial)
                .background(
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                    } placeholder: {
                        Rectangle()
                    }
                )
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading) {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                        } placeholder: {
                            Rectangle()
                        }
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 8)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text(entry.sound.appleData?.artistName ?? "")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .lineLimit(1)
                            
                            Text(entry.sound.appleData?.name ?? "")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .lineLimit(1)
                        }
                        .padding([.horizontal, .bottom], 12)
                    }
                }
                .frame(width: 224, height: 280, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.leading, 48)

            // Avatar, Text, and Thread Line
            HStack(alignment: .bottom, spacing: 12) {
                AvatarView(size: animateReplySheet ? 24 : 36, imageURL: entry.author.image)

                ZStack(alignment: .bottomLeading) {
                    Circle()
                        .stroke(animateReplySheet ? .white.opacity(0.1) : .clear, lineWidth: 1)
                        .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                        .frame(width: 6, height: 6)
                        .offset(x: -8, y: 3)

                    Circle()
                        .stroke(animateReplySheet ? .white.opacity(0.1) : .clear, lineWidth: 1)
                        .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                        .frame(width: 12, height: 12)

                    Text(entry.text)
                        .foregroundColor(.white)
                        .font(.system(size: animateReplySheet ? 11 : 15, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .transition(.blurReplace)
                        .lineLimit(animateReplySheet ? 3 : nil)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(animateReplySheet ? .black : Color(UIColor.systemGray6),
                                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color(UIColor.systemGray6).opacity(animateReplySheet ? 1 : 0), lineWidth: 1)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 3)

                if !sampleComments.isEmpty {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()

                            BottomCurvePath()
                                .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 40, height: geometry.size.height / 2)
                                .rotationEffect(.degrees(180))
                                .padding(.bottom, 8)
                                .overlay(
                                    ZStack {
                                        ForEach(0 ..< 3) { index in
                                            AvatarView(size: 16, imageURL: "https://picsum.photos/200/300")
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
                                                .offset(tricornOffset(for: index))
                                        }
                                    }
                                    .frame(width: 40, height: 40)
                                    .offset(x: 0, y: 48),
                                    alignment: .bottom
                                )
                        }
                        .opacity(animateReplySheet ? 0 : 1)
                        .onTapGesture {
                            showReplySheet = true
                        }
                    }
                    .frame(width: 40)
                }
            }
        }

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
