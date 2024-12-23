import SwiftUI

enum DragState {
    case idle
    case dragging
    case collapsedDown
    case expandedDown
    case collapsedUp
    case expandedUp
}

struct Home: View {
    // MARK: - Environment Variables

    @Environment(\.viewSize) private var viewSize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState

    // MARK: - Gesture State

    @GestureState var gestureState: Bool = false
    @State var dragState: DragState = .idle

    // MARK: - State Variables

    @State var isExpanded = false

    @State var mainOffset: CGPoint = .zero
    @State var mainHitTest = false
    @State var mainScrollDisabled: Bool = false
    @State var mainScrollOffset: CGFloat = 0

    @State var gridScrollOffset: CGPoint = .zero
    @State var gridContentSize: CGSize = .zero
    @State var gridScrollDisabled: Bool = false
    
    @State var gridScrollView: CollaborativeScrollView?
    @State var mainScrollView: CollaborativeScrollView?

    // MARK: - Constants

    var body: some View {
        let offset: CGFloat = viewSize.height * 0.7
        let gOffset: CGFloat = viewSize.height - offset
        let expandBoundary: CGFloat = gOffset / 2

        VStack {
            // Outer ScrollView
            ScrollableView(
                $mainOffset,
                animationDuration: 0.0,
                showsScrollIndicator: true,
                axis: .vertical,
                disableScroll: false
            ) {
                ZStack(alignment: .top) {
                    // Inner ScrollView
                    ScrollableView(
                        $gridScrollOffset,
                        animationDuration: 0.0,
                        showsScrollIndicator: true,
                        axis: .vertical,
                        disableScroll: false
                    ) {
                        VStack(spacing: 1) {
                            ForEach(1 ... 50, id: \.self) { _ in
                                Rectangle()
                                    .fill(.blue.mix(with: .white, by: 0.5))
                                    .frame(height: 120)
                            }
                        }
                        .padding(.bottom, gOffset)
                        .border(.yellow)
                        .readSize { newSize in
                            gridContentSize = newSize
                        } 
                    }
                    .viewExtractor { view in
                        if let scrollView = findScrollView(in: view) {
                            gridScrollView = scrollView
                            print("Found ScrollView \(scrollView)")
                        }
                    }
                    .frame(height: viewSize.height, alignment: .bottom)
                    .border(.blue, width: 4)
                    .zIndex(1)

                    VStack(spacing: 1) {
                        ForEach(1 ... 12, id: \.self) { _ in
                            Rectangle()
                                .fill(.red.mix(with: .black, by: 0.5))
                                .frame(height: 120)
                        }
                    }
                    .padding(.top, offset)
                }
            }
            .viewExtractor { view in
                if let scrollView = findScrollView(in: view) {
                    mainScrollView = scrollView
                }
            }
            .border(.red, width: 4)
            .onAppear {
                DispatchQueue.main.async {
                    let bottomOffset = max(0, gridContentSize.height - viewSize.height)
                    gridScrollOffset = CGPoint(x: 0, y: bottomOffset)
                }
            }
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .scaleEffect(0.75)
    }
}


func findScrollView(in view: UIView) -> CollaborativeScrollView? {
    if let scrollView = view as? CollaborativeScrollView {
        return scrollView
    }
    for subview in view.subviews {
        if let scrollView = findScrollView(in: subview) {
            return scrollView
        }
    }
    return nil
}

extension View {
    @ViewBuilder
    func viewExtractor(result: @escaping (UIView) -> ()) -> some View {
        self
            .background(ViewExtractorHelper(result: result))
            .compositingGroup()
    }
}

fileprivate struct ViewExtractorHelper: UIViewRepresentable {
    var result: (UIView) -> ()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            if let superView = view.superview?.superview?.subviews.last?.subviews.first {
                result(superView)
            }
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        
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
