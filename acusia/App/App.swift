import CoreData
import SwiftUI

let apiurl = "http://192.168.1.21:8000"

@main
struct AcusiaApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var auth = Auth.shared // Singleton

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(auth)
        }
    }
}

struct AcusiaAppView: View {
    @StateObject private var auth = Auth.shared
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
                }
            } else {
                AuthScreen()
            }
        }
        .onAppear {
            setupNavigationBar()
            Task { await auth.initSession() }
        }
    }
    
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
