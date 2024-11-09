import SwiftUI

struct BlipView: View {
    let size: CGSize
    let color: Color
    let emojis = [
        "😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]

    @State private var selectedEmojis: [String] = (0..<4).map { _ in
        ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"].randomElement() ?? "😊"
    }

    var body: some View {
        ZigZagLayout(spacing: -8, rowSpacing: -10) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(color)
                    .frame(width: getSize(for: index), height: getSize(for: index))
                    .background(
                        Group {
                            if index == 3 {
                                color.clipShape(BlipBubbleWithTail())
                            }
                        }
                    )
                    .background(Circle().stroke(.ultraThickMaterial, lineWidth: 2))
                    .overlay(
                        ZStack {
                            if index != 0 {
                                Text(selectedEmojis[index])
                                    .font(.system(size: getSize(for: index) * 0.35))
                            } else {
                                Text("1k")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    )
                    .zIndex(Double(index))
            }
        }
        .padding(.trailing, 12)
    }
    
    private func getSize(for index: Int) -> CGFloat {
        switch index {
            case 0: return 24
            case 1, 2: return 28
            default: return 32
        }
    }
}
