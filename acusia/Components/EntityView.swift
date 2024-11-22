//
//  EntityView.swift
//  acusia
//
//  Created by decoherence on 11/8/24.
//
import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

struct EntityView: View {
    @State private var attachmentSize: CGSize = .zero
    @State private var textSize: CGSize = .zero
    @State private var spacing: CGFloat = 0

    @State private var parentAttachmentSize: CGSize = .zero
    @State private var parentTextSize: CGSize = .zero
    @State private var parentSpacing: CGFloat = 0

    @State private var hasContext = false

    let rootEntity: Entity
    let previousEntity: Entity?
    let entity: Entity
    let color: Color
    let secondaryColor: Color

    let blipXOffset: CGFloat = 80

    var body: some View {
        let rootId = rootEntity.id
        let previousId = previousEntity?.id
        let previousParentId = previousEntity?.parent?.id
        let parent = entity.parent
        let parentId = entity.parent?.id

        let isRoot = parent == nil
        let isRootChild = parentId == rootId

        if !isRoot {
            VStack(alignment: .leading, spacing: hasContext ? 8 : 0) {
                // MARK: Contextual Parent
                if previousId == parentId && !isRootChild && !isRoot {
                    LoopPath()
                        .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 32)
                        .scaleEffect(x: -1, y: 1)
                }
                if let parent = parent, parentId != previousParentId, parentId != previousId, !isRootChild {
                    HStack(alignment: .bottom, spacing: 8) {
                        AvatarView(size: 32, imageURL: parent.avatar)
                            .frame(width: 40)

                        ZStack(alignment: .topLeading) {
                            HStack(alignment: .bottom, spacing: -blipXOffset) {
                                ParentTextBubbleView(entity: parent)
                                    .alignmentGuide(VerticalAlignment.bottom) { _ in 8 }
                                    .measure($parentTextSize)
                                    .padding(.bottom, 4)
                            }
                            .onChange(of: parentTextSize.width) {
                                /// If the width of the top is greater than the width of the text bubble minus 16, push the top down.
                                parentSpacing = parentAttachmentSize.width > (parentTextSize.width) ? 0 : 4
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(entity.username)
                                    .font(.system(size: 9, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 8)
                            }
                            .alignmentGuide(VerticalAlignment.top) { d in d.height + parentSpacing }
                            .measure($parentAttachmentSize)
                        }
                    }
                    .onAppear { hasContext = true }
                }

                // MARK: Entity
                HStack(alignment: .bottom, spacing: 8) {
                    VStack {
                        Line()
                            .stroke(color,
                                    style: StrokeStyle(
                                        lineWidth: 4,
                                        lineCap: .round,
                                        dash: previousParentId == parentId ? [4, 8] : []
                                    ))
                            .frame(width: 40)
                            .opacity(!isRoot && !isRootChild ? 1 : 0)

                        AvatarView(size: 40, imageURL: entity.avatar)
                    }
                    .frame(width: 40)
                    .frame(maxHeight: .infinity)

                    ZStack(alignment: .topLeading) {
                        HStack(alignment: .bottom, spacing: -blipXOffset) {
                            TextBubbleView(entity: entity, color: color, secondaryColor: secondaryColor)
                                .alignmentGuide(VerticalAlignment.bottom) { _ in 8 }
                                .measure($textSize)
                                .padding(.bottom, 4)

                            BlipView(color: color)
                        }
                        .onChange(of: textSize.width) {
                            /// If the width of the top is greater than the width of the text bubble minus 16, push the top down.
                            spacing = attachmentSize.width > (textSize.width - blipXOffset) ? 0 : 20
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entity.username)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)

                            if let song = entity.getSongAttachment() {
                                HStack {
                                    AsyncImage(url: URL(string: song.artwork)) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        Rectangle()
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .aspectRatio(contentMode: .fit)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                                    VStack(alignment: .leading) {
                                        Text(song.artistName)
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(.white)
                                        Text(song.name)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                      

                                        HStack(spacing: 2) {
                                            Image(systemName: "applelogo")
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)

                                            Text("Music")
                                                .font(.system(size: 13, weight: .regular))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .blendMode(.difference)
                                }
                                .padding(12)
                                .frame(height: 72, alignment: .leading)
                                .background(Color(hex: song.color), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                        }
                        .alignmentGuide(VerticalAlignment.top) { d in d.height - spacing }
                        .measure($attachmentSize)
                    }
                }
            }
        }
    }
}
