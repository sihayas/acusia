import SwiftUI

struct BlipView: View {
    let emojis = [
        "😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]

    @State private var selectedEmojis: [String] = (0..<3).map { _ in
        ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"].randomElement() ?? "😊"
    }

    var body: some View {
        HStack(spacing: -8) {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("1k")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                )
                .background(.ultraThinMaterial)
                .mask(
                    Circle()
                        .fill(.white)
                        .strokeBorder(.black, lineWidth: 1)
                )
            
            ForEach(0..<2) { index in
                Capsule()
                    .fill(Color(.systemGray6))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(selectedEmojis[index])
                            .font(.system(size: 32 * 0.35))
                    )
                    .background(.ultraThinMaterial)
                    .mask(
                        Circle()
                            .fill(.white)
                            .strokeBorder(.black, lineWidth: 1)
                    )
            }

            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(selectedEmojis[2])
                        .font(.system(size: 36 * 0.4))
                )
                .background(Color(.systemGray6), in: BlipBubbleWithTail())
                .mask(
                    BlipBubbleWithTail()
                        .fill(.white)
                )
        }
    }
}
