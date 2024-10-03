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

struct AcusiaAppView: View {
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var musicKitManager: MusicKit
    @EnvironmentObject private var windowState: WindowState

    @State private var homePath = NavigationPath()
    @State private var dragOffset: CGFloat = 0

    let cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            let baseReplyHeight: CGFloat = size.height * 0.7
            let baseHomeHeight: CGFloat = size.height * 0.4
            
            let maxReplyHeight: CGFloat = size.height * 1.0
            let minHomeHeight: CGFloat = size.height * 0.18

            let heightProgress = min(max(dragOffset / (maxReplyHeight - baseReplyHeight), 0), 1)
            let replyOpacity = 1.0 - heightProgress
            let homeOverlayOpacity = heightProgress * 0.1

            let replySplitHeight: CGFloat = windowState.isSplit ? baseReplyHeight + dragOffset : 0
            let homeSplitHeight = max(windowState.isSplit ? baseHomeHeight - dragOffset : size.height, minHomeHeight)

            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) { // Align to top.
                    RepliesSheet(size: CGSize(width: size.width, height: maxReplyHeight))
                        .frame(minWidth: size.width, minHeight: size.height)
                        .frame(height: replySplitHeight, alignment: .top) // Align content inside to top.
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                        .background(Color(UIColor.systemGray6).opacity(replyOpacity))
                        .animation(.spring(), value: replySplitHeight)
                }
                .frame(minWidth: size.width, minHeight: size.height, alignment: .top)

                Home(size: size, safeArea: proxy.safeAreaInsets, homePath: $homePath)
                    .overlay(
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
                    )
                    .frame(minWidth: size.width, minHeight: size.height)
                    .frame(height: homeSplitHeight, alignment: .top) // Align content inside to top.
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(radius: 10)
                    .animation(.spring(), value: homeSplitHeight)
            }
            
            // Add the drag gesture here
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        // Only proceed if the window is split and not layered
                        guard windowState.isSplit && !windowState.isLayered else { return }

                        let verticalDrag = value.translation.height

                        // Determine if the user is dragging down at the top or if the window is not fully expanded
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
                            // Expand the split fully
                            dragOffset = maxReplyHeight - baseReplyHeight
                            windowState.isSplitFull = true
                        } else if verticalDrag > 0 {
                            // User is dragging downwards
                            guard windowState.isOffsetAtTop else { return }

                            let collapseHalfwayPoint = baseReplyHeight / 2
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
                print("safeAreaInsets: \(proxy.safeAreaInsets)")
            }
        }
        .ignoresSafeArea()
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
