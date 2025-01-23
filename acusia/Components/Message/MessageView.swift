//
//  MessageView.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//

import SwiftUI

struct MessageView: View {
    @State private var attachmentSize: CGSize = .zero
    @State private var textBubbleSize: CGSize = .zero
    @State private var verticalSpacing: CGFloat = 0

    let entity: Entity
    let isOwn: Bool
    let blipXOffset: CGFloat = 72
    var isPreview = true

    var body: some View {
        let photos = entity.getPhotoAttachments()

        ZStack(alignment: .topLeading) {
            HStack(alignment: .bottom, spacing: -blipXOffset) {
                if !isOwn {
                    TextBubbleView(entity: entity, isOwn: isOwn)
                        .alignmentGuide(VerticalAlignment.bottom) { _ in 8 }
                        .measure($textBubbleSize)

                    BlipView(isOwn: isOwn)
                } else {
                    BlipView(isOwn: isOwn)
                        .zIndex(1)

                    TextBubbleView(entity: entity, isOwn: isOwn)
                        .alignmentGuide(VerticalAlignment.bottom) { _ in 8 }
                        .measure($textBubbleSize)
                }
            }
            .onChange(of: textBubbleSize.width) { _, _ in
                if !isOwn {
                    /// If the width of the top is greater than the width of the text bubble minus blip horizontal size, push the top down.
                    verticalSpacing = attachmentSize.width > (textBubbleSize.width - blipXOffset)
                        ? -2
                        : 24
                } else {
                    verticalSpacing = -2
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                if !isOwn {
                    Text("\(entity.username)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.leading, 12)
                } else {
                    Text("biome_name")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }

                if let song = entity.getSongAttachment() {
                    SongAttachmentView(song: song)
                }

                if !photos.isEmpty {
                    if isPreview {
                        PhotoMessagesDeckView(photos: photos)
                    } else {
                        switch photos.count {
                        case 1:
                            if let photo = photos.first {
                                PhotoMessageView(photo: photo)
                            }
                        case 2 ... 3:
                            PhotoMessagesView(photos: photos)
                        default:
                            PhotoMessagesDeckView(photos: photos)
                        }
                    }
                }
            }
            .alignmentGuide(VerticalAlignment.top) { dimensions in
                dimensions.height - verticalSpacing
            }
            .measure($attachmentSize)
        }
    }
}
