import CoreData
import SwiftUI

let apiurl = "http://192.168.1.35:8000"

@main
struct AcusiaApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var auth = Auth.shared
    @StateObject private var musicKitManager = MusicKitManager.shared
    @StateObject private var shareData = ShareData()
    @StateObject private var safeAreaInsetsManager = SafeAreaInsetsManager()

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(auth)
                .environmentObject(musicKitManager)
                .environmentObject(shareData)
                .environmentObject(safeAreaInsetsManager)
        }
    }
}

struct AcusiaAppView: View {
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var musicKitManager: MusicKitManager
    @EnvironmentObject private var safeAreaInsetsManager: SafeAreaInsetsManager
    @State private var homePath = NavigationPath()

    var body: some View {
        Group {
            if auth.isAuthenticated && auth.user != nil {
                GeometryReader {
                    let size = $0.size
                    let safeArea = $0.safeAreaInsets
                    Home(size: size, safeArea: safeArea, homePath: $homePath)
                        .ignoresSafeArea(.all)
                        .background(Color.black)
                        .onAppear {
                            safeAreaInsetsManager.insets = safeArea
                        }
                }
            } else {
                AuthScreen()
            }
        }
        .onAppear {
            setupNavigationBar()

            Task {
                await auth.initSession()
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

extension Notification.Name {
    static let authenticationSucceeded = Notification.Name("AuthenticationSucceeded")
}

class SafeAreaInsetsManager: ObservableObject {
    @Published var insets: EdgeInsets = .init()
}
