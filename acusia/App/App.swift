import CoreData
import SwiftUI
import Transmission

@main
struct AcusiaApp: App {
    @StateObject private var auth = Auth.shared
    @ObservedObject private var uiState = UIState.shared
    @ObservedObject private var musicKit = MusicKit.shared
    @ObservedObject private var homeState = HomeState.shared

    let persistenceController = PersistenceController.shared
    private var safeAreaInsets: UIEdgeInsets = .init()

    var body: some Scene {
        WindowGroup {
            AcusiaAppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(auth)
                .environmentObject(uiState)
                .environmentObject(musicKit)
                .environmentObject(homeState)
                // .onAppear { auth.authenticate() }
        }
    }
}

struct AcusiaAppView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var auth: Auth
    @EnvironmentObject private var uiState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit
    @EnvironmentObject private var homeState: HomeState

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

                let homeHeight: CGFloat = uiState.isSplit ?
                    collapsedHomeHeight + dragOffset
                    : screenHeight

                let replyHeight: CGFloat = uiState.isSplit ?
                    screenHeight - dragOffset
                    : 0

                ZStack(alignment: .top) {
                    Home()
                        .overlay {
                            Rectangle()
                                .foregroundStyle(.clear)
                                .background(.thinMaterial)
                                .opacity(uiState.isSplit ? 1.0 : 0)
                                .animation(.snappy, value: uiState.isSplit)
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
                        if uiState.isSplit {
                            VStack(alignment: .leading) { // Align to top. This contains the clipped view.
                                EmptyView()
                                    .frame(minWidth: screenWidth, minHeight: screenHeight)
                                    .frame(height: replyHeight, alignment: .top) // Align content inside to top.
                                    .overlay(
                                        Color.white.opacity(uiState.isSplit ? 0 : 0.05)
                                            .blendMode(.exclusion)
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
                            guard uiState.isSplit, !uiState.isLayered, uiState.isOffsetAtTop else { return }
                            let yOffset = value.translation.height

                            /// Dragging up, means scrolling down, negative offset.
                            /// Dragging down, means scrolling up, positive offset.
                            if yOffset > 0 {
                                dragOffset = yOffset
                            }
                        }
                        .onEnded { value in
                            guard uiState.isSplit, !uiState.isLayered, uiState.isOffsetAtTop else { return }

                            let yOffset = value.translation.height
                            let yVelocity = value.velocity.height

                            if yOffset > 0, yVelocity > 1000 || yOffset >= (screenHeight / 2) { // User is dragging downwards
                                withAnimation(.snappy) {
                                    uiState.isSplit = false
                                    dragOffset = 0
                                }
                            } else {
                                dragOffset = 0
                            }
                        }
                )
                .onAppear {
                    uiState.size = proxy.size
                    uiState.collapsedHomeHeight = collapsedHomeHeight
                    uiState.enableDarkMode()
                    uiState.setupSymmetryWindow()
                    uiState.setupNavigationBar()

                    Task {
                        await musicKitManager.requestMusicAuthorization()

                        if musicKitManager.isAuthorizedForMusicKit {
                            await musicKitManager.loadRecentlyPlayedSongs()
                        }
                    }
                }
            }
            .ignoresSafeArea()
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

/// IMPORTANT: Putting a border on the outer stack prevents touch inputs from being passed through.
struct SymmetryWindowView: View {
    @EnvironmentObject private var uiState: UIState
    @EnvironmentObject private var musicKitManager: MusicKit
    @EnvironmentObject private var homeState: HomeState
    @Environment(\.safeAreaInsets) private var safeAreaInsets

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
            uiState.symmetryState = .feed
            uiState.enableDarkMode()
        }
    }
}


struct AcusiaAppPreview: PreviewProvider {
    static var previews: some View {
        let auth = Auth.shared
        let uiState = UIState.shared
        let musicKit = MusicKit.shared
        let homeState = HomeState.shared

        auth.isAuthenticated = true
        let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDA0NTEuYTVmN2Y5OGQxMzRlNGY1ZTg1NWY2YmNkYzUyMmViMDMuMDkwMSIsImV4cCI6MTczMzQyMTc4OX0.VTf2UT9IzFL3-mZtGJGjsn4L1v1rcuGf2JmGS3Jql58"

        return AcusiaAppView()
            .environmentObject(auth)
            .environmentObject(uiState)
            .environmentObject(musicKit)
            .environmentObject(homeState)
            .onAppear {
                uiState.setupSymmetryWindow()
            }
    }
}
