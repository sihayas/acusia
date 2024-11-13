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

    let blipXOffset: CGFloat = 52

    var body: some View {
        let rootId = rootEntity.id
        let previousId = previousEntity?.id
        let previousParentId = previousEntity?.parent?.id
        let parent = entity.parent
        let parentId = entity.parent?.id

        let isRoot = parent == nil
        let isRootChild = parentId == rootId

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
                                .padding(.leading, 10)
                            
                            if let song = parent.getSongAttachment() {
                                ZStack(alignment: .bottomTrailing) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.ultraThinMaterial, lineWidth: 1)
                                        .fill(.clear)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            AsyncImage(url: URL(string: song.artwork)) { image in
                                                image
                                                    .resizable()
                                            } placeholder: {
                                                Rectangle()
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .aspectRatio(contentMode: .fill)
                                            .padding(4)
                                        )

                                    Button(action: {
                                        // Handle button action here
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 8, weight: .regular))
                                            .foregroundColor(.secondary)
                                            .frame(width: 12, height: 12)
                                            .background(.ultraThinMaterial)
                                            .clipShape(Circle())
                                            .alignmentGuide(VerticalAlignment.bottom) { d in d.height + 4 }
                                            .alignmentGuide(HorizontalAlignment.trailing) { d in d.width + 4 }
                                    }
                                }
                            }
                        }
                        .alignmentGuide(VerticalAlignment.top) { d in d.height + parentSpacing }
                        .measure($parentAttachmentSize)
                    }
                }
                .onAppear { hasContext = true }
                .padding(.top, 24)
            }

            // MARK: Entity Parent

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

                        BlipView(size: CGSize(width: 56, height: 56), color: color)
                    }
                    .onChange(of: textSize.width) {
                        /// If the width of the top is greater than the width of the text bubble minus 16, push the top down.
                        spacing = attachmentSize.width > (textSize.width - blipXOffset) ? 0 : 44
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(entity.username)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                            .padding(.leading, 12)

                        if let song = entity.getSongAttachment() {
                            ZStack(alignment: .bottomTrailing) {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 88, height: 88)
                                    .overlay(
                                        AsyncImage(url: URL(string: song.artwork)) { image in
                                            image
                                                .resizable()
                                        } placeholder: {
                                            Rectangle()
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                                        .aspectRatio(contentMode: .fill)
                                        .padding(2)
                                    )

                                Button(action: {}) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .frame(width: 24, height: 24)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(color, lineWidth: 2)
                                        )
                                        .alignmentGuide(VerticalAlignment.bottom) { d in d.height - 4 }
                                        .alignmentGuide(HorizontalAlignment.trailing) { d in d.width - 4 }
                                }
                            }
                        }
                    }
                    .alignmentGuide(VerticalAlignment.top) { d in d.height - spacing }
                    .measure($attachmentSize)
                }
            }
        }
    }
}
