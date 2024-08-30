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
        HStack(alignment:.bottom) {
            VStack(alignment: .leading, spacing: -12) {
                HStack(alignment: .bottom, spacing: 12) {
                    AvatarView(size: animateReplySheet ? 24 : 40, imageURL: entry.author.image)
                    
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
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(animateReplySheet ? .white.opacity(0.1) : .clear, lineWidth: 1)
                                    .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                                    .frame(width: 12, height: 12)
                                    .offset(x: 0, y: 0)
                                
                                Circle()
                                    .stroke(animateReplySheet ? .white.opacity(0.1) : .clear, lineWidth: 1)
                                    .fill(animateReplySheet ? .clear : Color(UIColor.systemGray6))
                                    .frame(width: 6, height: 6)
                                    .offset(x: -10, y: 6)
                            },
                            alignment: .bottomLeading
                        )
                        .padding(.bottom, 20)
                }
                
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .frame(width: animateReplySheet ? 24 : 40, height: animateReplySheet ? 24 : 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .frame(width: 40, height: 40)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(entry.sound.appleData?.artistName ?? "Unknown")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white)
                        
                        Text(entry.sound.appleData?.name ?? "Unknown")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: animateReplySheet ? 14 : 28)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            if !sampleComments.isEmpty {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        BottomCurvePath()
                            .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 40, height: geometry.size.height / 2)
                            .rotationEffect(.degrees(180))
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
                                    .offset(x: 0, y: 48)
                                ,alignment: .bottom
                            )
                            .offset(y: -16)
                    }
                    .opacity(animateReplySheet ? 0 : 1)
                    .onTapGesture {
                        showReplySheet = true
                    }
                }
                .frame(width: 40)
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

// Replies
