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
    let color: Color
    let secondaryColor: Color

    let auxiliarySize: CGSize = .init(width: 216, height: 120)

    @State private var gestureTranslation = CGPoint.zero
    @State private var gestureVelocity = CGPoint.zero

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline) {
                Text(entity.text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
            }

            if let song = entity.getSongAttachment() {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)

                    Text("\(song.artistName),")
                        .foregroundColor(.secondary)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .lineLimit(1)

                    Text(song.name)
                        .foregroundColor(.white)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(secondaryColor, in: Capsule())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color, in: BubbleWithTailShape(scale: 1))
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

struct ParentTextBubbleView: View {
    let entity: Entity

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(entity.text)
                .foregroundColor(.secondary)
                .font(.system(size: 11))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(
            BubbleWithTailShape(scale: 0.2)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
