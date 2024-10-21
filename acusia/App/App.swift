import CoreData
import SwiftUI
import Transmission

let apiurl = "http://192.168.1.248:8000"

class WindowState: ObservableObject {
    static let shared = WindowState()

    enum SymmetryState: String {
        case collapsed
        case feed
        case search
        case form
        case reply
    }

    @Published var size: CGSize = .zero

    // SymmetryView
    @Published var symmetryState: SymmetryState = .collapsed
    @Published var selectedResult: SearchResult?

    // Reply Sheet
    @Published var collapsedHomeHeight: CGFloat = 0
    @Published var isSplit: Bool = false
    @Published var isOffsetAtTop: Bool = true
    @Published var isLayered: Bool = false

    private init() {}
}

@main
struct AcusiaApp: App {
    @ObservedObject private var windowState = WindowState.shared
    @ObservedObject private var musicKit = MusicKit.shared
    @ObservedObject private var homeState = HomeState.shared

    let persistenceController = PersistenceController.shared
    private var floatingBarPresenter = FloatingBarPresenter()
    private var safeAreaInsets: UIEdgeInsets = .init()

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(windowState)
                .environmentObject(musicKit)
                .environmentObject(homeState)
                .onAppear {
                    floatingBarPresenter.showFloatingBar()
                }
        }
    }
}

/// The general idea for the split layout is there is a ZStack container that holds
/// the RepliesView below the HomeView. When the user triggers a split,
/// the HomeView mask frame shrinks to the baseHomeHeight
/// and the RepliesView mask frame expands to the baseReplyHeight.
/// As the user drags up the RepliesView mask expands to full, and the
/// HomeView mask shrinks to the minHomeHeight.
struct AcusiaAppView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var musicKitManager: MusicKit

    @State private var dragOffset: CGFloat = 0

    private var cornerRadius = max(UIScreen.main.displayCornerRadius, 12)

    var body: some View {
        ScrollView(.init()) {
            // TabView {
            // Main Feed + User + User History View
            GeometryReader { proxy in
                // Horizontal Slide Helpers
                let screen = proxy.frame(in: .global)
                let offset = screen.minX
                let scale = 1 + (offset / screen.width)

                let progress = min(1, max(0, -offset / screen.width))
                let dynamicCornerRadius = max(12, cornerRadius - (cornerRadius - 12) * progress)

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
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(radius: 10)
                        .animation(.snappy(), value: homeHeight)
                        .zIndex(1)

                    VStack {
                        if windowState.isSplit {
                            VStack(alignment: .leading) { // Align to top. This contains the clipped view.
                                RepliesSheet()
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
                // Notification Slide Over
                .overlay(
                    Color.white
                        .opacity(min(0.3, max(0, -offset / screen.width * 0.3)))
                )
                .clipShape(RoundedRectangle(cornerRadius: dynamicCornerRadius, style: .continuous))
                .scaleEffect(scale >= 0.92 ? scale : 0.92, anchor: .center)
                .offset(x: -offset)
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
                    windowState.size = proxy.size
                    windowState.collapsedHomeHeight = collapsedHomeHeight

                    UINavigationBar.setupCustomAppearance()

                    Task {
                        await musicKitManager.requestMusicAuthorization()

                        if musicKitManager.isAuthorizedForMusicKit {
                            await musicKitManager.loadRecentlyPlayedSongs()
                        }
                    }
                }
            }

            // Notifications
            //     VStack {}
            //         .frame(maxWidth: .infinity, maxHeight: .infinity)
            //         .background(.black)
            // }
            // .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .ignoresSafeArea()
        .sheet(isPresented: Binding(
            get: { windowState.symmetryState == .search },
            set: { newValue in
                if !newValue, windowState.symmetryState != .form { windowState.symmetryState = .feed }
            }
        )) {
            IndexSheet()
        }
        .sheet(isPresented: Binding(
            get: { windowState.symmetryState == .form },
            set: { newValue in
                if !newValue { windowState.symmetryState = .feed }
            }
        )) {
            ZStack {
                Rectangle()
                    .foregroundStyle(.clear)
                    .background(
                        .thinMaterial
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea()

                if let selectedResult = windowState.selectedResult {
                    ImprintView(result: selectedResult)
                }
            }
            .edgesIgnoringSafeArea(.vertical)
            .presentationBackground(.clear)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(40)
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
            .environmentObject(MusicKit.shared)
            .environmentObject(HomeState.shared)

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .clear
        // Remove safe area from the hosting controller
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

/// NOTE: Putting a border on the outer stack prevents touch inputs from being passed through.
struct FloatingBarView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            if keyboardHeight > safeAreaInsets.bottom {
                Color.white.opacity(0.01)
                    .contentShape(Rectangle())
                    .edgesIgnoringSafeArea(.all)
                    .simultaneousGesture(DragGesture().onChanged { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    )
            }

            SymmetryView()
                .offset(y: -keyboardHeight)
                .animation(.snappy, value: keyboardHeight)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardFrame.height + safeAreaInsets.bottom
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    self.keyboardHeight = safeAreaInsets.bottom
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            self.keyboardHeight = safeAreaInsets.bottom
        }
    }
}
