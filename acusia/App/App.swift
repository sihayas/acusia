import CoreData
import SwiftUI
import Transmission

let apiurl = "http://192.168.1.248:8000"

class SharedState: ObservableObject {
    static let shared = SharedState() // Singleton instance

    // Your shared properties go here
    @Published var someValue: String = ""

    private init() {} // Prevents external initialization
}

@main
struct AcusiaApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var auth = Auth.shared
    @StateObject private var musicKitManager = MusicKitManager.shared
    @StateObject private var shareData = ShareData()
    private var floatingBarPresenter = FloatingBarPresenter()

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(auth)
                .environmentObject(musicKitManager)
                .environmentObject(shareData)
                .environmentObject(SharedState.shared) // Use singleton instance here
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

        let view = FloatingBarView().environmentObject(SharedState.shared) // Use singleton instance
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear
        hostingController.safeAreaRegions = SafeAreaRegions() // Important

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
    @EnvironmentObject private var musicKitManager: MusicKitManager
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
                    .ignoresSafeArea()
                    .background(Color.black)
//                }
            }
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
            SearchBar(searchText: $searchText, entryText: $entryText, selectedResult: $selectedResult)
                .padding(.horizontal, 24)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
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
        .border(Color.green)
    }

    private func getKeyboardHeight(from notification: Notification) -> CGFloat {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 34
        }
        return keyboardFrame.height + 8
    }
}
