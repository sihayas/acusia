import CoreData
import SwiftUI
import Transmission

let apiurl = "http://192.168.1.248:8000"

// Shared state between the two windows
class WindowState: ObservableObject {
    static let shared = WindowState()

    @Published var showSearchSheet: Bool = false

    // Reply
    @Published var isSplit: Bool = false // Split the screen
    @Published var isSplitFull: Bool = false // Prevent gesture with the scrollview
    @Published var isOffsetAtTop: Bool = true // Prevent gesture with the split
    @Published var isLayered: Bool = false // Layered replies

    private init() {}
}

@main
struct AcusiaApp: App {
    @ObservedObject private var windowState = WindowState.shared
    @ObservedObject private var auth = Auth.shared
    @ObservedObject private var musicKit = MusicKit.shared
    @ObservedObject private var homeState = HomeState.shared

    let persistenceController = PersistenceController.shared
    private var floatingBarPresenter = FloatingBarPresenter()
    private var safeAreaInsets: UIEdgeInsets = .init()

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(windowState)
                .environmentObject(auth)
                .environmentObject(musicKit)
                .environmentObject(homeState)
                .onAppear {
                    floatingBarPresenter.showFloatingBar()
                }
        }
    }
}

/// The general idea for the split layout is there is a ZStack container that holds
/// the RepliesView below the HomeView. When the user triggers a split,
/// the HomeView mask frame shrinks to the baseHomeHeight
/// and the RepliesView mask frame expands to the baseReplyHeight.
/// As the user drags up the RepliesView mask expands to full, and the
/// HomeView mask shrinks to the minHomeHeight.
struct AcusiaAppView: View {
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var musicKitManager: MusicKit
    @EnvironmentObject private var homeState: WindowState
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var homePath = NavigationPath()
    @State private var dragOffset: CGFloat = 0

