import CoreData
import SwiftUI
import Modals
import Transmission

let apiurl = "http://192.168.1.248:8000"

@main
struct AcusiaApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var auth = Auth.shared
    @StateObject private var musicKitManager = MusicKitManager.shared
    @StateObject private var shareData = ShareData()

    var body: some Scene {
        WindowGroup {
            ModalStackView {
                AcusiaAppView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(auth)
                    .environmentObject(musicKitManager)
                    .environmentObject(shareData)
            }
        }
    }
}

struct AcusiaAppView: View {
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var musicKitManager: MusicKitManager
    @State private var homePath = NavigationPath()
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button {
                withAnimation {
                    isPresented = true
                }
            } label: {
                HStack {
                    Image("noise2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240)
                        .presentation(
                            transition: .custom,
                            isPresented: $isPresented
                        ) {
                            Image("noise2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 240, height: 240)
                        }
                }
            }
            
            Spacer()
        }
//        Group {
////            if auth.isAuthenticated && auth.user != nil {
//                GeometryReader {
//                    let size = $0.size
//                    let safeArea = $0.safeAreaInsets
//                    Home(size: size, safeArea: safeArea, homePath: $homePath)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .ignoresSafeArea(.all)
//                        .background(Color.black)
////                }
//            } 
////            else {
////                AuthScreen()
////            }
//        }
//        .onAppear {
//            setupNavigationBar()
//
//            Task {
////                await auth.initSession()
//                await musicKitManager.requestMusicAuthorization()
//
//                // Load recently played songs if authorized
//                if musicKitManager.isAuthorizedForMusicKit {
//                    print("Loading recently played songs")
//                    await musicKitManager.loadRecentlyPlayedSongs()
//                }
//            }
//        }
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
