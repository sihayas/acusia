import CoreData
import SwiftUI
import Transmission

#Preview {
    let auth = Auth.shared
    let uiState = UIState.shared
    // let musicKit = MusicKit.shared
    
    auth.isAuthenticated = true
    let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDA0NTEuYTVmN2Y5OGQxMzRlNGY1ZTg1NWY2YmNkYzUyMmViMDMuMDkwMSIsImV4cCI6MTczMzQyMTc4OX0.VTf2UT9IzFL3-mZtGJGjsn4L1v1rcuGf2JmGS3Jql58"
    
    return MainView()
        .environmentObject(auth)
        .environmentObject(uiState)
        // .environmentObject(musicKit)
}

@main
struct AcusiaApp: App {
    @StateObject private var auth = Auth.shared
    @ObservedObject private var uiState = UIState.shared
    // @ObservedObject private var musicKit = MusicKit.shared

    let persistenceController = PersistenceController.shared
    private var safeAreaInsets: UIEdgeInsets = .init()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(auth)
                .environmentObject(uiState)
                // .environmentObject(musicKit)
            // .onAppear { auth.authenticate() }
        }
    }
}

struct MainView: View {
    @Environment(\.viewSize) private var viewSize
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var uiState: UIState
    // @EnvironmentObject private var musicKitManager: MusicKit

    @State private var dragOffset: CGFloat = 0
    var cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        if !auth.isAuthenticated {
            AuthScreen()
        } else {
            GeometryReader { proxy in
                Home()
                    .onAppear {
                        uiState.size = proxy.size
                        uiState.enableDarkMode()
                        uiState.setupNavigationBar()
                        // uiState.setupSymmetryWindow()

                        Task {
                            // await musicKitManager.requestMusicAuthorization()
                           
                            // if musicKitManager.isAuthorizedForMusicKit {
                            //     await musicKitManager.loadRecentlyPlayedSongs()
                            // }
                        }
                    }
                    .environment(\.viewSize, proxy.size)
            }
            .ignoresSafeArea()
            // .overlay(alignment: .top) {
            //     if auth.isAuthenticated {
            //         Button {
            //             auth.signOut()
            //         } label: {
            //             Label("Sign Out", systemImage: "person.crop.circle.badge.xmark")
            //                 .font(.headline)
            //                 .padding()
            //         }
            //     }
            // }
            .sheet(isPresented: Binding(
                get: { uiState.symmetryState == .user },
                set: { newValue in
                    if !newValue, uiState.symmetryState == .user {
                        uiState.symmetryState = .feed
                    }
                }
            )) {
                UserSheet()
            }
            .sheet(isPresented: Binding(
                get: { uiState.symmetryState == .create },
                set: { newValue in
                    if !newValue, uiState.symmetryState == .create {
                        uiState.symmetryState = .feed
                    }
                }
            )) {
                CreateSheet()
                    .presentationBackground(.ultraThickMaterial)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(40)
            }
            .sheet(isPresented: Binding(
                get: { uiState.symmetryState == .search },
                set: { newValue in
                    if !newValue, uiState.symmetryState == .search {
                        uiState.symmetryState = .feed
                    }
                }
            )) {
                IndexSheet()
                    .presentationBackground(.thinMaterial)
                    .presentationDetents([.fraction(0.99)])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(40)
            }
        }
    }
}
