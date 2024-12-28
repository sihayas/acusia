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
    private var isExpanded = false
    private var lockOuterScrollView = false
    private var lockInnerScrollView = true
    private var initialDirection: Direction = .none
    weak var outerScrollView: CollaborativeScrollView?
    weak var innerScrollView: CollaborativeScrollView?

    enum Direction { case none, up, down }

    /// Lets the user begin expanding/collapsing. Unlocks scrolls if conditions are met.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CollaborativeScrollView else { return }
        csv.initialContentOffset = csv.contentOffset

        initialDirection = .none

        /// If dragging starts at top of outer, unlock inner to allow expansion.
        if !isExpanded {
            if csv === outerScrollView {
                lockInnerScrollView = csv.initialContentOffset.y > 0
            }
        }

        /// If dragging starts at bottom of inner, unlock outer to allow collapse.
        if isExpanded {
            let isAtBottom = ((innerScrollView!.contentOffset.y + innerScrollView!.frame.size.height) >= innerScrollView!.contentSize.height)
            lockOuterScrollView = !isAtBottom
        }
    }

    /// Decides if we commit to expanded or collapsed based on final scroll position.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let csv = scrollView as? CollaborativeScrollView else { return }

        /// Mark expanded if user scrolled inner enough.
        if !isExpanded, csv === innerScrollView {
            let bottom = csv.contentSize.height - csv.bounds.size.height

            if csv.contentOffset.y < bottom {
                isExpanded = true
                csv.bounces = true
            }
        }

        /// Collapse if user scrolled outer (means they want to go back).
        if isExpanded, csv === outerScrollView {
            if csv.contentOffset.y > 0 {
                innerScrollView?.bounces = false
                isExpanded = false
            }
        }
    }

    /// Cleanup post-drag. Good place to snap locked scroll offsets if needed.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}

    /// Core logic that locks/unlocks outer and inner scrolls depending on state and direction.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CollaborativeScrollView else { return }
        let direction: Direction = csv.lastContentOffset.y > csv.contentOffset.y ? .up : .down

        /// Note the initial direction to abort a possible expansion/unexpansion
        if initialDirection == .none && csv.contentOffset.y != csv.initialContentOffset.y {
            initialDirection = csv.contentOffset.y > csv.initialContentOffset.y ? .down : .up
        }

        /// Lock outer: force offset to top and hide indicator.
        if lockOuterScrollView {
            outerScrollView!.contentOffset = CGPoint(x: 0, y: 0)
            outerScrollView!.showsVerticalScrollIndicator = false
        }

        /// Lock inner: force offset to bottom and hide indicator.
        if lockInnerScrollView {
            innerScrollView!.contentOffset.y = innerScrollView!.contentSize.height - innerScrollView!.bounds.size.height
        }

        if !isExpanded {
            /// Abort expansion if user drags downward immediately. Works in tandom with
            /// `scrollViewWillBeginDragging`.
            if initialDirection == .down, !lockInnerScrollView {
                lockInnerScrollView = true
            }

            if csv === innerScrollView {
                let isAtBottom = (csv.contentOffset.y + csv.frame.size.height) >= csv.contentSize.height

                if !lockInnerScrollView {
                    if direction == .up && outerScrollView?.contentOffset.y ?? 0 <= 0 {
                        lockOuterScrollView = true
                    } else if direction == .down && isAtBottom {
                        lockOuterScrollView = false
                    }
                }
            }
        }

        if isExpanded {
            /// Abort collapse if user scrolls upward immediately. Works in tandom with `scrollViewWillBeginDragging`.
            if initialDirection == .up, !lockOuterScrollView {
                lockOuterScrollView = true
            }

            if csv === innerScrollView {
                let isAtBottom = (csv.contentOffset.y + csv.frame.size.height) >= csv.contentSize.height

                if !lockOuterScrollView {
                    if direction == .down && isAtBottom {
                        lockInnerScrollView = true
                    } else if direction == .up && outerScrollView?.contentOffset.y ?? 0 <= 0 {
                        lockOuterScrollView = true
                    }
                }
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
