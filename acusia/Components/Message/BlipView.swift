import SwiftUI

struct BlipView: View {
    let isOwn: Bool
    let emojis = [
        "😡", "💀", "🔥", "😎", "👻", "🚀", "🌈", "🦄",
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
                    .background(Color(.systemGray6), in: Circle())
                    .foregroundStyle(.clear)
                    .overlay {
                        Text("22")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Circle()
                            .strokeBorder(.black, lineWidth: 1)
                    }
                
                ForEach(0..<1) { index in
                    Capsule()
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray6), in: Capsule())
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(selectedEmojis[index])
                                .font(.system(size: 32 * 0.35))
                            
                            Capsule()
                                .stroke(.black, lineWidth: 1)
                        }
                }
                
                Circle()
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6), in: BlipBubbleWithTail(isFlipped: false))
                    .foregroundStyle(.clear)
                    .overlay {
                        Text(selectedEmojis[2])
                            .font(.system(size: 36 * 0.4))
                        
                        BlipBubbleWithTailInsettable(isFlipped: false)
                            .stroke(.black, lineWidth: 1)
                    }
            }
        } else {
            HStack(spacing: -6) {
                Circle()
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6), in: BlipBubbleWithTail(isFlipped: true))
                    .foregroundStyle(.clear)
                    .overlay {
                        Text(selectedEmojis[2])
                            .font(.system(size: 36 * 0.4))
                        
                        BlipBubbleWithTailInsettable(isFlipped: true)
                            .stroke(.black, lineWidth: 1)
                    }
                    .zIndex(3)
                
                ForEach(0..<1) { index in
                    Capsule()
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray6), in: Capsule())
                        .foregroundStyle(.clear)
                        .overlay {
                            Text(selectedEmojis[index])
                                .font(.system(size: 32 * 0.35))
                            
                            Capsule()
                                .stroke(.black, lineWidth: 1)
                        }
                        .zIndex(Double(3 - (index + 1)))
                }
                
                Circle()
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6), in: Circle())
                    .foregroundStyle(.clear)
                    .overlay {
                        Text("1k")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Circle()
                            .strokeBorder(.black, lineWidth: 1)
                    }
                    .zIndex(0)
            }
        }
    }
}
