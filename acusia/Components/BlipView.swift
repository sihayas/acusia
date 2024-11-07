import SwiftUI

struct BlipView: View {
    let size: CGSize
    let fill: Color
    let emojis = [
        "😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]

    @State private var selectedEmojis: [String] = (0..<5).map { _ in
        ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"].randomElement() ?? "😊"
    }

    var body: some View {
        ZigZagLayout(spacing: -4, rowSpacing: -12) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: getSize(for: index), height: getSize(for: index))
                    .background(
                        Group {
                            if index == 1 {
                                Color(UIColor.systemGray5)
                                    .clipShape(BlipBubbleWithTail())
                            }
                        }
                    )
                    .background(Circle().stroke(.ultraThickMaterial, lineWidth: 2))
                    .overlay(
                        Text(selectedEmojis[index])
                            .font(.system(size: getSize(for: index) * 0.4))
                    )
                    .zIndex(getZIndex(for: index)) 
            }
        }
    }
    
    private func getSize(for index: Int) -> CGFloat {
        switch index {
            case 0: return 28
            case 1: return 32
            case 2: return 24
            default: return 28
        }
    }
    
    private func getZIndex(for index: Int) -> Double {
        let size = getSize(for: index)
        switch size {
            case 32: return 3
            case 28: return 2
            case 24: return 1
            default: return 0
        }
    }
}
