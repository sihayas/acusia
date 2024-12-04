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
        HStack(spacing: -8) {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Text("1k")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                )
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.black, lineWidth: 1)
                )
            
            ForEach(0..<2) { index in
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(selectedEmojis[index])
                            .font(.system(size: 32 * 0.35))
                    )
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.black, lineWidth: 1)
                    )
            }

            Circle()
                .fill(color)
                .frame(width: 36, height: 36)
                .background(color, in: BlipBubbleWithTail())
                .overlay(
                    Text(selectedEmojis[2])
                        .font(.system(size: 36 * 0.4))
                )
                .overlay(
                    BlipBubbleWithTail()
                        .stroke(.black, lineWidth: 1)
                )
        }
    }
}
