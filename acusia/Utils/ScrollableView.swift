//
//  ScrollableView.swift
//  acusia
//
//  Created by decoherence on 12/22/24.
//
import SwiftUI

class CollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate {
    /// Track previous offset to detect scroll direction
    var lastContentOffset: CGPoint = .zero
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGesture()
    }
    
    private func setupGesture() {
        /// Allow simultaneous recognition only with other CollaborativeScrollViews
        self.panGestureRecognizer.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return otherGestureRecognizer.view is CollaborativeScrollView
    }
}

// MARK: - ScrollableView

enum ScrollDirection {
    case none, up, down
}

struct ScrollableView<Content: View>: UIViewControllerRepresentable, Equatable {
    // MARK: - Coordinator

    final class Coordinator: NSObject, UIScrollViewDelegate {
        // MARK: - Properties

        private let scrollView: CollaborativeScrollView
        var offset: Binding<CGPoint>

        // Track if outer scroll is locked
        private var lockOuterScroll = false
            
        // If you have a nested CollaborativeScrollView, store it here
        weak var nestedScrollView: CollaborativeScrollView?

        // MARK: - Init

        init(_ scrollView: CollaborativeScrollView,
             offset: Binding<CGPoint>,
             nestedScrollView: CollaborativeScrollView? = nil)
        {
            self.scrollView = scrollView
            self.offset = offset
            self.nestedScrollView = nestedScrollView
            super.init()
            self.scrollView.delegate = self

            // If there’s an inner scrollview, set the same coordinator as delegate
            self.nestedScrollView?.delegate = self
        }
            
        // MARK: - UIScrollViewDelegate

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let collabScroll = scrollView as? CollaborativeScrollView else { return }

            DispatchQueue.main.async {
                self.offset.wrappedValue = scrollView.contentOffset
            }

            // 1) Detect direction
            let direction: ScrollDirection
            if collabScroll.lastContentOffset.y > collabScroll.contentOffset.y {
                direction = .up
            } else if collabScroll.lastContentOffset.y < collabScroll.contentOffset.y {
                direction = .down
            } else {
                direction = .none
            }
                
            // 2) If the user is scrolling the inner scrollview
            if collabScroll == self.nestedScrollView {
                let isAtBottom = collabScroll.contentOffset.y + collabScroll.frame.size.height >= collabScroll.contentSize.height
                let isAtTop = collabScroll.contentOffset.y <= 0
                    
                // Unlock outer only when we’ve hit top or bottom of inner
                if (direction == .down && isAtBottom) || (direction == .up && isAtTop) {
                    self.lockOuterScroll = false
                } else {
                    self.lockOuterScroll = true
                }
            }
            // 3) If the user is scrolling the outer scrollview but it's locked
            else if self.lockOuterScroll {
                // Force outer to remain at the same offset => "locked"
                collabScroll.contentOffset = collabScroll.lastContentOffset
            }

