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

            // if let song = entity.getSongAttachment() {
            //     HStack(spacing: 4) {
            //         Image(systemName: "music.note")
            //             .font(.system(size: 9, weight: .bold))
            //             .foregroundColor(.secondary)
           
            //         Text("\(song.artistName),")
            //             .foregroundColor(.secondary)
            //             .font(.system(size: 11, weight: .regular, design: .monospaced))
            //             .lineLimit(1)
           
            //         Text(song.name)
            //             .foregroundColor(.white)
            //             .font(.system(size: 11, weight: .regular, design: .monospaced))
            //     }
            //     .padding(.horizontal, 6)
            //     .padding(.vertical, 2)
            //     .background(secondaryColor, in: Capsule())
            // }
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
    @State private var gestureTranslation = CGPoint.zero
    @State private var gestureVelocity = CGPoint.zero
    
    let entity: Entity
    let auxiliarySize: CGSize = .init(width: 216, height: 120)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                    
                    VStack(alignment: .leading) {
                        Text(song.artistName)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                        Text(song.name)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 44, alignment: .leading)
                .padding(.vertical, 4)
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text(entity.text)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(
            ContextualBubbleWithTailShape()
                .stroke(.white.opacity(0.05), lineWidth: 1)
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
