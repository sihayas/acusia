/// This took a MONTH to figure out for some reason. I spent way too long try to pull it off in pure SwiftUI.
/// https://stackoverflow.com/questions/25793141/continuous-vertical-scrolling-between-uicollectionview-nested-in-uiscrollview
import SwiftUI

struct Home: View {
    @Environment(\.viewSize) private var viewSize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState

    let scrollDelegate = CSVDelegate()

    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]

    private let biomes = [
        Biome(entities: biomePreviewOne),
        Biome(entities: biomePreviewTwo)
    ]

    var body: some View {
        let upperSectionHeight = viewSize.width
        let bottomSectionHeight = viewSize.height - upperSectionHeight

        CSVRepresentable(delegate: scrollDelegate) {
            ZStack(alignment: .top) {
                // MARK: - Nested Scroll View

                CSVRepresentable(isInner: true, delegate: scrollDelegate) {
                    VStack(spacing: 0) {
                        /// User History
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(userHistorySample.indices, id: \.self) { index in
                                EntityView(
                                    rootEntity: userHistorySample[index],
                                    previousEntity: userHistorySample[index],
                                    entity: userHistorySample[index]
                                )
                            }
                        }
                        .safeAreaPadding(.horizontal)

                        /// Biomes
                        LazyVGrid(columns: columns) {
                            ForEach(0 ..< biomes.count, id: \.self) { index in
                                BiomePreviewSphereView(biome: biomes[index])
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: upperSectionHeight - safeAreaInsets.top)

                        /// Spacer/Offset
                        Rectangle()
                            .fill(.clear)
                            .frame(height: bottomSectionHeight)
                            .border(.red)
                    }
                }
                .frame(height: viewSize.height)

                // MARK: - Outer Scroll View

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: upperSectionHeight)

                    LazyVStack(spacing: 12) {
                        BiomePreviewView(biome: Biome(entities: biomePreviewOne))
                        BiomePreviewView(biome: Biome(entities: biomePreviewTwo))
                        BiomePreviewView(biome: Biome(entities: biomePreviewThree))
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .overlay(alignment: .top) {
            LinearBlurView(radius: 4, gradientColors: [.clear, .black])
                .scaleEffect(x: 1, y: -1)
                .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top * 2)
        
            LinearGradientMask(gradientColors: [.black, Color.clear])
                .frame(maxWidth: .infinity, maxHeight: safeAreaInsets.top * 2)
        }

    }
}

class CSV: UIScrollView, UIGestureRecognizerDelegate {
    var lastContentOffset: CGPoint = .zero
    var initialContentOffset: CGPoint = .zero
    var isInner: Bool = false

    // Add reference to the other scroll view's gesture recognizer
    var otherPanGestureRecognizer: UIPanGestureRecognizer?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        // Make sure we're the delegate for our own pan gesture recognizer
        panGestureRecognizer.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous recognition with the other scroll view's gesture
        if otherGestureRecognizer == otherPanGestureRecognizer {
            return true
        }
        return false
    }
}

struct CSVRepresentable<Content: View>: UIViewRepresentable {
    let content: Content
    let isInner: Bool
    private let scrollDelegate: CSVDelegate

    init(isInner: Bool = false, delegate: CSVDelegate, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isInner = isInner
        self.scrollDelegate = delegate
    }

    func makeUIView(context: Context) -> CSV {
        /// Create the CollaborativeScrollView in UIKit.
        let scrollView = CSV()
        scrollView.isInner = isInner
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = scrollDelegate
        scrollView.bounces = !isInner

        let hostController = UIHostingController(rootView: content)
        hostController.view.translatesAutoresizingMaskIntoConstraints = false
        hostController.view.backgroundColor = .clear
        hostController.safeAreaRegions = SafeAreaRegions()
        scrollView.addSubview(hostController.view)

        /// Constrain the SwiftUI content to the edges of the CollaborativeScrollView.
        NSLayoutConstraint.activate([
            hostController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
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

                self.scrollDelegate.setupGestureRecognizers()
            }
        } else {
            scrollDelegate.outerScrollView = scrollView
        }

        return scrollView
    }

    func updateUIView(_ uiView: CSV, context: Context) {}
}

class CSVDelegate: NSObject, UIScrollViewDelegate {
    private var isExpanded = false
    private var lockOuterScrollView = false
    private var lockInnerScrollView = true
    private var initialDirection: Direction = .none
    weak var outerScrollView: CSV?
    weak var innerScrollView: CSV?

    enum Direction { case none, up, down }

    func setupGestureRecognizers() {
        guard let inner = innerScrollView, let outer = outerScrollView else { return }

        // Connect the gesture recognizers
        inner.otherPanGestureRecognizer = outer.panGestureRecognizer
        outer.otherPanGestureRecognizer = inner.panGestureRecognizer

        // Add both gesture recognizers to the outer scroll view
        if let innerPan = inner.panGestureRecognizer as? UIPanGestureRecognizer {
            outer.addGestureRecognizer(innerPan)
        }
    }

    /// Lets the user begin expanding/collapsing. Unlocks scrolls if conditions are met.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CSV else { return }
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
        guard let csv = scrollView as? CSV else { return }

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
        guard let csv = scrollView as? CSV else { return }
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

extension View {
    @ViewBuilder
    func viewExtractor(result: @escaping (UIView) -> ()) -> some View {
        background(ViewExtractorHelper(result: result))
            .compositingGroup()
    }
}

private struct ViewExtractorHelper: UIViewRepresentable {
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

    func updateUIView(_ uiView: UIView, context: Context) {}
}
