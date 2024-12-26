/// This took a MONTH to figure out for some reason. I spent way too long try to pull it off in pure SwiftUI.
/// Thanks to https://stackoverflow.com/questions/25793141/continuous-vertical-scrolling-between-uicollectionview-nested-in-uiscrollview
import SwiftUI

struct Home: View {
    @Environment(\.viewSize) private var viewSize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState

    let scrollDelegate = CSVDelegate()

    var body: some View {
        let size = viewSize
        let innerSize = size.height * 0.7
        let innerOffset = size.height - innerSize

        NestedScrollView(delegate: scrollDelegate) {
            ZStack(alignment: .top) {
                NestedScrollView(isInner: true, delegate: scrollDelegate) {
                    VStack(spacing: 1) {
                        ForEach(0 ..< 60) { _ in
                            Color.blue.frame(height: 100)
                        }
                    }

                    Spacer()
                        .frame(height: innerOffset)
                }
                .ignoresSafeArea()
                .frame(height: size.height)
                .border(.green)

                Color.red.frame(height: size.height * 2)
                    .padding(.top, innerSize)
                    .opacity(0.5)
            }
        }
        .ignoresSafeArea()
    }
}

class CollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate {
    var lastContentOffset: CGPoint = .zero
    var initialContentOffset: CGPoint = .zero

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view is CollaborativeScrollView
    }
}

class CSVDelegate: NSObject, UIScrollViewDelegate {
    private var initialDirection: Direction = .none
    private var lockOuterScrollView = false
    private var lockInnerScrollView = true
    weak var outerScrollView: CollaborativeScrollView?
    weak var innerScrollView: CollaborativeScrollView?

    enum Direction { case none, up, down }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CollaborativeScrollView else { return }
        csv.initialContentOffset = csv.contentOffset

        initialDirection = .none

        /// Prepare to unlock inner scroll view at the inflection point.
        if csv === outerScrollView {
            lockInnerScrollView = csv.initialContentOffset.y > 0
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // print("Will end dragging")
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // if content offset <= 0 and i end dragging!
        // print("Did end dragging")
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CollaborativeScrollView else { return }

        let direction: Direction
        if csv.lastContentOffset.y > csv.contentOffset.y {
            direction = .up
        } else {
            direction = .down
        }

        if initialDirection == .none && csv.contentOffset.y != csv.initialContentOffset.y {
            initialDirection = csv.contentOffset.y > csv.initialContentOffset.y ? .down : .up
        }

        if csv === outerScrollView {
            /// If the user chooses to scroll down at the inflection point, lock the inner scroll view.
            if !lockInnerScrollView, !lockOuterScrollView, initialDirection == .down {
                lockInnerScrollView = true
            }

            if lockOuterScrollView {
                csv.contentOffset = CGPoint(x: 0, y: 0)
                csv.showsVerticalScrollIndicator = false
            }
        }

        if csv === innerScrollView {
            /// Check if inner scroll view is at extremes
            let isAtBottom = (csv.contentOffset.y + csv.frame.size.height) >= csv.contentSize.height
            let isAtTop = csv.contentOffset.y <= 0

            /// Allow outer scroll if inner is at extremes
            if direction == .down && isAtBottom {
                lockOuterScrollView = false
                outerScrollView?.showsVerticalScrollIndicator = true
            } else {
                lockOuterScrollView = true
                outerScrollView?.showsVerticalScrollIndicator = false
            }

            /// Keep/set the inner scroll view to its resting position & do not allow scrolling.
            if lockInnerScrollView {
                csv.contentOffset.y = csv.contentSize.height - csv.bounds.size.height
            }
        }

        csv.lastContentOffset = csv.contentOffset
    }
}

struct NestedScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let isInner: Bool
    private let scrollDelegate: CSVDelegate

    init(isInner: Bool = false, delegate: CSVDelegate, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isInner = isInner
        self.scrollDelegate = delegate
    }

    func makeUIView(context: Context) -> CollaborativeScrollView {
        let scrollView = CollaborativeScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = scrollDelegate
        scrollView.bounces = !isInner

        let hostController = UIHostingController(rootView: content)
        hostController.view.translatesAutoresizingMaskIntoConstraints = false
        hostController.view.backgroundColor = .clear
        hostController.safeAreaRegions = SafeAreaRegions()
        scrollView.addSubview(hostController.view)

        NSLayoutConstraint.activate([
            hostController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        if isInner {
            scrollDelegate.innerScrollView = scrollView

            DispatchQueue.main.async {
                let bottomOffset = CGPoint(
                    x: 0,
                    y: scrollView.contentSize.height - scrollView.bounds.size.height
                )
                if bottomOffset.y > 0 {
                    scrollView.setContentOffset(bottomOffset, animated: false)
                }
            }
        } else {
            scrollDelegate.outerScrollView = scrollView
        }

        return scrollView
    }

    func updateUIView(_ uiView: CollaborativeScrollView, context: Context) {}
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