            // 4) Update last offset
            collabScroll.lastContentOffset = collabScroll.contentOffset
        }
    }
    
    // MARK: - Type

    typealias UIViewControllerType = UIScrollViewController<Content>
    
    // MARK: - Properties

    var offset: Binding<CGPoint>
    var animationDuration: TimeInterval
    var showsScrollIndicator: Bool
    var axis: Axis
    var content: () -> Content
    var onScale: ((CGFloat) -> Void)?
    var disableScroll: Bool
    var forceRefresh: Bool
    var stopScrolling: Binding<Bool>
    private let scrollViewController: UIViewControllerType

    // MARK: - Init

    init(_ offset: Binding<CGPoint>, animationDuration: TimeInterval, showsScrollIndicator: Bool = true, axis: Axis = .vertical, onScale: ((CGFloat) -> Void)? = nil, disableScroll: Bool = false, forceRefresh: Bool = false, stopScrolling: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping () -> Content) {
        self.offset = offset
        self.onScale = onScale
        self.animationDuration = animationDuration
        self.content = content
        self.showsScrollIndicator = showsScrollIndicator
        self.axis = axis
        self.disableScroll = disableScroll
        self.forceRefresh = forceRefresh
        self.stopScrolling = stopScrolling
        self.scrollViewController = UIScrollViewController(rootView: self.content(), offset: self.offset, axis: self.axis, onScale: self.onScale)
    }
    
    // MARK: - Updates

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UIViewControllerType {
        self.scrollViewController
    }

    func updateUIViewController(_ viewController: UIViewControllerType, context: UIViewControllerRepresentableContext<Self>) {
        viewController.scrollView.showsVerticalScrollIndicator = self.showsScrollIndicator
        viewController.scrollView.showsHorizontalScrollIndicator = self.showsScrollIndicator
        viewController.updateContent(self.content)

        let duration: TimeInterval = self.duration(viewController)
        let newValue: CGPoint = self.offset.wrappedValue
        viewController.scrollView.isScrollEnabled = !self.disableScroll
        
        if self.stopScrolling.wrappedValue {
            viewController.scrollView.setContentOffset(viewController.scrollView.contentOffset, animated: false)
            return
        }
        
        guard duration != .zero else {
            viewController.scrollView.contentOffset = newValue
            return
        }
         
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 25,
            initialSpringVelocity: 100,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                viewController.scrollView.contentOffset = newValue
            },
            completion: nil
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self.scrollViewController.scrollView, offset: self.offset)
    }
    
    // Calcaulte max offset
    private func newContentOffset(_ viewController: UIViewControllerType, newValue: CGPoint) -> CGPoint {
        let maxOffsetViewFrame: CGRect = viewController.view.frame
        let maxOffsetFrame: CGRect = viewController.hostingController.view.frame
        let maxOffsetX: CGFloat = maxOffsetFrame.maxX - maxOffsetViewFrame.maxX
        let maxOffsetY: CGFloat = maxOffsetFrame.maxY - maxOffsetViewFrame.maxY
        
        return CGPoint(x: min(newValue.x, maxOffsetX), y: min(newValue.y, maxOffsetY))
    }
    
    // Calculate animation speed
    private func duration(_ viewController: UIViewControllerType) -> TimeInterval {
        var diff: CGFloat = 0
        
        switch self.axis {
            case .horizontal:
                diff = abs(viewController.scrollView.contentOffset.x - self.offset.wrappedValue.x)
            default:
                diff = abs(viewController.scrollView.contentOffset.y - self.offset.wrappedValue.y)
        }
        
        if diff == 0 {
            return .zero
        }
        
        let percentageMoved = diff / UIScreen.main.bounds.height
        
        return self.animationDuration * min(max(TimeInterval(percentageMoved), 0.25), 1)
    }
    
    // MARK: - Equatable

    static func == (lhs: ScrollableView, rhs: ScrollableView) -> Bool {
        return !lhs.forceRefresh && lhs.forceRefresh == rhs.forceRefresh
    }
}

// MARK: - UIScrollViewController

final class UIScrollViewController<Content: View>: UIViewController, ObservableObject {
    // MARK: - Properties

    var offset: Binding<CGPoint>
    var onScale: ((CGFloat) -> Void)?
    let hostingController: UIHostingController<Content>
    private let axis: Axis
    lazy var scrollView: CollaborativeScrollView = {
        let scrollView = CollaborativeScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.canCancelContentTouches = true
        scrollView.delaysContentTouches = true
        scrollView.scrollsToTop = false
        scrollView.backgroundColor = .clear
        
        if self.onScale != nil {
            scrollView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: self,
                action: #selector(self.onGesture)
            ))
        }
        
        return scrollView
    }()
    
    @objc func onGesture(gesture: UIPinchGestureRecognizer) {
        self.onScale?(gesture.scale)
    }

    // MARK: - Init

    init(rootView: Content, offset: Binding<CGPoint>, axis: Axis, onScale: ((CGFloat) -> Void)?) {
        self.offset = offset
        self.hostingController = UIHostingController<Content>(rootView: rootView)
        self.hostingController.view.backgroundColor = .clear
        self.axis = axis
        self.onScale = onScale
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Update

    func updateContent(_ content: () -> Content) {
        self.hostingController.rootView = content()
        self.scrollView.addSubview(self.hostingController.view)
        
        var contentSize: CGSize = self.hostingController.view.intrinsicContentSize
        
        switch self.axis {
            case .vertical:
                contentSize.width = self.scrollView.frame.width
            case .horizontal:
                contentSize.height = self.scrollView.frame.height
        }
        
        self.hostingController.view.frame.size = contentSize
        self.scrollView.contentSize = contentSize
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.createConstraints()
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Constraints

    fileprivate func createConstraints() {
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
