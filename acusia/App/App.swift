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
    @EnvironmentObject private var windowState: WindowState
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var homePath = NavigationPath()
    @State private var dragOffset: CGFloat = 0

    let cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let height = size.height

            let collapsedReplyHeight: CGFloat = size.height * 0.7
            let collapsedHomeHeight: CGFloat = size.height * 0.4

            let expandedReplyHeight: CGFloat = size.height * 0.8
            let expandedHomeHeight: CGFloat = size.height * 0.2

            let replySplitHeight: CGFloat = windowState.isSplit
                ? collapsedReplyHeight + dragOffset
                : 0

            let homeSplitHeight: CGFloat = windowState.isSplit
                ? (windowState.isSplitFull // Check if fully expanded
                    ? expandedHomeHeight // If yes, use expandedHomeHeight
                    : max(collapsedHomeHeight - dragOffset, expandedHomeHeight)) // Otherwise, use the previous calculation
                : size.height

            let heightProgress = min(max(dragOffset / (height - collapsedReplyHeight), 0), 1)
            let replyOpacity = 0.05 - heightProgress * 0.05
            let homeOverlayOpacity = heightProgress * 1.0

            ZStack(alignment: .top) {
                VStack(alignment: .leading) { // Align to top. This contains the clipped view. It has a bg.
                    RepliesSheet(size: size, minHomeHeight: expandedHomeHeight)
                        .frame(minWidth: size.width, minHeight: size.height)
                        .frame(height: replySplitHeight, alignment: .top) // Align content inside to top.
                        .overlay(
                            Color.white.opacity(windowState.isSplitFull ? 0 : 0.05)
                                .blendMode(.exclusion)
                                .animation(.spring(), value: replyOpacity)
                                .allowsHitTesting(false)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .animation(.spring(), value: replySplitHeight)
                }
                .frame(minWidth: size.width, minHeight: size.height, alignment: .bottom)

                Home(size: size, safeArea: proxy.safeAreaInsets, homePath: $homePath)
                    .overlay {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .background(
                                    .thinMaterial
                                )
                                .opacity(Double(windowState.isSplit ? homeOverlayOpacity : 0))
                                .animation(.spring(), value: homeOverlayOpacity)
                                .allowsHitTesting(false)

                            VStack {
                                Spacer()
                                
                                Button {
                                    windowState.isSplit.toggle()
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    .frame(minWidth: size.width, minHeight: size.height)
                    .frame(height: homeSplitHeight, alignment: .top) // Align content inside to top.
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(radius: 10)
                    .animation(.spring(), value: homeSplitHeight)
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        // Only proceed if the window is split and not layered
                        guard windowState.isSplit && !windowState.isLayered else { return }

                        let verticalDrag = value.translation.height

                        // Determine if the user is dragging down at the top or if the window is not fully.
                        let isDraggingDownAtTop = verticalDrag > 0 && windowState.isOffsetAtTop

                        // Adjust dragOffset for expanding upwards or collapsing downwards
                        if isDraggingDownAtTop || !windowState.isSplitFull {
                            dragOffset = -verticalDrag
                        }
                    }
                    .onEnded { value in
                        // Only proceed if the window is split
                        guard windowState.isSplit else { return }

                        let verticalDrag = value.translation.height
                        let verticalVelocity = value.velocity.height

                        let velocityThreshold: CGFloat = 1000
                        let expandHalfwayPoint: CGFloat = 25

                        let isQuickUpwardSwipe = verticalVelocity < -velocityThreshold
                        let hasDraggedPastHalfwayUp = dragOffset >= expandHalfwayPoint

                        if isQuickUpwardSwipe || hasDraggedPastHalfwayUp {
                            // Set splitHeights to their expanded state
                            dragOffset = expandedReplyHeight - collapsedReplyHeight
                            windowState.isSplitFull = true
                        } else if verticalDrag > 0 {
                            // User is dragging downwards
                            guard windowState.isOffsetAtTop else { return }

                            let collapseHalfwayPoint = collapsedReplyHeight / 2
                            let totalDragDown = -dragOffset

                            let isQuickDownwardSwipe = verticalVelocity > velocityThreshold
                            let hasDraggedPastHalfwayDown = totalDragDown >= collapseHalfwayPoint

                            if isQuickDownwardSwipe || hasDraggedPastHalfwayDown {
                                // Collapse the window fully
                                windowState.isSplit = false
                                windowState.isSplitFull = false
                                dragOffset = 0
                            } else {
                                // Reset to base height without fully collapsing
                                dragOffset = 0
                                windowState.isSplitFull = false
                            }
                        } else {
                            // Reset to base height if no significant drag occurred
                            dragOffset = 0
                            windowState.isSplitFull = false
                        }
                    }
            )
            .onAppear {
                UINavigationBar.setupCustomAppearance()

                Task {
                    await musicKitManager.requestMusicAuthorization()

                    // Load recently played songs if authorized
                    if musicKitManager.isAuthorizedForMusicKit {
                        await musicKitManager.loadRecentlyPlayedSongs()
                    }
                }
            }
        }
        .ignoresSafeArea()
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
            ApertureView()
                .padding(.bottom, safeAreaInsets.bottom) // Use safe area insets
                .opacity(0)
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
