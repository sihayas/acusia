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
        ZStack {
            // Radial layout with larger circle sizes
            RadialLayout(radius: size.width * 0.3, offset: .pi / 8) {
                ForEach(0..<selectedEmojis.count, id: \.self) { index in
                    let circleSize = calculateCircleSize(index: index, frameSize: size)
                    
                    Text(selectedEmojis[index])
                        .font(.system(size: circleSize / 2.5))
                        .frame(width: circleSize, height: circleSize)
                        .background(
                            Circle()
                                .stroke(.black, lineWidth: 2)
                                .fill(.ultraThinMaterial)
                        )
                        .zIndex(Double(index))
                }
            }
            
            // Bubble tail
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 10, height: 10)
                .position(x: size.width * 0.92, y: size.height * 0.92)
            
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 5, height: 5)
                .position(x: size.width * 1.05, y: size.height * 1.05)
        }
        .frame(width: size.width, height: size.height)
    }
    
    // Function to calculate larger circle sizes based on index and available frame size
    private func calculateCircleSize(index: Int, frameSize: CGSize) -> CGFloat {
        let baseSize = frameSize.width * 0.7
        return baseSize * (1 - CGFloat(index) * 0.15)
    }
}

#Preview {
    BlipView(size: CGSize(width: 56, height: 56))
}

/// Path Version...
//
// struct BlipView: View {
//     let size: CGSize
//     let emojis = ["😡", "💀", "🔥", "🎉", "😎", "👻", "🚀", "🌈", "🦄", "🍕", "🎸", "🌊", "🍦", "🌺", "🦋", "🌙"]
//
//     @State private var selectedEmojis: [String] = []
//
//     init(size: CGSize) {
//         self.size = size
//         let circleSizes = BlipShape.calculateCircleSizes(for: size)
//         _selectedEmojis = State(initialValue: (0..<circleSizes.count).map { _ in
//             emojis.randomElement() ?? "😊"
//         })
//     }
//
//     var body: some View {
//         ZStack {
//             Rectangle()
//                 .background(.ultraThinMaterial)
//                 .foregroundStyle(.clear)
//                 .clipShape(BlipShape(size: size))
//
//             let circleSizes = BlipShape.calculateCircleSizes(for: size)
//
//             ForEach(0 ..< circleSizes.count, id: \.self) { index in
//                 Text(selectedEmojis[index])
//                     .font(.system(size: circleSizes[index]/2.5))
//                     .position(circlePosition(for: index, in: size, circleSizes: circleSizes))
//             }
//         }
//         .frame(width: size.height, height: size.height)
//     }
//
//     private func circlePosition(for index: Int, in size: CGSize, circleSizes: [CGFloat]) -> CGPoint {
//         BlipShape
//             .circleCenter(
//                 for: index,
//                 in: CGRect(origin: .zero, size: size),
//                 circleSizes: circleSizes
//             )
//     }
// }
//
// struct BlipShape: Shape {
//     let size: CGSize
//     static let baseCircleSizes: [CGFloat] = [30, 26, 22]
//
//     func path(in rect: CGRect) -> Path {
//         var path = Path()
//
//         let circleSizes = BlipShape.calculateCircleSizes(for: rect.size)
//
//         // Main circles
//         for (index, size) in circleSizes.enumerated() {
//             let center = BlipShape.circleCenter(for: index, in: rect, circleSizes: circleSizes)
//             path.addEllipse(in: CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size))
//         }
//
//         // Tail bubbles
//         let bigTailSize: CGFloat = 8
//         let smallTailSize: CGFloat = 4
//
//         // Position larger tail circle
//         let bigTailCenter = CGPoint(
//             x: rect.maxX - bigTailSize,
//             y: rect.maxY - bigTailSize
//         )
//         path.addEllipse(in: CGRect(
//             x: bigTailCenter.x - bigTailSize/2,
//             y: bigTailCenter.y - bigTailSize/2,
//             width: bigTailSize,
//             height: bigTailSize
//         ))
//
//         // Position smaller tail circle
//         let smallTailCenter = CGPoint(
//             x: bigTailCenter.x + bigTailSize/2 + smallTailSize/2,
//             y: bigTailCenter.y + bigTailSize/2 + smallTailSize/2
//         )
//         path.addEllipse(in: CGRect(x: smallTailCenter.x - smallTailSize/2, y: smallTailCenter.y - smallTailSize/2, width: smallTailSize, height: smallTailSize))
//
//         return path
//     }
//
//     static func calculateCircleSizes(for frameSize: CGSize) -> [CGFloat] {
//         let scaleFactor = frameSize.width/56 // Base frame size is 56x56
//         return baseCircleSizes.map { $0 * scaleFactor }
//     }
//
//     static func circleCenter(for index: Int, in rect: CGRect, circleSizes: [CGFloat]) -> CGPoint {
//         let angle = CGFloat(index) * (2 * .pi/CGFloat(circleSizes.count)) + .pi/4
//         let maxSize = circleSizes.max() ?? 0
//         let radius = min(rect.width, rect.height)/2 - maxSize/2
//         return CGPoint(
//             x: rect.midX + radius * cos(angle),
//             y: rect.midY + radius * sin(angle)
//         )
//     }
// }
