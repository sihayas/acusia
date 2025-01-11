import SwiftUI

struct BlipView: View {
    let isOwn: Bool
    let emojis = [
        "😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]

    @State private var selectedEmojis: [String] = (0..<3).map { _ in
        ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"].randomElement() ?? "😊"
    }

    var body: some View {
        if !isOwn {
            HStack(spacing: -6) {
                Circle()
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5), in: Circle())
                    .foregroundStyle(.clear)
                    .overlay {
                        Text("22")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Circle()
                            .strokeBorder(.ultraThickMaterial, lineWidth: 1)
                    }
                
                ForEach(0..<2) { index in
                    Capsule()
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5), in: Capsule())
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(selectedEmojis[index])
                                .font(.system(size: 32 * 0.35))
                            
                            Capsule()
                                .stroke(.ultraThickMaterial, lineWidth: 1)
                        }
                }
                
                Circle()
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray5), in: BlipBubbleWithTail(isFlipped: false))
                    .foregroundStyle(.clear)
                    .overlay {
                        Text(selectedEmojis[2])
                            .font(.system(size: 36 * 0.4))
                        
                        BlipBubbleWithTailInsettable(isFlipped: false)
                            .stroke(.ultraThickMaterial, lineWidth: 1)
                    }
            }
        } else {
            HStack(spacing: -8) {
                Circle()
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray5), in: BlipBubbleWithTail(isFlipped: true))
                    .foregroundStyle(.clear)
                    .overlay {
                        Text(selectedEmojis[2])
                            .font(.system(size: 36 * 0.4))
                        
                        BlipBubbleWithTailInsettable(isFlipped: true)
                            .stroke(.ultraThickMaterial, lineWidth: 1)
                    }
                    .zIndex(1)
                
                ForEach(0..<2) { index in
                    Capsule()
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5), in: Capsule())
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(selectedEmojis[index])
                                .font(.system(size: 32 * 0.35))
                            
                            Capsule()
                                .stroke(.ultraThickMaterial, lineWidth: 1)
                        }
                        .zIndex(2)
                }
                
                Circle()
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5), in: Circle())
                    .foregroundStyle(.clear)
                    .overlay {
                        Text("1k")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Circle()
                            .strokeBorder(.ultraThickMaterial, lineWidth: 1)
                    }
                    .zIndex(3)
            }
        }
    }
}
