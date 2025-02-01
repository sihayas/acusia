//
//  MessageView.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//

import SwiftUI

struct MessageView: View {
    @State private var bubbleSize: CGSize = .zero
    @State private var attachmentSize: CGSize = .zero
    @State private var blipSize: CGSize = .zero
    @State private var verticalSpacing: CGFloat = 0

    let entity: Entity

    var body: some View {
        let photos = entity.getPhotoAttachments()
        let parent = entity.parent
        
        VStack(spacing: 8) {
            /// Message Context
            if let parent = parent {
                MessageContextView(entity: parent)
            }
            
            /// Message
            HStack(alignment: .bottom, spacing: 12) {
                AvatarView(size: 32, imageURL: entity.avatar)
                
                /// Body
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .leading) {
                        Text("\(entity.username)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                        
                        /// Attachment
                        VStack(alignment: .leading, spacing: 4) {
                            if let song = entity.getSongAttachment() {
                                SongAttachmentView(song: song)
                            }
                        
                            if !photos.isEmpty {
                                PhotoMessagesDeckView(photos: photos)
                            }
                        }
                        .measure($attachmentSize)
                    }
                    .readSize { size in
                        attachmentSize = size
                    }
                    .alignmentGuide(.top) { d in
                        d[.bottom] - verticalSpacing
                    }
                    
                    ZStack(alignment: .topTrailing) {
                        TextBubbleView(
                            entity: entity
                        )
                        .padding(.trailing, 20)
                        .frame(
                            minWidth: bubbleSize.width,
                            alignment: .leading
                        )
                        
                        BlipView()
                            .readSize { size in
                                blipSize = size
                            }
                            .alignmentGuide(.top) { d in
                                d[.bottom] - 8
                            }
                    }
                    .readSize { size in
                        bubbleSize = size
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .bottomLeading
                )
                .onChange(of: bubbleSize.width) { _, _ in
                    /// If the width of the top is greater than the width of the text bubble minus blip horizontal size, push the top down.
                    verticalSpacing = attachmentSize.width < bubbleSize.width - blipSize.width
                        ? 24
                        : -4
                }
            }
            .overlay(alignment: .leading) {
                Line()
                    .stroke(Color(.systemGray6),
                            style: StrokeStyle(
                                lineWidth: 4,
                                lineCap: .round
                            ))
                    .frame(width: 32)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct MessageContextView: View {
    @State private var bubbleSize: CGSize = .zero
    @State private var attachmentSize: CGSize = .zero
    @State private var blipSize: CGSize = .zero
    @State private var verticalSpacing: CGFloat = 0

    let entity: Entity
    
    var body: some View {
        let photos = entity.getPhotoAttachments()
        
        HStack(alignment: .bottom, spacing: 12) {
            AvatarView(size: 24, imageURL: entity.avatar)
                .frame(width: 32)
            
            /// Body
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    Text("\(entity.username)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                    
                    /// Attachment
                    VStack(alignment: .leading, spacing: 4) {
                        if let song = entity.getSongAttachment() {
                            SongAttachmentView(song: song)
                        }
                    
                        if !photos.isEmpty {
                            PhotoMessagesDeckView(photos: photos)
                        }
                    }
                }
                .readSize { size in
                    attachmentSize = size
                }
                .alignmentGuide(.top) { d in
                    d[.bottom] - verticalSpacing
                }
                
                ZStack(alignment: .topTrailing) {
                    TextBubbleContextView(
                        entity: entity
                    )
                    .padding(.trailing, 16)
                    .frame(
                        minWidth: bubbleSize.width,
                        alignment: .leading
                    )
                    
                    BlipContextView()
                        .readSize { size in
                            blipSize = size
                        }
                        .alignmentGuide(.top) { d in
                            d[.bottom] - 6
                        }
                }
                .readSize { size in
                    bubbleSize = size
                }
            }
            .onChange(of: bubbleSize.width) { _, _ in
                /// If the width of the top is greater than the width of the text bubble minus blip horizontal size, push the top down.
                verticalSpacing = attachmentSize.width < bubbleSize.width - blipSize.width
                ? 24
                : -4
            }
            .frame(
                maxWidth: .infinity,
                alignment: .bottomLeading
            )
        }
    }
}
