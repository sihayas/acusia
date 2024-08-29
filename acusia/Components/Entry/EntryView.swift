//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import SwiftUI

struct Entry: View {    
    let entry: APIEntry
    let onDelete: (String) async -> Void
    
    @Binding var expandedEntryId: String?

    // Entry is halfway past scrollview.
    @State private var isVisible: Bool = false
    
    // First controls the sheet visibility. Second controls animation.
    @State private var showReplySheet = false
    @State private var animateReplySheet = false
    
    @State private var repliesOffset: CGFloat = 0
    @State private var entryHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Entry
            if entry.rating != 2 {
                ArtifactView(entry: entry, animateReplySheet: animateReplySheet)
            } else {
                WispView(entry: entry, animateReplySheet: animateReplySheet)
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
                .opacity(animateReplySheet ? 0 : 1)
                .onTapGesture {
                    showReplySheet = true
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
                    .onChange(of: showReplySheet) { old, new in
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
            // Sheet content
            VStack(alignment: .leading) {
                // Content
                LazyVStack(alignment: .leading) {
                    CommentsListView(replies: sampleComments)
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
            }
            .background(
                Color.black
                    .clipShape(RoundedRectangle(cornerRadius: 45, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 45, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1) // Define the outline color and width
                    )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .presentationDetents([.fraction(0.85)])
            .presentationCornerRadius(45)
            .presentationBackground(.black)
            .presentationDragIndicator(.visible)
        }
    }
}
