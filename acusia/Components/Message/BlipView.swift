import SwiftUI

struct BlipView: View {
    let emojis = [
        "😡", "💀", "🔥", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]

    @State private var selectedEmojis: [String] = (0..<3).map { _ in
        ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"].randomElement() ?? "😊"
    }

    var body: some View {
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
                            .font(.caption)

                        Capsule()
                            .stroke(.black, lineWidth: 1)
                    }
            }
            
            BlipTail()
                .fill(Color(.systemGray6))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(selectedEmojis[2])
                        .font(.footnote)
                    
                    BlipTail(insetAmount: -1)
                        .stroke(Color(.black), lineWidth: 1)
                }
                .padding(.trailing, 36 * 0.3)
        }
    }
}

struct BlipContextView: View {
    let emojis = [
        "😡", "💀", "🔥", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]

    @State private var selectedEmojis: [String] = (0..<3).map { _ in
        ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"].randomElement() ?? "😊"
    }

    var body: some View {
        HStack(spacing: -6) {
            Circle()
                .frame(width: 28, height: 28)
                .background(Color(.black), in: Circle())
                .foregroundStyle(.clear)
                .overlay {
                    Text("22")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    Circle()
                        .strokeBorder(Color(.systemGray6), lineWidth: 1)
                }

            ForEach(0..<1) { index in
                Capsule()
                    .frame(width: 28, height: 28)
                    .background(Color(.black), in: Capsule())
                    .foregroundStyle(.clear)
                    .overlay {
                        Text(selectedEmojis[index])
                            .font(.caption2)

                        Capsule()
                            .strokeBorder(Color(.systemGray6), lineWidth: 1)
                    }
            }
            
            BlipTail()
                .fill(Color(.black))
                .frame(width: 32, height: 32)
                .overlay {
                    Text(selectedEmojis[2])
                        .font(.caption)
                    
                    BlipTail(insetAmount: -1)
                        .strokeBorder(Color(.systemGray6), lineWidth: 1)
                }
                .padding(.trailing, 32 * 0.3)
        }
    }
}
