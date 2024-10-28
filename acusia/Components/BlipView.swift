import SwiftUI

struct BlipView: View {
    let size: CGSize
    let emojis = [
        "😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄",
        "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"
    ]
    
    @State private var selectedEmojis: [String] = []
    
    init(size: CGSize) {
        self.size = size
        _selectedEmojis = State(
            initialValue: (0..<3).map { _ in
                emojis.randomElement() ?? "😊"
            }
        )
    }
    
    var body: some View {
        // Adjust the radius factor to get desired circle sizes
        let radiusFactor: CGFloat = 0.23
        let radius = size.width * radiusFactor

        ZStack {
            RadialLayout(radius: radius, offset: .pi / 8) {
                ForEach(0..<selectedEmojis.count, id: \.self) { index in
                    let circleSize = calculateCircleSize(index: index, frameSize: size, radius: radius)
                    
                    Text(selectedEmojis[index])
                        .font(.system(size: circleSize / 2.5))
                        .frame(width: circleSize, height: circleSize)
                        .background(
                            Circle()
                                // .stroke(.black, lineWidth: 2)
                                .fill(.ultraThinMaterial)
                        )
                        .zIndex(Double(index))
                }
            }
            
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 10, height: 10)
                .position(x: size.width * 0.84, y: size.height * 0.84)
            
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 5, height: 5)
                .position(x: size.width * 0.96, y: size.height * 0.96)
        }
        .frame(width: size.width, height: size.height)
    }
    
    private func calculateCircleSize(index: Int, frameSize: CGSize, radius: CGFloat) -> CGFloat {
        let maxCircleSize = frameSize.width - 2 * radius
        let reductionFactor: CGFloat = 0.15
        return maxCircleSize * (1 - CGFloat(index) * reductionFactor)
    }
}

#Preview {
    BlipView(size: CGSize(width: 56, height: 56))
}
