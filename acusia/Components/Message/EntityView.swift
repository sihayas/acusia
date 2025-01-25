//
//  EntityView.swift
//  acusia
//
//  Created by decoherence on 11/8/24.
//
import SwiftUI

struct EntityView: View {
    @State private var hasContext = false
    @State private var messageSize: CGSize?

    let rootEntity: Entity
    let previousEntity: Entity?
    let entity: Entity

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
                    .stroke(Color(.black), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .scaleEffect(x: -1, y: 1)
            }

            if let parent = parent, parentId != previousParentId, parentId != previousId, !isRootChild {
                HStack(alignment: .bottom, spacing: 8) {
                    AvatarView(size: 24, imageURL: parent.avatar)
                        .frame(width: 32)

                    ContextualMessageView(entity: parent)
                }
                .onAppear { hasContext = true }
            }

            // MARK: Main Message

            HStack(alignment: .bottom, spacing: 10) {
                VStack {
                    Line()
                        .stroke(Color(.black),
                                style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round,
                                    dash: previousParentId == parentId ? [4, 8] : []
                                ))
                        .frame(width: 32)
                        .opacity(!isRoot && !isRootChild ? 1 : 0)

                    AvatarView(size: 32, imageURL: entity.avatar)
                }
                .frame(
                    width: 32,
                    height: messageSize?.height,
                    alignment: .bottom
                )
 
                MessageView(entity: entity, isOwn: false)
                    .readSize { size in
                        messageSize = size
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EntityHistoryView: View {
    @State private var hasContext = false

    let rootEntity: Entity
    let previousEntity: Entity?
    let entity: Entity

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
                    .stroke(Color(.systemGray6), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 32)
                    .scaleEffect(x: -1, y: 1)
            }

            if let parent = parent, parentId != previousParentId, parentId != previousId, !isRootChild {
                HStack(alignment: .bottom, spacing: 8) {
                    AvatarView(size: 32, imageURL: parent.avatar)
                        .frame(width: 40)

                    ContextualMessageView(entity: parent)
                }
                .onAppear { hasContext = true }
            }

            // MARK: Main Message

            HStack(alignment: .bottom, spacing: 8) {
                // VStack {
                //     Line()
                //         .stroke(Color(.systemGray6),
                //                 style: StrokeStyle(
                //                     lineWidth: 4,
                //                     lineCap: .round,
                //                     dash: previousParentId == parentId ? [4, 8] : []
                //                 ))
                //         .frame(width: 8)
                //         .opacity(!isRoot && !isRootChild ? 1 : 0)
                // }
                // .frame(width: 8)
                // .frame(maxHeight: .infinity)

                MessageView(entity: entity, isOwn: true)
            }
        }
    }
}
