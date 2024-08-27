//
//  EntryView.swift
//  acusia
//
//  Created by decoherence on 8/25/24.
//

import SwiftUI

struct Entry: View {
    let entry: APIEntry
    var namespace: Namespace.ID
    let scrolledEntryID: APIEntry.ID?
    let onDelete: (String) async -> Void

    @State private var isSheetPresented = false
    @State private var isVisible: Bool = false
    @State private var showComments = false

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
                    if !showComments {
                        BottomCurvePath()
                            .stroke(Color(UIColor.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 40, height: showComments ? nil : 20)
                        
                        ZStack {
                            ForEach(0 ..< 3) { index in
                                AvatarView(size: 16, imageURL: "https://picsum.photos/200/300")
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(UIColor.systemGray6), lineWidth: 2))
                                    .offset(tricornOffset(for: index))
                            }
                        }
                        .frame(width: 40, height: 40)
                    } else {
                        LazyVStack(alignment: .leading) {
                            ForEach(sampleComments) { comment in
                                CommentView(comment: comment)
                                    .transition(.blurReplace)
                                    .border(.red)
                            }
                        }
                        .transition(.blurReplace)
                    }
                }
                .onTapGesture {
                    withAnimation {
                        showComments.toggle()
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .onScrollVisibilityChange(threshold: 0.7) { visibility in
            isVisible = visibility
        }
        .sheet(isPresented: $isSheetPresented) {
            // Sheet content
            VStack {}
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(32)
                .presentationBackground(.thinMaterial)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
    }
}
