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
    let root: Entity
    let previousEntity: Entity?
    let entity: Entity
    let isRoot: Bool
    let color: Color
    let secondaryColor: Color

    @State private var attachmentSize: CGSize = .zero
    @State private var textSize: CGSize = .zero
    @State private var spacing: CGFloat = 0
    @State private var hasContext = false

    let blipXOffset: CGFloat = 52

    var body: some View {
        let entityParent = entity.parent

        VStack(alignment: .leading, spacing: hasContext ? 8 : 0) {
            /// Contextual Parent Logic
            /// Render context if:
            /// - This entity has a parent (this entity is not the root).
            /// - The previous entity's parent is not the same as this entity.
            /// - The parent is not the previous entity.
            if let parent = entity.parent, previousEntity?.parent?.id != parent.id, previousEntity?.id != parent.id {
                VStack(alignment: .leading, spacing: 0) {
                    Line()
                        .stroke(color,
                                style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round,
                                    dash: previousEntity?.parent?.id != root.id ? [4, 8] : []
                                ))
                        .frame(width: 40, height: 48)
                        .padding(.bottom, -12)

                    HStack(spacing: 12) {
                        LoopPath()
                            .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 40, height: 32)
                            .scaleEffect(x: -1, y: 1)

                        AvatarView(size: 32, imageURL: parent.avatar)

                        ParentTextBubbleView(entity: parent)
                            .padding(.bottom, 8)
                    }
                }
                .onAppear { hasContext = true }
            }

            HStack(alignment: .bottom, spacing: 8) {
                VStack {
                    Line()
                        .stroke(color,
                                style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round,
                                    dash: entityParent?.id != root.id ? [4, 8] : []
                                ))
                        .frame(width: 40)
                        .padding(.top, hasContext ? -16 : 0)
                        .opacity(!isRoot ? 1 : 0)

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

                        if isRoot {
                            ZStack(alignment: .bottomTrailing) {
                                AsyncImage(url: URL(string: entity.artwork ?? "")) { image in
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

                                Button {} label: {
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
    }
}
