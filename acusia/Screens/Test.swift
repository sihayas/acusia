// //
// //  homebase.swift
// //  acusia
// //
// //  Created by decoherence on 12/30/24.
// //
// 
// import SwiftUI
// 
// struct Home: View {
//     let scrollDelegate = CSVDelegate()
// 
//     var body: some View {
//         NestedScrollView(delegate: scrollDelegate) {
//             ZStack(alignment: .top) {
//                 VStack {
//                     Spacer()
//                         .frame(height: 500)
// 
//                     Button {
//                         print("Button tapped")
//                     } label: {
//                         Image(systemName: "plus")
//                             .fontWeight(.semibold)
//                             .font(.subheadline)
//                             .foregroundStyle(.white)
//                             .frame(width: 40, height: 40)
//                             .background(
//                                 TintedBlurView(style: .systemChromeMaterialDark, backgroundColor: .brown, blurMutingFactor: 0.25)
//                             )
//                             .clipShape(Capsule())
//                     }
// 
//                     Color.red.frame(height: 1000)
//                         .opacity(0.5)
//                 }
// 
//                 NestedScrollView(isInner: true, delegate: scrollDelegate) {
//                     VStack {
//                         ForEach(0 ..< 60) { _ in
//                             Color.blue.frame(height: 100)
//                                 .opacity(0.5)
//                         }
//                     }
// 
//                     Spacer()
//                         .frame(height: 500)
//                 }
//                 .frame(height: UIScreen.main.bounds.height)
//             }
//         }
//     }
// }
// 
// class CollaborativeScrollView: UIScrollView, UIGestureRecognizerDelegate {
//     var lastContentOffset: CGPoint = .zero
// 
//     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//         return otherGestureRecognizer.view is CollaborativeScrollView
//     }
// }
// 
// class CSVDelegate: NSObject, UIScrollViewDelegate {
//     private var lockOuterScrollView = false
//     weak var outerScrollView: CollaborativeScrollView?
//     weak var innerScrollView: CollaborativeScrollView?
// 
//     enum Direction { case none, up, down }
// 
//     func scrollViewDidScroll(_ scrollView: UIScrollView) {
//         guard let csv = scrollView as? CollaborativeScrollView else { return }
// 
//         let direction: Direction
//         if csv.lastContentOffset.y > csv.contentOffset.y {
//             direction = .up
//         } else {
//             direction = .down
//         }
// 
//         if csv === innerScrollView {
//             let isAtBottom = (csv.contentOffset.y + csv.frame.size.height) >= csv.contentSize.height
//             let isAtTop = csv.contentOffset.y <= 0
// 
//             if (direction == .down && isAtBottom) || (direction == .up && isAtTop) {
//                 lockOuterScrollView = false
//                 outerScrollView?.showsVerticalScrollIndicator = true
//             } else {
//                 lockOuterScrollView = true
//                 outerScrollView?.showsVerticalScrollIndicator = false
//             }
//         } else if lockOuterScrollView {
//             outerScrollView?.contentOffset = outerScrollView?.lastContentOffset ?? .zero
//             outerScrollView?.showsVerticalScrollIndicator = false
//         }
// 
//         csv.lastContentOffset = csv.contentOffset
//     }
// }
// 
// struct NestedScrollView<Content: View>: UIViewRepresentable {
//     let content: Content
//     let isInner: Bool
//     private let scrollDelegate: CSVDelegate
// 
//     init(isInner: Bool = false, delegate: CSVDelegate, @ViewBuilder content: () -> Content) {
//         self.content = content()
//         self.isInner = isInner
//         self.scrollDelegate = delegate
//     }
// 
//     func makeUIView(context: Context) -> CollaborativeScrollView {
//         /// Create the CollaborativeScrollView in UIKit.
//         let scrollView = CollaborativeScrollView()
//         scrollView.contentInsetAdjustmentBehavior = .never
//         scrollView.delegate = scrollDelegate
//         scrollView.bounces = !isInner
// 
//         if isInner {
//             let hostingParentView = HostingParentView()
//             hostingParentView.translatesAutoresizingMaskIntoConstraints = false
//             hostingParentView.makeBackgroundsClear = true
// 
//             let hostController = UIHostingController(rootView: content)
//             hostController.view.translatesAutoresizingMaskIntoConstraints = false
// 
//             scrollView.addSubview(hostingParentView)
// 
//             NSLayoutConstraint.activate([
//                 hostingParentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
//                 hostingParentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
//                 hostingParentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
//                 hostingParentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
//                 hostingParentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
//             ])
// 
//             hostingParentView.addSubview(hostController.view)
//             NSLayoutConstraint.activate([
//                 hostController.view.leadingAnchor.constraint(equalTo: hostingParentView.leadingAnchor),
//                 hostController.view.trailingAnchor.constraint(equalTo: hostingParentView.trailingAnchor),
//                 hostController.view.topAnchor.constraint(equalTo: hostingParentView.topAnchor),
//                 hostController.view.bottomAnchor.constraint(equalTo: hostingParentView.bottomAnchor)
//             ])
// 
//             scrollDelegate.innerScrollView = scrollView
// 
//             DispatchQueue.main.async {
//                 let bottomOffset = CGPoint(
//                     x: 0,
//                     y: scrollView.contentSize.height - scrollView.bounds.size.height
//                 )
//                 if bottomOffset.y > 0 {
//                     scrollView.setContentOffset(bottomOffset, animated: false)
//                 }
//             }
//         } else {
//             /// Embed the SwiftUI content in a UIHostingController.
//             let hostController = UIHostingController(rootView: content)
//             hostController.view.translatesAutoresizingMaskIntoConstraints = false
//             hostController.view.backgroundColor = .clear
//             hostController.safeAreaRegions = SafeAreaRegions()
//             scrollView.addSubview(hostController.view)
// 
//             /// Constrain the SwiftUI content to the edges of the CollaborativeScrollView.
//             NSLayoutConstraint.activate([
//                 hostController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
//                 hostController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
//                 hostController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
//                 hostController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
//                 hostController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
//             ])
// 
//             scrollDelegate.outerScrollView = scrollView
//         }
// 
//         return scrollView
//     }
// 
//     func updateUIView(_ uiView: CollaborativeScrollView, context: Context) {}
// }
// 
// // #Preview {
// //     Home()
// //         .ignoresSafeArea()
// // }
// // 
// // class ViewController: UIViewController {
// //     let hostingController = UIHostingController(rootView: AView())
// //     let hostingController2 = UIHostingController(rootView: AView2())
// //     let hostingController3 = UIHostingController(rootView: AView3())
// // 
// //     override func viewDidLoad() {
// //         super.viewDidLoad()
// // 
// //         view.addSubview(hostingController.view)
// //         view.addSubview(hostingController2.view)
// //         view.addSubview(hostingController3.view) 
// // 
// //         hostingController.view.accessibilityIdentifier = "🔴 Hosting Controller"
// //         hostingController2.view.accessibilityIdentifier = "🟡 Hosting Controller"
// //         hostingController3.view.accessibilityIdentifier = "🟢 Hosting Controller"
// //         
// //         hostingController.view.backgroundColor = .clear
// //         hostingController2.view.backgroundColor = .clear
// //         hostingController3.view.backgroundColor = .clear
// // 
// //         hostingController.view.translatesAutoresizingMaskIntoConstraints = false
// //         hostingController2.view.translatesAutoresizingMaskIntoConstraints = false
// //         hostingController3.view.translatesAutoresizingMaskIntoConstraints = false
// // 
// //         let constraints = [
// //             hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
// //             hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
// //             hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
// //             hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
// // 
// //             hostingController2.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
// //             hostingController2.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
// //             hostingController2.view.topAnchor.constraint(equalTo: view.topAnchor),
// //             hostingController2.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
// // 
// //             hostingController3.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
// //             hostingController3.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
// //             hostingController3.view.topAnchor.constraint(equalTo: view.topAnchor),
// //             hostingController3.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
// //         ]
// // 
// //         NSLayoutConstraint.activate(constraints)
// //     }
// // }
// 
// struct AView: View {
//     var body: some View {
//         Button {
//             print("🔴🔴🔴")
//         } label: {
//             Circle()
//                 .fill(Color.red)
//                 .frame(width: 100, height: 100)
//         }
//         .padding(.bottom, 240)
//         .accessibilityIdentifier("🔴 Button")
//     }
// }
// 
// struct AView2: View {
//     var body: some View {
//         Button {
//             print("🟡🟡🟡")
//         } label: {
//             Circle()
//                 .fill(Color.yellow)
//                 .frame(width: 100, height: 100)
//         }
//         .accessibilityIdentifier("🟡 Button")
//     }
// }
// 
// struct AView3: View {
//     var body: some View {
//         Button {
//             print("🟢🟢🟢")
//         } label: {
//             Circle()
//                 .fill(Color.green)
//                 .frame(width: 100, height: 100)
//         }
//         .padding(.top, 240)
//         .accessibilityIdentifier("🟢 Button")
//     }
// }
// 
// #Preview {
//     ViewController()
// }
// 
// 
// //
// //  ViewController.swift
// //  SwiftUITouchHandling
// //
// //  Created by Peter Steinberger on 26.10.20.
// //
// 
// import UIKit
// import SwiftUI
// 
// struct SwiftUIView: View {
//     var body: some View {
//         VStack {
//             Button("SwiftUI Button") {
//                 print("SwiftUI tapped")
//             }.border(Color.black)
//         }.frame(minWidth: 0,
//                 maxWidth: .infinity,
//                 minHeight: 0,
//                 maxHeight: .infinity,
//                 alignment: .center
//         ).background(Color.red)
//     }
// }
// 
// class MyView: UIView {
//     var hostingView: UIView?
//     
//     override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//         let something = super.hitTest(point, with: event)
//         
//         // SwiftUI returns unusual views during hitTesting - there must be a smarter way to find
//         // a match for the background, but demo purposes this is enough.
//         if something?.frame.width == hostingView?.frame.width {
//             return self.subviews.first
//         } else {
//             return something
//         }
//     }
// }
// 
// class ViewController: UIViewController {
//     
//     override func loadView() {
//         let myView = MyView()
//         view = myView
//     }
//     
//     override func viewDidLoad() {
//         super.viewDidLoad()
//         
//         self.view.backgroundColor = .white
//         let button = UIButton(type: .roundedRect, primaryAction: UIAction { _ in
//             print("UIKit tapped")
//         })
//         button.frame = CGRect(x: 100, y: 100, width: 500, height: 500)
//         button.setTitle("UIKit Button", for: .normal)
//         button.setTitleColor(.blue, for: .normal)
//         button.layer.borderWidth = 2
//         button.layer.borderColor = UIColor.blue.cgColor
//         view.addSubview(button)
//         
//         let swiftUI = UIHostingController(rootView: SwiftUIView())
//         swiftUI.view.frame = CGRect(x: 150, y: 150, width: 150, height: 150)
//         self.addChild(swiftUI)
//         view.addSubview(swiftUI.view)
//         
//         let castView = view as! MyView
//         
//         castView.hostingView = swiftUI.view
//     }
//     
//     
// }
