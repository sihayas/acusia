//
//  BiomeDetailView.swift
//  acusia
//
//  Created by decoherence on 11/7/24.
//
import SwiftUI

struct BiomeExpandedView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State var didAppear = false

    let biome: Biome
    let strokeColor = Color(UIColor.systemGray6)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 45, style: .continuous)
                .fill(.ultraThickMaterial)
                .opacity(didAppear ? 0 : 1)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<biome.entities.count, id: \.self) { index in
                        let entity = biome.entities[index]
                        let isRoot = entity.parent == nil
                        let previousEntity = index > 0 ? biome.entities[index - 1] : nil

                        /// Contextual Parent Logic
                        /// Render context if:
                        /// - This entity has a parent (this entity is not the root).
                        /// - The previous entity's parent is not the same as this entity.
                        /// - The parent is not the previous entity.
                        if let parent = entity.parent, previousEntity?.parent?.id != parent.id, previousEntity?.id != parent.id {
                            VStack(alignment: .leading) {
                                Capsule()
                                    .fill(strokeColor)
                                    .frame(width: 4, height: 8)
                                    .frame(width: 40)

                                HStack(spacing: 12) {
                                    LoopPath()
                                        .stroke(strokeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .frame(width: 40, height: 32)
                                        .scaleEffect(x: -1, y: 1)

                                    AvatarView(size: 24, imageURL: parent.avatar)

                                    ParentTextBubbleView(entity: parent)
                                        .padding(.leading, -4)
                                }
                            }
                        }

                        /// Main Entity Rendering
                        EntityView(entity: entity, isRoot: isRoot, strokeColor: strokeColor)
                            .frame(maxHeight: .infinity)
                            .shadow(color: isRoot ? .black.opacity(0.1) : .clear, radius: isRoot ? 10 : 0, x: 0, y: 0)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, safeAreaInsets.bottom)
            }
            .defaultScrollAnchor(.bottom)
        }
        .overlay(alignment: .top) {
            Image(systemName: "chevron.down")
                .font(.system(size: 27, weight: .bold))
                .foregroundColor(strokeColor)
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.7)) {
                didAppear = true
            }
        }
    }
}
