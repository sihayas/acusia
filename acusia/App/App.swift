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
            let isSplit = windowState.isSplit

            let baseReplyHeight: CGFloat = size.height * 0.7
            let maxReplyHeight: CGFloat = size.height * 0.9
            let baseHomeHeight: CGFloat = size.height * 0.3
            let minHomeHeight: CGFloat = size.height * 0.1

            // Progress based on dragOffset to control opacity changes
            let heightProgress = min(max(dragOffset / (maxReplyHeight - baseReplyHeight), 0), 1)
            let replyOpacity = 1.0 - heightProgress
            let homeOverlayOpacity = heightProgress * 0.1

            // Heights for reply and home views
            let replySplitHeight: CGFloat = isSplit ? baseReplyHeight + dragOffset : 0
            let homeSplitHeight: CGFloat = isSplit ? baseHomeHeight - dragOffset : .infinity

            ZStack {
                ReplySheet()
                    .frame(maxWidth: .infinity, maxHeight: replySplitHeight)
                    .background(Color(UIColor.systemGray6).opacity(replyOpacity))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.blue, lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .animation(.spring(), value: replySplitHeight)

                Home(size: size, safeArea: proxy.safeAreaInsets, homePath: $homePath)
                    .frame(maxWidth: .infinity, maxHeight: homeSplitHeight)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.red, lineWidth: 1)
                            .fill(.white.opacity(homeOverlayOpacity)) // Adjust overlay opacity based on dragOffset
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .animation(.spring(), value: homeSplitHeight)
            }
            // Add the drag gesture here
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        guard isSplit else { return }

                        let dragY = value.translation.height

                        // Adjust dragOffset for both expanding (up) and collapsing (down)
                        if (dragY > 0 && windowState.isOffsetAtTop) || !windowState.isSplitFull {
                            dragOffset = -dragY
                        }
                    }
                    .onEnded { value in
                        guard isSplit else { return }

                        let velocityY = value.velocity.height
                        let velocityThreshold: CGFloat = 1000
                        let halfwayPoint = (maxReplyHeight - baseReplyHeight) / 2

                        if velocityY < -velocityThreshold || dragOffset >= halfwayPoint {
                            // Expand fully
                            dragOffset = maxReplyHeight - baseReplyHeight
                            windowState.isSplitFull = true
                        } else if value.translation.height > 0 {
                            guard windowState.isOffsetAtTop else { return }

                            // Collapse fully if dragging down past threshold
                            let collapseHalfwayPoint = (baseReplyHeight - minHomeHeight) / 2
                            if velocityY > velocityThreshold || dragOffset <= collapseHalfwayPoint {
                                windowState.isSplit.toggle()
                                dragOffset = 0
                                windowState.isSplitFull = false
                            } else {
                                // Rubberband back to full expanded height
                                dragOffset = maxReplyHeight - baseReplyHeight
                                windowState.isSplitFull = true
                            }
                        } else {
                            // Rubberband back to base height if no threshold met
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
