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
        ZigZagLayout(spacing: -6, rowSpacing: -10) {
            ForEach(0..<4) { index in
                Circle()
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: getSize(for: index), height: getSize(for: index))
                    .background(
                        Group {
                            if index == 2 {
                                Color(UIColor.systemGray5)
                                    .clipShape(BlipBubbleWithTail())
                            }
                        }
                    )
                    .background(Circle().stroke(.ultraThickMaterial, lineWidth: 2))
                    .overlay(
                        ZStack {
                            if index != 3 {
                                Text(selectedEmojis[index])
                                    .font(.system(size: getSize(for: index) * 0.4))
                            } else {
                                Text("1k")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    )
                    .zIndex(getZIndex(for: index)) 
            }
        }
        .padding(.trailing, 12)
    }
    
    private func getSize(for index: Int) -> CGFloat {
        switch index {
            case 0: return 24
            case 1: return 30
            case 2: return 32
            default: return 28
        }
    }
    
    private func getZIndex(for index: Int) -> Double {
        let size = getSize(for: index)
        switch size {
            case 32: return 3
            case 28: return 1
            case 24: return 2
            default: return 0
        }
    }
}
