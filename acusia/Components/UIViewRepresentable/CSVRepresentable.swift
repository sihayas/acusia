//
//  CSVRepresentable.swift
//  acusia
//
//  Created by decoherence on 1/12/25.
//

import SwiftUI

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

class CSVDelegate: NSObject, UIScrollViewDelegate, ObservableObject {
    @Published var isExpanded = false
    @Published var dragOffset: CGFloat = 0
    @Published var trackDragOffset = true
    
    private var lockOuterScrollView = false
    private var lockInnerScrollView = true
    private var initialDirection: Direction = .none

    weak var outerScrollView: CSV?
    weak var innerScrollView: CSV?

    enum Direction { case none, up, down }

    func setupGestureRecognizers() {
        guard let inner = innerScrollView, let outer = outerScrollView else { return }

        inner.otherPanGestureRecognizer = outer.panGestureRecognizer
        outer.otherPanGestureRecognizer = inner.panGestureRecognizer

        outer.addGestureRecognizer(inner.panGestureRecognizer)
    }

    /// Lets the user begin expanding/collapsing. Unlocks scrolls if conditions are met.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CSV else { return }
        csv.initialContentOffset = csv.contentOffset

        initialDirection = .none

        /// If dragging starts at top of outer, unlock inner to allow expansion.
        if !isExpanded {
            if csv === outerScrollView {
                if csv.initialContentOffset.y > 0 {
                    trackDragOffset = false
                    lockInnerScrollView = true
                } else {
                    trackDragOffset = true
                    lockInnerScrollView = false
                }
            }
        }
 
        /// If dragging starts at bottom of inner, unlock outer to allow collapse.
        if isExpanded {
            let isAtBottom = ((innerScrollView!.contentOffset.y + innerScrollView!.frame.size.height) >= innerScrollView!.contentSize.height)
            if isAtBottom {
                trackDragOffset = true
                lockOuterScrollView = false
            } else {
                trackDragOffset = false
                lockOuterScrollView = true
            }
        }
    }

    /// Decides if we commit to expanded or collapsed based on final scroll position.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let csv = scrollView as? CSV else { return }

        /// Mark expanded if user scrolled inner enough.
        if !isExpanded, csv === innerScrollView {
            let bottom = csv.contentSize.height - csv.bounds.size.height

            if csv.contentOffset.y < bottom {
                trackDragOffset = false
                isExpanded = true
                csv.bounces = true
            }
        }

        /// Collapse if user scrolled outer (means they want to go back).
        if isExpanded, csv === outerScrollView {
            if csv.contentOffset.y > 0 {
                trackDragOffset = false
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

        if trackDragOffset {
            dragOffset = csv.panGestureRecognizer.translation(in: csv).y
        }
  
        if !isExpanded {
            /// Abort expansion if user drags downward immediately. Works in tandom with
            /// `scrollViewWillBeginDragging`.
            if initialDirection == .down, !lockInnerScrollView {
                lockInnerScrollView = true
            }

            if csv === innerScrollView {
                let isAtBottom = (csv.contentOffset.y + csv.frame.size.height) >= csv.contentSize.height

                /// Expansion logic
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

                /// Collapse logic
                if !lockOuterScrollView {
                    dragOffset = csv.panGestureRecognizer.translation(in: csv).y
                    print("expanded dragOffset: \(dragOffset)")
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
