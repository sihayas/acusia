import SwiftUI
import CoreData

let apiurl = "http://192.168.1.17:8000"

@main
struct AcusiaApp: App {
    let persistenceController = PersistenceController.shared
//    @StateObject private var auth = Auth()
    
    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .environmentObject(auth)
        }
    }
}

struct AcusiaAppView: View {
//    @EnvironmentObject var auth: Auth
    
    var body: some View {
//        Group {
//            if auth.isAuthenticated {
//                if let user = auth.user {
//                    ContentView(user: user)
//                } else {
//                    ProgressView()
//                }
//            } else {
//                AuthScreen()
//            }
//        }
//        .onAppear {
//            Task {
//                await auth.initSession()
//            }
//        }
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            Home(size: size, safeArea: safeArea)
                .ignoresSafeArea(.all, edges: .top)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var auth: Auth
    let user: APIUser
    @State private var selectedTab = 0
    @State private var feedPath = NavigationPath()
    @State private var userPath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $feedPath) {
                FeedScreen(userId: user.id)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationBarHidden(true)
                    .navigationDestination(for: SearchResultItem.self) { item in
                        switch item {
                        case .sound(_):
                            EmptyView()
                        case .user(let user):
                            UserScreen(initialUserData: nil, userResult: user)
                        }
                    }
                    .tag(0)
            }
            
            NavigationStack(path: $userPath) {
                UserScreen(initialUserData: user, userResult: nil)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationBarHidden(true)
                    .tag(1)
            }
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}
extension Notification.Name {
    static let authenticationSucceeded = Notification.Name("AuthenticationSucceeded")
}
