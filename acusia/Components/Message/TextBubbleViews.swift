//
//  EntityBubbleView.swift
//  acusia
//
//  Created by decoherence on 10/29/24.
//
import ContextMenuAuxiliaryPreview
import SwiftUI

struct TextBubbleView: View {
    let entity: Entity

    let auxiliarySize: CGSize = .init(width: 216, height: 120)

    @State private var gestureTranslation = CGPoint.zero
    @State private var gestureVelocity = CGPoint.zero

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(entity.text)
                .foregroundColor(.white)
                .font(.callout)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Color(.systemGray6),
            in: MessageTail()
        )
        .foregroundStyle(.secondary)
        .auxiliaryContextMenu(
            auxiliaryContent: AuxiliaryView(size: auxiliarySize, gestureTranslation: $gestureTranslation, gestureVelocity: $gestureVelocity),
            gestureTranslation: $gestureTranslation,
            gestureVelocity: $gestureVelocity,
            config: AuxiliaryPreviewConfig(
                verticalAnchorPosition: .top,
                horizontalAlignment: .targetLeading,
                preferredWidth: .constant(auxiliarySize.width),
                preferredHeight: .constant(auxiliarySize.height),
                marginInner: -56,
                marginOuter: 0,
                marginLeading: -56,
                marginTrailing: 0,
                transitionConfigEntrance: .syncedToMenuEntranceTransition(),
                transitionExitPreset: .zoom(zoomOffset: 0)
            )
        ) {
            UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
            }
        }
    }
}

struct TextBubbleContextView: View {
    @State private var gestureTranslation = CGPoint.zero
    @State private var gestureVelocity = CGPoint.zero

    let entity: Entity
    let auxiliarySize: CGSize = .init(width: 216, height: 120)

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(entity.text)
                .foregroundColor(.secondary)
                .font(.caption)
                .multilineTextAlignment(.leading)
                .lineLimit(4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(
            ContextMessageTail()
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .auxiliaryContextMenu(
            auxiliaryContent: AuxiliaryView(size: auxiliarySize, gestureTranslation: $gestureTranslation, gestureVelocity: $gestureVelocity),
            gestureTranslation: $gestureTranslation,
            gestureVelocity: $gestureVelocity,
            config: AuxiliaryPreviewConfig(
                verticalAnchorPosition: .top,
                horizontalAlignment: .targetLeading,
                preferredWidth: .constant(auxiliarySize.width),
                preferredHeight: .constant(auxiliarySize.height),
                marginInner: -56,
                marginOuter: 0,
                marginLeading: -56,
                marginTrailing: 0,
                transitionConfigEntrance: .syncedToMenuEntranceTransition(),
                transitionExitPreset: .zoom(zoomOffset: 0)
            )
        ) {
            UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
            }
        }
    }
}
