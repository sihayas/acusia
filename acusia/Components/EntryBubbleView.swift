//
//  EntryBubbleView.swift
//  acusia
//
//  Created by decoherence on 10/29/24.
//
import SwiftUI
import ContextMenuAuxiliaryPreview

struct AuxiliaryView: View {
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .cornerRadius(10)
    }
}

struct EntryBubble: View {
    let entry: EntryModel
    let color: Color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(entry.text)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(6)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color, in: WispBubbleWithTail(scale: 1))
            .foregroundStyle(.secondary)
            .auxiliaryContextMenu(
                 auxiliaryContent: AuxiliaryView(),
                 config: AuxiliaryPreviewConfig(
                    verticalAnchorPosition: .automatic,
                    horizontalAlignment: .targetCenter,
                    preferredWidth: .constant(100),
                    preferredHeight: .constant(100),
                    marginInner: 10,
                    marginOuter: 10,
                    transitionConfigEntrance: .syncedToMenuEntranceTransition(),
                    transitionExitPreset: .fade
                )
             ) {
                 UIAction(
                     title: "Share",
                     image: UIImage(systemName: "square.and.arrow.up")
                 ) { _ in
                     // Action handler
                 }
             }
            .overlay(alignment: .topLeading) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(entry.username)
                        .foregroundColor(.secondary)
                        .font(.system(size: 11, weight: .regular))

                    if let artist = entry.artistName, let album = entry.name {
                        Text("·")
                            .foregroundColor(.secondary)
                            .font(.system(size: 11, weight: .bold))

                        VStack(alignment: .leading) {
                            Text("\(artist), \(album)")
                                .foregroundColor(.secondary)
                                .font(.system(size: 11, weight: .semibold))
                                .lineLimit(1)
                        }
                    }
                }
                .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }

            BlipView(size: CGSize(width: 60, height: 60), fill: color)
                .alignmentGuide(VerticalAlignment.top) { d in d.height / 1.5 }
                .alignmentGuide(HorizontalAlignment.trailing) { d in d.width * 1.0 }
                .offset(x: 20, y: 0)
        }
        // .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EntryBubbleOutlined: View {
    let entry: EntryModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .lastTextBaseline) {
                Text(entry.text)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay(
                WispBubbleWithTail(scale: 0.7)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                Text(entry.username)
                    .foregroundColor(.secondary)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .alignmentGuide(VerticalAlignment.top) { d in d.height + 2 }
                    .alignmentGuide(HorizontalAlignment.leading) { _ in -12 }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 6)
        }
        // .frame(maxWidth: .infinity, alignment: .leading)
    }
}
