import SwiftUI
import CoreData
import UserNotifications

let apiurl = "http://192.168.1.234:8000"

// Thank you Claude.
class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        
        // If the hit view is not the root view controller's view, return it
        guard hitView == rootViewController?.view else { return hitView }
        
        // Check if there are any visible, interactive subviews at the touch point
        let interactiveSubview = hitView.subviews.first { subview in
            !subview.isHidden &&
            subview.alpha > 0.01 &&
            subview.isUserInteractionEnabled &&
            subview.frame.contains(point)
        }
        
        // If there's an interactive subview, return the hit view (allow interaction)
        // Otherwise, return nil (pass through)
        return interactiveSubview != nil ? hitView : nil
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task {
            await (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.auth.handleDeviceToken(deviceToken)
        }
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    var keyWindow: UIWindow?
    var navWindow: UIWindow?
    
    @Published var auth: Auth!
    @Published var navManager = NavManager.shared
    let persistenceController = PersistenceController.shared
    @Published var feedPath = NavigationPath()
    @Published var userPath = NavigationPath()
    @Published var selectedTab = 0
    
    // Set up the stacked windows and initialize the auth session
    func scene(
      _ scene: UIScene,
      willConnectTo session: UISceneSession,
      options connectionOptions: UIScene.ConnectionOptions
    ) {
        auth = Auth()
        
        if let windowScene = scene as? UIWindowScene {
            setupKeyWindow(in: windowScene)
            setupSecondaryWindow(in: windowScene)
        }
        
        Task {
            await auth.initSession()
        }
        
    }
    
    func setupKeyWindow(in scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        
        let contentView = AcusiaAppView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(auth)
            .environmentObject(navManager)
            .environmentObject(self)
        
        
        window.rootViewController = UIHostingController(rootView: contentView)
        self.keyWindow = window
        window.makeKeyAndVisible()
    }
    
    func setupSecondaryWindow(in scene: UIWindowScene) {
        let navViewController = UIHostingController(rootView: NavViewContainer()
            .environmentObject(auth)  // Inject Auth here
            .environmentObject(navManager)
            .environmentObject(self)
        )
        navViewController.view.backgroundColor = .clear
        
        let navWindow = PassThroughWindow(windowScene: scene)
        navWindow.rootViewController = navViewController
        navWindow.isHidden = false
        self.navWindow = navWindow
    }
}


@main
struct AcusiaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView() // The actual content is managed by SceneDelegate
        }
    }
}

// Main App View
struct AcusiaAppView: View {
    @EnvironmentObject var auth: Auth
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
        Group {
            if auth.isAuthenticated {
                if let user = auth.user {
                    ContentView(user: user)
                } else {
                    ProgressView()
                }
            } else {
                AuthScreen()
            }
        }
    }
}

struct NavViewContainer: View {
    @EnvironmentObject var auth: Auth
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some View {
        if let user = auth.user {
            NavView(user: user, path: $sceneDelegate.feedPath, selectedTab: $sceneDelegate.selectedTab)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var sessionManager: Auth
    @EnvironmentObject var sceneDelegate: SceneDelegate
    let user: APIUser
    @StateObject private var navManager = NavManager.shared
    
    var body: some View {
        TabView(selection: $sceneDelegate.selectedTab) {
            NavigationStack(path: $sceneDelegate.feedPath) {
                FeedScreen(userId: user.id)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationBarHidden(true)
                    .navigationDestination(for: SearchResultItem.self) { item in
                        switch item {
                        case .sound(let sound):
                            SoundScreen()
                        case .user(let user):
                            UserScreen(initialUserData: nil, userResult: user)
                        }
                    }
                    .tag(0)
            }
            
            NavigationStack(path: $sceneDelegate.userPath) {
                UserScreen(initialUserData: user, userResult: nil)
                    .toolbar(.hidden, for: .tabBar)
                    .navigationBarHidden(true)
                    .tag(2)
            }
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}

extension Notification.Name {
    static let authenticationSucceeded = Notification.Name("AuthenticationSucceeded")
}
