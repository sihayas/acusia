//
//  UIState.swift
//  acusia
//
//  Created by decoherence on 12/4/24.
//
import SwiftUI

/// Manages the UI states and properties of the app.
class UIState: ObservableObject {
    static let shared = UIState()

    /// Symmetry Window Presenter-related state
    private var floatingBarWindow: UIWindow?

    /// App states and properties
    enum SymmetryState: String {
        case collapsed
        case user
        case feed
        case search
        case form
        case reply
        case create
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

    // MARK: - Symmetry Window Presentation

    func setupSymmetryWindow() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        let view = SymmetryWindowView()
            .environmentObject(UIState.shared)
            .environmentObject(MusicKit.shared)
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

    // MARK: - Navigation Bar Appearance

    func setupNavigationBar() {
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

    // MARK: - Dark Mode

    func enableDarkMode() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene } // Ensure the scene is a UIWindowScene
            .forEach { windowScene in
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }
            }
    }
}
