import CoreData
import SwiftUI
import Transmission

let apiurl = "http://192.168.1.248:8000"

// Shared state between the two windows
class WindowState: ObservableObject {
    static let shared = WindowState()

    @Published var size: CGSize = .zero
    @Published var collapsedHomeHeight: CGFloat = 0
    @Published var showSearchSheet: Bool = false

    // Reply
    @Published var isSplit: Bool = false // Split the screen
    @Published var isOffsetAtTop: Bool = true // Prevent gesture with the split
    @Published var isLayered: Bool = false // Layered replies

    private init() {}
}

@main
struct AcusiaApp: App {
    @ObservedObject private var windowState = WindowState.shared
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
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var musicKitManager: MusicKit

    @State private var dragOffset: CGFloat = 0

    private var cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        ScrollView(.init()) {
            // TabView {
                // Main Feed + User + User History View
                GeometryReader { proxy in
                    // Horizontal Slide Helpers
                    let screen = proxy.frame(in: .global)
                    let offset = screen.minX
                    let scale = 1 + (offset / screen.width)

                    let progress = min(1, max(0, -offset / screen.width))
                    let dynamicCornerRadius = max(12, cornerRadius - (cornerRadius - 12) * progress)

                    // Split Layout Helpers
                    let screenHeight = proxy.size.height
                    let screenWidth = proxy.size.width

                    let collapsedHomeHeight: CGFloat = safeAreaInsets.top * 2
                    let collapsedReplyHeight: CGFloat = screenHeight

                    let homeHeight: CGFloat = windowState.isSplit ?
                        collapsedHomeHeight + dragOffset
                        : screenHeight

                    let replyHeight: CGFloat = windowState.isSplit ?
                        collapsedReplyHeight - dragOffset
                        : 0

                    ZStack(alignment: .top) {
                        Home()
                            .overlay {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .background(.thinMaterial)
                                    .opacity(windowState.isSplit ? 1.0 : 0)
                                    .animation(.snappy, value: windowState.isSplit)
                                    .allowsHitTesting(false)
                            }
                            .frame(minWidth: screenWidth, minHeight: screenHeight)
                            .frame(height: homeHeight, alignment: .top)
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(radius: 10)
                            .animation(.snappy(), value: homeHeight)
                            .zIndex(1)

                        // Replies view
                        VStack {
                            if windowState.isSplit {
                                VStack(alignment: .leading) { // Align to top. This contains the clipped view.
                                    RepliesSheet()
                                        .frame(minWidth: screenWidth, minHeight: screenHeight)
                                        .frame(height: replyHeight, alignment: .top) // Align content inside to top.
                                        .overlay(
                                            Color.white.opacity(windowState.isSplit ? 0 : 0.05)
                                                .blendMode(.exclusion)
                                                // .animation(.spring(), value: replyOpacity)
                                                .allowsHitTesting(false)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                        .animation(.spring(), value: replyHeight)
                                }
                                .frame(minWidth: screenWidth, minHeight: screenHeight, alignment: .bottom)
                            }
                        }
                        .transition(.blurReplace)
                        .zIndex(0)
                    }
                    // Notification Slide Over
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
                                guard windowState.isSplit, !windowState.isLayered, windowState.isOffsetAtTop else { return }
                                let yOffset = value.translation.height

                                /// Dragging up, means scrolling down, negative offset.
                                /// Dragging down, means scrolling up, positive offset.
                                if yOffset > 0 {
                                    dragOffset = yOffset
                                }
                            }
                            .onEnded { value in
                                guard windowState.isSplit, !windowState.isLayered, windowState.isOffsetAtTop else { return }

                                let yOffset = value.translation.height
                                let yVelocity = value.velocity.height

                                if yOffset > 0, yVelocity > 1000 || yOffset >= (screenHeight / 2) { // User is dragging downwards
                                    withAnimation(.snappy) {
                                        windowState.isSplit = false
                                        dragOffset = 0
                                    }
                                } else {
                                    dragOffset = 0
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
                    .onAppear {
                        windowState.size = proxy.size
                        windowState.collapsedHomeHeight = collapsedHomeHeight
                    }
                }

                // Notifications
            //     VStack {}
            //         .frame(maxWidth: .infinity, maxHeight: .infinity)
            //         .background(.black)
            // }
            // .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
