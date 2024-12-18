import SwiftUI

struct Home: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState

    enum DragState {
        case none
        case began
        case draggingUp
        case draggingDown
        case ended
    }

    @GestureState var gestureState: Bool = false
    @State var scrollOffset: CGFloat = 0
    @State var enableDrag = true
    @State var dragState: DragState = .none

    @State var bottomOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let screenHeight = proxy.size.height
            let minTopHeight = screenHeight

            ScrollView {
                VStack(spacing: 0) {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 4)], spacing: 4) {
                            ForEach(1 ... 50, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 120)
                            }
                        }
                    }
                    .frame(maxHeight: screenHeight)
                    .border(.green, width: 2)
                    .defaultScrollAnchor(.bottom)
                    .scrollClipDisabled()
                    .scrollDisabled(dragState == .draggingUp)

                    VStack(spacing: 4) {
                        ForEach(1 ... 12, id: \.self) { _ in
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 120)
                        }
                    }
                    .frame(alignment: .top)
                    .border(.red, width: 2)
                    .offset(y: bottomOffset)
                }
            }
            .defaultScrollAnchor(.top)
            .scrollClipDisabled()
            .frame(height: screenHeight, alignment: .top)
            .clipped()
            // .simultaneousGesture(
            //     DragGesture(minimumDistance: 0)
            //         .updating($gestureState) { _, state, _ in
            //             guard enableDrag else { return }
            //
            //             state = true
            //         }
            //         .onChanged { value in
            //             guard enableDrag else { return }
            //             let translation = value.translation.height
            //
            //             print("Drag Down \(translation)")
            //             if translation > 0 {
            //                 dragState = .draggingDown
            //             }
            //
            //             if translation < 0 {
            //                 dragState = .draggingUp
            //             }
            //         }
            //         .onEnded { _ in
            //             dragState = .ended
            //         }
            // )
            .scaleEffect(0.5)
            .onAppear {
                bottomOffset = -screenHeight * 0.4
            }
        }
    }
}

// .overlay(alignment: .bottom) {
//     LinearGradientMask(gradientColors: [.black.opacity(0.5), Color.clear])
//         .frame(height: safeAreaInsets.bottom * 2)
//         .scaleEffect(x: 1, y: -1)
// }
// .overlay(alignment: .top) {
//     LinearBlurView(radius: 2, gradientColors: [.clear, .black])
//         .scaleEffect(x: 1, y: -1)
//         .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top)
// }
/// User's Past?
// VStack(spacing: 12) {
//     /// Main Feed
//     BiomePreviewView(biome: Biome(entities: biomePreviewOne))
//     // BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
//     // BiomePreviewView(biome: Biome(entities: biomePreviewThree))
// }
// .onScrollGeometryChange(for: CGFloat.self, of: {
//     /// This will be zero when the content is placed at the bottom
//     $0.contentOffset.y - $0.contentSize.height + $0.containerSize.height
// }, action: { _, newValue in
//     scrollOffset = newValue
//     print(scrollOffset)
// })