    let cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        ScrollView(.init()) {
            TabView {
                GeometryReader { proxy in
                    // Horizontal Slide Helpers
                    let screen = proxy.frame(in: .global)
                    let offset = screen.minX
                    let scale = 1 + (offset / screen.width)
                    
                    let progress = min(1, max(0, -offset / screen.width))
                    let dynamicCornerRadius = max(12, cornerRadius - (cornerRadius - 12) * progress)
                    
                    // Split Layout Helpers
                    let size = proxy.size
                    let height = size.height

                    let collapsedReplyHeight: CGFloat = size.height * 0.7
                    let collapsedHomeHeight: CGFloat = size.height * 0.4

                    let expandedReplyHeight: CGFloat = size.height * 0.8
                    let expandedHomeHeight: CGFloat = size.height * 0.2

                    let homeHeight: CGFloat = homeState.isSplitFull ?
                        expandedHomeHeight + dragOffset
                        : homeState.isSplit ?
                        collapsedHomeHeight + dragOffset
                        : size.height

                    let replyHeight: CGFloat = homeState.isSplitFull ?
                        expandedReplyHeight - dragOffset
                        : homeState.isSplit ?
                        collapsedReplyHeight - dragOffset
                        : 0

                    ZStack(alignment: .top) {
                        // Replies view
                        VStack {
                            if homeState.isSplit {
                                VStack(alignment: .leading) { // Align to top. This contains the clipped view.
                                    RepliesSheet(size: size, minHomeHeight: expandedHomeHeight)
                                        .frame(minWidth: size.width, minHeight: size.height)
                                        .frame(height: replyHeight, alignment: .top) // Align content inside to top.
                                        .overlay(
                                            Color.white.opacity(homeState.isSplitFull ? 0 : 0.05)
                                                .blendMode(.exclusion)
                                                // .animation(.spring(), value: replyOpacity)
                                                .allowsHitTesting(false)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                        .animation(.spring(), value: replyHeight)
                                }
                                .frame(minWidth: size.width, minHeight: size.height, alignment: .bottom)
                            }
                        }
                        .transition(.blurReplace)

                        Home(size: size, safeArea: proxy.safeAreaInsets, homePath: $homePath)
                            // .overlay {
                            //     Rectangle()
                            //         .foregroundStyle(.clear)
                            //         .background(.thinMaterial)
                            //         // .opacity(Double(homeState.isSplit ? homeOverlayOpacity : 0))
                            //         // .animation(.spring(), value: homeOverlayOpacity)
                            //         .allowsHitTesting(false)
                            // }
                            .frame(minWidth: size.width, minHeight: size.height)
                            .frame(height: homeHeight, alignment: .top) // Align content inside to top.
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .shadow(radius: 10)
                            .animation(.spring(), value: homeHeight)
                    }
                    // Sliding View
                    .overlay(
                        Color.white
                            .opacity(min(0.3, max(0, -offset / screen.width * 0.3)))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: dynamicCornerRadius, style: .continuous))
                    .scaleEffect(scale >= 0.92 ? scale : 0.92, anchor: .center)
                    .offset(x: -offset)
                    
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                /// Only allow gesture input to modify split progress if not fully split or if fully split and root scroll offset is at the top.
                                guard homeState.isSplit, !homeState.isLayered, homeState.isOffsetAtTop else { return }

                                /// Dragging up, means scrolling down, negative offset.
                                /// Dragging down, means scrolling up, positive offset.
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                guard homeState.isSplit else { return }

                                let yOffset = value.translation.height
                                let yVelocity = value.velocity.height

                                if yVelocity < -1000 || yOffset <= -50 { // User is dragging upwards
                                    dragOffset = 0
                                    homeState.isSplitFull = true
                                } else if yOffset > 0 { // User is dragging downwards
                                    guard homeState.isOffsetAtTop else { return }

                                    if yVelocity > 1000 || yOffset >= (height / 2) {
                                        withAnimation {
                                            homeState.isSplit = false
                                            homeState.isSplitFull = false
                                            dragOffset = 0
                                        }
                                    } else {
                                        // Reset to base height without fully collapsing
                                        dragOffset = 0
                                        homeState.isSplitFull = false
                                    }
                                } else {
                                    // Reset to base height if no significant drag occurred
                                    dragOffset = 0
                                    homeState.isSplitFull = false
                                }
                            }
                    )
                    .onAppear {
                        UINavigationBar.setupCustomAppearance()

                        Task {
                            await musicKitManager.requestMusicAuthorization()

                            if musicKitManager.isAuthorizedForMusicKit {
                                await musicKitManager.loadRecentlyPlayedSongs()
                            }
                        }
                    }
                }
                
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
    }
}

class FloatingBarPresenter {
    private var floatingBarWindow: UIWindow?

    func showFloatingBar() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        // Get safe area insets from the scene's window
        let safeAreaInsets = scene.windows.first?.safeAreaInsets ?? UIEdgeInsets.zero

        // Pass the insets to the SwiftUI view
        let view = FloatingBarView(safeAreaInsets: safeAreaInsets)
            .environmentObject(WindowState.shared)
            .environmentObject(Auth.shared)
            .environmentObject(MusicKit.shared)
            .environmentObject(HomeState.shared)

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear

        // Remove safe area from the hosting controller
        hostingController.safeAreaRegions = SafeAreaRegions()

        floatingBarWindow = PassThroughWindow(windowScene: scene)
        floatingBarWindow?.backgroundColor = .clear

        let screenBounds = UIScreen.main.bounds
        floatingBarWindow?.frame = CGRect(x: 0, y: screenBounds.height / 2,
                                          width: screenBounds.width, height: screenBounds.height / 2)
        floatingBarWindow?.rootViewController = hostingController

        floatingBarWindow?.windowLevel = UIWindow.Level.alert + 1
        floatingBarWindow?.isHidden = false
    }
}

/// NOTE: Putting a border on the outer stack prevents touch inputs from being passed through.
struct FloatingBarView: View {
    let safeAreaInsets: UIEdgeInsets

    @State private var searchText = "clairo"
    @State private var entryText = ""
    @State private var selectedResult: SearchResult?
    @State private var keyboardOffset: CGFloat = 34

    var body: some View {
        ZStack {
            SymmetryView()
                .padding(.bottom, safeAreaInsets.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private func getKeyboardHeight(from notification: Notification) -> CGFloat {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 34
        }
        return keyboardFrame.height + 8
    }
}
