import SwiftUI

struct BlipView: View {
    let color: Color
    let emojis = [
        "😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]

    @State private var selectedEmojis: [String] = (0..<3).map { _ in
        ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"].randomElement() ?? "😊"
    }

    var body: some View {
        HStack(spacing: -6) {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay(
                    Text("1k")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                )
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
            
            ForEach(0..<2) { index in
                Circle()
                    .fill(color)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(selectedEmojis[index])
                            .font(.system(size: 28 * 0.35))
                    )
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            }

            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .background(color)
                .clipShape(BlipBubbleWithTail())
                .overlay(
                    Circle()
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
        }
    }
}
