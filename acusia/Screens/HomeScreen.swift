/// This took a MONTH to figure out for some reason. I spent way too long try to pull it off in pure SwiftUI.
/// Thanks to https://stackoverflow.com/questions/25793141/continuous-vertical-scrolling-between-uicollectionview-nested-in-uiscrollview
import SwiftUI

class CollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate {
    var lastContentOffset: CGPoint = .zero

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view is CollaborativeScrollView
    }
}

class CSVDelegate: NSObject, UIScrollViewDelegate {
    private var lockOuterScrollView = false
    weak var outerScrollView: CollaborativeScrollView?
    weak var innerScrollView: CollaborativeScrollView?

    enum Direction { case none, up, down }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let csv = scrollView as? CollaborativeScrollView else { return }

        let direction: Direction
        if csv.lastContentOffset.y > csv.contentOffset.y {
            direction = .up
        } else {
            direction = .down
        }

        if csv === innerScrollView {
            let isAtBottom = (csv.contentOffset.y + csv.frame.size.height) >= csv.contentSize.height
            let isAtTop = csv.contentOffset.y <= 0

            if (direction == .down && isAtBottom) || (direction == .up && isAtTop) {
                lockOuterScrollView = false
                outerScrollView?.showsVerticalScrollIndicator = true
            } else {
                lockOuterScrollView = true
                outerScrollView?.showsVerticalScrollIndicator = false
            }
        } else if lockOuterScrollView {
            outerScrollView?.contentOffset = outerScrollView?.lastContentOffset ?? .zero
            outerScrollView?.showsVerticalScrollIndicator = false
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
        scrollView.delegate = scrollDelegate
        scrollView.bounces = !isInner

        let hostController = UIHostingController(rootView: content)
        hostController.view.translatesAutoresizingMaskIntoConstraints = false
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

struct Home: View {
    let scrollDelegate = CSVDelegate()

    var body: some View {
        NestedScrollView(delegate: scrollDelegate) {
            VStack {
                NestedScrollView(isInner: true, delegate: scrollDelegate) {
                    VStack {
                        ForEach(0 ..< 60) { _ in
                            Color.blue.frame(height: 100)
                        }
                    }
                }
                .frame(height: 300)

                Color.red.frame(height: 300)

                Color.green.frame(height: 500)
            }
        }
    }
}

#Preview {
    Home()
        .ignoresSafeArea()
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
