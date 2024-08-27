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
    let onDelete: (String) async -> Void

    // Detected using scroll visibility change
    @State private var isVisible: Bool = false
    @State private var showReplies = false
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
                            .frame(width: 40, height: showReplies ? nil : 20)

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
                .opacity(showReplies ? 0.5 : 1)
                .frame(height: showReplies ? UIScreen.main.bounds.height : nil,
                       alignment: .leading
                )
                .border(.blue)
                .onTapGesture {
                    showReplies.toggle()
                }
            }
        }
        .padding(.horizontal, 24)
        .onScrollVisibilityChange(threshold: 0.7) { visibility in
            isVisible = visibility
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        entryHeight = geometry.size.height
                    }
            }
        )
        .overlay(
            showReplies ?
                AnyView(
                    LazyVStack(alignment: .leading) {
                        CommentsListView(replies: sampleComments)
                    }
                    .transition(.blurReplace)
                    .padding(.top, 8)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .topLeading)
                    .border(.red)
                    .offset(y: entryHeight)  // Offset by the height of the Entry view
                ) :
                AnyView(EmptyView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                ),
            alignment: .topLeading
        )
    }
}
