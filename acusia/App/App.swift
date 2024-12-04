import CoreData
import SwiftUI
import Transmission

struct AcusiaAppView_Previews: PreviewProvider {
    static var previews: some View {
        let windowState = UIState()
        let musicKit = MusicKit()
        let homeState = HomeState()
        let floatingBarPresenter = FloatingBarPresenter()

        AuthScreen()
            .environmentObject(windowState)
            .environmentObject(musicKit)
            .environmentObject(homeState)
            .onAppear {
                floatingBarPresenter.showFloatingBar()
            }
    }
}

class UIState: ObservableObject {
    static let shared = UIState()

    init() {}

    enum SymmetryState: String {
        case collapsed
        case feed
        case search
        case form
        case reply
    }

    @Published var size: CGSize = .zero

    /// Symmetry
    @Published var symmetryState: SymmetryState = .collapsed
    @Published var selectedResult: SearchResult?

    /// Reply Sheet
    @Published var collapsedHomeHeight: CGFloat = 0
    @Published var isSplit: Bool = false
    @Published var isOffsetAtTop: Bool = true
    @Published var isLayered: Bool = false

    /// Customizes the navigation bar appearance.
    func setupNavigationBarAppearance() {
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

    func enableDarkMode() {
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let uiWindow = window.windows.first
        {
            uiWindow.overrideUserInterfaceStyle = .dark
        }
    }
}

@main
struct AcusiaApp: App {
    @StateObject private var auth = Auth.shared
    @ObservedObject private var windowState = UIState.shared
    @ObservedObject private var musicKit = MusicKit.shared
    @ObservedObject private var homeState = HomeState.shared

    let persistenceController = PersistenceController.shared
    private var safeAreaInsets: UIEdgeInsets = .init()

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(auth)
                .environmentObject(windowState)
                .environmentObject(musicKit)
                .environmentObject(homeState)
                .onAppear {
                    print("Checking authentication") 
                    auth.checkAuthentication()
                }
        }
    }
}

struct AcusiaAppView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var windowState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit
    @EnvironmentObject private var homeState: HomeState

    private var floatingBarPresenter = FloatingBarPresenter()

    @State private var dragOffset: CGFloat = 0
    var cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        if !auth.isAuthenticated {
            AuthScreen()
        } else {
            GeometryReader { proxy in
                // Split Layout Helpers
                let screenHeight = proxy.size.height
                let screenWidth = proxy.size.width

                let collapsedHomeHeight: CGFloat = safeAreaInsets.top * 2

                let homeHeight: CGFloat = windowState.isSplit ?
                    collapsedHomeHeight + dragOffset
                    : screenHeight

                let replyHeight: CGFloat = windowState.isSplit ?
                    screenHeight - dragOffset
                    : 0

                ZStack(alignment: .top) {
                    Home()
                        .overlay {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .background(.thinMaterial)
                                .opacity(windowState.isSplit ? 1.0 : 0)
                                .animation(.snappy, value: windowState.isSplit)
                                .allowsHitTesting(false)
                        }
                        .frame(minWidth: screenWidth, minHeight: screenHeight)
                        .frame(height: homeHeight, alignment: .top)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(radius: 10)
                        .animation(.snappy(), value: homeHeight)
                        .zIndex(1)

                    VStack {
                        if windowState.isSplit {
                            VStack(alignment: .leading) { // Align to top. This contains the clipped view.
                                EmptyView()
                                    .frame(minWidth: screenWidth, minHeight: screenHeight)
                                    .frame(height: replyHeight, alignment: .top) // Align content inside to top.
                                    .overlay(
                                        Color.white.opacity(windowState.isSplit ? 0 : 0.05)
                                            .blendMode(.exclusion)
                                            // .animation(.spring(), value: replyOpacity)
                                            .allowsHitTesting(false)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                    .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                    .animation(.spring(), value: replyHeight)
                            }
                            .frame(minWidth: screenWidth, minHeight: screenHeight, alignment: .bottom)
                        }
                    }
                    .transition(.blurReplace)
                    .zIndex(0)
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            /// Only allow gesture input to modify split progress if not fully split or if fully split and root scroll offset is at the top.
                            guard windowState.isSplit, !windowState.isLayered, windowState.isOffsetAtTop else { return }
                            let yOffset = value.translation.height

                            /// Dragging up, means scrolling down, negative offset.
                            /// Dragging down, means scrolling up, positive offset.
                            if yOffset > 0 {
                                dragOffset = yOffset
                            }
                        }
                        .onEnded { value in
                            guard windowState.isSplit, !windowState.isLayered, windowState.isOffsetAtTop else { return }

                            let yOffset = value.translation.height
                            let yVelocity = value.velocity.height

                            if yOffset > 0, yVelocity > 1000 || yOffset >= (screenHeight / 2) { // User is dragging downwards
                                withAnimation(.snappy) {
                                    windowState.isSplit = false
                                    dragOffset = 0
                                }
                            } else {
                                dragOffset = 0
                            }
                        }
                )
                .onAppear {
                    /// Setup window state.
                    windowState.size = proxy.size
                    windowState.collapsedHomeHeight = collapsedHomeHeight
                    windowState.setupNavigationBarAppearance()
                    windowState.enableDarkMode()

                    floatingBarPresenter.showFloatingBar()

                    /// Setup music kit.
                    Task {
                        await musicKitManager.requestMusicAuthorization()

                        if musicKitManager.isAuthorizedForMusicKit {
                            await musicKitManager.loadRecentlyPlayedSongs()
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                Button(action: {
                    auth.signOut()
                }) {
                    Text("Sign Out")
                        .padding()
                        .background(Color.red)
                }
            }
            .sheet(isPresented: Binding(
                get: { windowState.symmetryState == .search },
                set: { newValue in
                    if !newValue, windowState.symmetryState == .search {
                        windowState.symmetryState = .feed
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

class FloatingBarPresenter {
    private var floatingBarWindow: UIWindow?

    func showFloatingBar() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        let view = FloatingBarView()
            .environmentObject(UIState.shared)
            .environmentObject(MusicKit.shared)
            .environmentObject(HomeState.shared)
            .environmentObject(Auth.shared)

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear
        hostingController.safeAreaRegions = SafeAreaRegions()

        floatingBarWindow = PassThroughWindow(windowScene: scene)
        floatingBarWindow?.backgroundColor = .clear
        floatingBarWindow?.frame = CGRect(x: 0,
                                          y: 0,
                                          width: UIScreen.main.bounds.width,
                                          height: UIScreen.main.bounds.height)
        floatingBarWindow?.rootViewController = hostingController
        floatingBarWindow?.windowLevel = UIWindow.Level.alert + 1
        floatingBarWindow?.isHidden = false
    }
}

/// IMPORTANT: Putting a border on the outer stack prevents touch inputs from being passed through.
struct FloatingBarView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit
    @EnvironmentObject private var homeState: HomeState

    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            SymmetryView()
                .offset(y: -keyboardHeight)
                .animation(.snappy, value: keyboardHeight)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height + 24
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    self.keyboardHeight = safeAreaInsets.bottom
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            self.keyboardHeight = safeAreaInsets.bottom
            windowState.symmetryState = .feed
        }
        .opacity(0)
    }
}
