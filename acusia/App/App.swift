import CoreData
import SwiftUI
import Transmission

let apiurl = "http://192.168.1.248:8000"

// Shared state between the two windows
class WindowState: ObservableObject {
    static let shared = WindowState()

    @Published var showSearchSheet: Bool = false

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
    @State private var isCollapsed = false
    
    let cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        VStack {
            GeometryReader {
//            if auth.isAuthenticated && auth.user != nil {
                Home(size: $0.size, safeArea: $0.safeAreaInsets, homePath: $homePath)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay() {
                        UnevenRoundedRectangle(topLeadingRadius: cornerRadius, bottomLeadingRadius: cornerRadius, bottomTrailingRadius: cornerRadius, topTrailingRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.white.opacity(1.0), lineWidth: 1, antialiased: true)
                            .fill(.white.opacity(isCollapsed ? 0.1 : 0.0))
                    }
                    .frame(maxWidth: .infinity, maxHeight: isCollapsed ? $0.size.height * 0.5 : .infinity)
                    .animation(.spring(), value: isCollapsed)
                
            }
            .ignoresSafeArea()
//            else {
//                AuthScreen()
//            }
            
            Button {
                isCollapsed.toggle()
            } label: {
                Text("Toggle")
            }
        }
        .onAppear {
            UINavigationBar.setupCustomAppearance()

            Task {
//                await auth.initSession()
                await musicKitManager.requestMusicAuthorization()

                // Load recently played songs if authorized
                if musicKitManager.isAuthorizedForMusicKit {
                    print("Loading recently played songs")
                    await musicKitManager.loadRecentlyPlayedSongs()
                }
            }
        }
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
