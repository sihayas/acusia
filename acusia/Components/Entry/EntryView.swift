//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import SwiftUI

struct Entry: View {
    @State private var blurRadius: CGFloat = 0
    
    let entry: APIEntry
    var namespace: Namespace.ID
    let onDelete: (String) async -> Void

    @State private var isVisible: Bool = false
    @State private var showReplies = false
    @State private var repliesOffset: CGFloat = 0
    @State private var entryHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Entry
            HStack(alignment: .bottom, spacing: 0) {
                AvatarView(size: 40, imageURL: entry.author.image)

                if entry.rating != 2 {
                    ArtifactView(isVisible: $isVisible, entry: entry)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    WispView(entry: entry, namespace: namespace)
                }
            }

            // Replies
            if !sampleComments.isEmpty {
                HStack(alignment: .top) {
                    BottomCurvePath()
                        .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 20)

                    ZStack {
                        ForEach(0 ..< 3) { index in
                            AvatarView(size: 16, imageURL: "https://picsum.photos/200/300")
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
                                .offset(tricornOffset(for: index))
                        }
                    }
                    .frame(width: 40, height: 40)
                }
                .opacity(showReplies ? 0 : 1)
                .onTapGesture {
                    withAnimation {
                        showReplies.toggle()
                    }
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
                    .onChange(of: showReplies) { old, new in
                        if new {
                            // Measure the top of the entry from the top of the screen.
                            repliesOffset = geometry.frame(in: .global).minY
                            withAnimation {
                                showReplies = new
                            }
                        }
                    }
            }
        )
        .offset(y: showReplies ? 32 - repliesOffset : 0)
        .zIndex(showReplies ? 1 : 0)
        .sheet(isPresented: $showReplies) {
            // Sheet content
            VStack(alignment: .leading) {
                LazyVStack(alignment: .leading) {
                    CommentsListView(replies: sampleComments)
                }
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .presentationDetents([.medium, .large])
            .presentationCornerRadius(45)
            .presentationBackground(.ultraThickMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .onDisappear {
                repliesOffset = 0
                withAnimation {
                    showReplies = false
                }
            }
        }
    }
}
