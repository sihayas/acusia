import CoreData
import SwiftUI

let apiurl = "http://192.168.1.234:8000"

@main
struct AcusiaApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var auth = Auth()

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(auth)
        }
    }
}

struct AcusiaAppView: View {
    @EnvironmentObject var auth: Auth
    @State private var homePath = NavigationPath()

    var body: some View {
        Group {
            if auth.isAuthenticated {
                if let user = auth.user {
                    GeometryReader {
                        let size = $0.size
                        let safeArea = $0.safeAreaInsets
                        Home(size: size, safeArea: safeArea, homePath: $homePath)
                            .ignoresSafeArea(.all)
                            .background(Color.black)
                    }

                } else {
                    ProgressView()
                }
            } else {
                AuthScreen()
            }
        }
        .onAppear {
            Task {
                await auth.initSession()
            }
            setupNavigationBar()
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
