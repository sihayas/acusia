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
    @State private var hasContext = false

    let rootEntity: Entity
    let previousEntity: Entity?
    let entity: Entity
    let isRoot: Bool
    let color: Color
    let secondaryColor: Color

    let blipXOffset: CGFloat = 52

    var body: some View {
        let rootId = rootEntity.id
        let previousId = previousEntity?.id
        let previousParentId = previousEntity?.parent?.id
        let parent = entity.parent
        let parentId = entity.parent?.id
        let entityId = entity.id

        let isRootChild = parentId == rootId

        VStack(alignment: .leading, spacing: hasContext ? 8 : 0) {
            /// Contextual Parent
            if previousId == parentId && !isRootChild && !isRoot {
                LoopPath()
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 32)
                    .scaleEffect(x: -1, y: 1)
            }
            
            if let parent = parent, parentId != previousParentId, parentId != previousId, !isRootChild {
                HStack(spacing: 12) {
                    AvatarView(size: 32, imageURL: parent.avatar)
                        .frame(width: 40)

                    ParentTextBubbleView(entity: parent)
                        .padding(.bottom, 8)
                }
                .onAppear { hasContext = true }
                .padding(.top, 44)
            }

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
                                AsyncImage(url: URL(string: song.artwork)) { image in
                                    image
                                        .resizable()
                                } placeholder: {
                                    Rectangle()
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 88, height: 88)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .padding(1)
                                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 4))
                                .rotationEffect(.degrees(-4), anchor: .center)

                                Button(action: {
                                    // Handle button action here
                                }) {
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
                                        .alignmentGuide(HorizontalAlignment.trailing) { d in d.width - 8 }
                                }
                            }
                        }
                    }
                    .alignmentGuide(VerticalAlignment.top) { d in d.height - spacing }
                    .measure($attachmentSize)
                }
            }
        }
        // .border(.red)
    }
}

// if let parent = entity.parent, previousEntity?.parent?.id != parent.id, previousEntity?.id != parent.id, !isRootChild {
//     VStack(alignment: .leading, spacing: 8) {
//         // Line()
//         //     .stroke(color,
//         //             style: StrokeStyle(
//         //                 lineWidth: 4,
//         //                 lineCap: .round,
//         //                 dash: previousEntity?.parent?.id != rootEntity.id ? [4, 8] : []
//         //             ))
//         //     .frame(width: 40, height: 48)
//             // .padding(.bottom, -12)
//
//         HStack(spacing: 12) {
//             // LoopPath()
//             //     .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
//             //     .frame(width: 40, height: 32)
//             //     .scaleEffect(x: -1, y: 1)
//
//             AvatarView(size: 32, imageURL: parent.avatar)
//                 .frame(width: 40)
//
//             ParentTextBubbleView(entity: parent)
//                 .padding(.bottom, 8)
//         }
//     }
//     .onAppear { hasContext = true }
// }
