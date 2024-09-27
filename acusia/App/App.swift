import CoreData
import SwiftUI
import Transmission

let apiurl = "http://192.168.1.248:8000"

class WindowState: ObservableObject {
    static let shared = WindowState()

    @Published var showSearchSheet: Bool = false
    @Published var hideFloatingBar: Bool = false

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

        let view = FloatingBarView()
            .environmentObject(WindowState.shared)
            .environmentObject(Auth.shared)
            .environmentObject(MusicKit.shared)
            .environmentObject(HomeState.shared)

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear
        hostingController.safeAreaRegions = SafeAreaRegions()

        floatingBarWindow = PassThroughWindow(windowScene: scene)
        floatingBarWindow?.backgroundColor = .clear
        let screenBounds = UIScreen.main.bounds
        floatingBarWindow?.frame = CGRect(x: 0, y: screenBounds.height / 2, width: screenBounds.width, height: screenBounds.height / 2)
        floatingBarWindow?.rootViewController = hostingController

        floatingBarWindow?.windowLevel = UIWindow.Level.alert + 1
        floatingBarWindow?.isHidden = false
    }
}

struct AcusiaAppView: View {
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var musicKitManager: MusicKit
    @State private var homePath = NavigationPath()
    @State private var isPresented = false

    var body: some View {
        Group {
//            if auth.isAuthenticated && auth.user != nil {
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                Home(size: size, safeArea: safeArea, homePath: $homePath)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
//                }
            }
            .ignoresSafeArea()
//            else {
//                AuthScreen()
//            }
        }
        .onAppear {
            setupNavigationBar()

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

    // Remove the ugly default nav.
    private func setupNavigationBar() {
        var backButtonBackgroundImage = UIImage(systemName: "chevron.left.circle.fill")!
        backButtonBackgroundImage = backButtonBackgroundImage.applyingSymbolConfiguration(.init(paletteColors: [.white, .darkGray]))!
        UINavigationBar.appearance().backIndicatorImage = backButtonBackgroundImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonBackgroundImage
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = .clear
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000.0, vertical: 0.0), for: .default)
    }
}

struct FloatingBarView: View {
    @State private var searchText = "clairo"
    @State private var entryText = ""
    @State private var selectedResult: SearchResult?

    @State private var keyboardOffset: CGFloat = 34

    var body: some View {
        ZStack {
            SearchBar(searchText: $searchText, entryText: $entryText)
                .padding(.horizontal, 24)
                .offset(y: -keyboardOffset)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    keyboardOffset = getKeyboardHeight(from: notification)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    keyboardOffset = 34
                }
                .animation(.spring(), value: keyboardOffset)
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
