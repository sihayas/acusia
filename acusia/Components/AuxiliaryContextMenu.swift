//
//  AuxiliaryContextMenu.swift
//  acusia
//
//  Created by decoherence on 11/2/24.
//
/// A SwiftUI implementation of a context menu that can be used to display
/// auxiliary actions.

import ContextMenuAuxiliaryPreview
import SwiftUI
import SwiftUIX

struct AuxiliaryPreview: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                /// User's Past?
                // PastView(size: size)

                /// Main Feed
                VStack(spacing: 32) {
                    ForEach(sampleEntrySets) { sampleEntrySet in
                        EntryView(entrySet: sampleEntrySet)
                        EntryView(entrySet: sampleEntrySet)
                        EntryView(entrySet: sampleEntrySet)
                    }
                }
            }
        }
    }
}
//FIRST
// MARK: - View Modifier
struct AuxiliaryContextMenuModifier<AuxiliaryContent: View>: ViewModifier {
    let auxiliaryContent: AuxiliaryContent
    let menuItems: () -> [UIMenuElement]
    let config: AuxiliaryPreviewConfig
    
    func body(content: Content) -> some View {
        content.overlay(
            ContextMenuContainer(
                content: content,
                auxiliaryContent: auxiliaryContent,
                menuItems: menuItems,
                config: config
            )
        )
    }
}

// MARK: - Container View
struct ContextMenuContainer<Content: View, AuxiliaryContent: View>: UIViewRepresentable {
    let content: Content
    let auxiliaryContent: AuxiliaryContent
    let menuItems: () -> [UIMenuElement]
    let config: AuxiliaryPreviewConfig
    
    // Store interaction and manager as properties
    @StateObject private var viewModel = ContainerViewModel()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(container: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // Setup content view
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        
        container.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: container.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Create and store interaction
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        viewModel.interaction = interaction
        container.addInteraction(interaction)
        
        // Create and store context menu manager
        let contextMenuManager = ContextMenuManager(
            contextMenuInteraction: interaction,
            menuTargetView: container
        )
        viewModel.contextMenuManager = contextMenuManager
        contextMenuManager.delegate = context.coordinator
        contextMenuManager.auxiliaryPreviewConfig = config
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.container = self
        context.coordinator.auxiliaryContent = auxiliaryContent
        context.coordinator.menuItems = menuItems
    }
    
    // MARK: - Container ViewModel
    class ContainerViewModel: ObservableObject {
        var interaction: UIContextMenuInteraction?
        var contextMenuManager: ContextMenuManager?
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIContextMenuInteractionDelegate, ContextMenuManagerDelegate {
        var container: ContextMenuContainer
        var auxiliaryContent: AuxiliaryContent
        var menuItems: () -> [UIMenuElement]
        
        init(container: ContextMenuContainer) {
            self.container = container
            self.auxiliaryContent = container.auxiliaryContent
            self.menuItems = container.menuItems
            super.init()
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            container.viewModel.contextMenuManager?.notifyOnContextMenuInteraction(
                interaction,
                configurationForMenuAtLocation: location
            )
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
                UIMenu(title: "", children: self?.menuItems() ?? [])
            }
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willDisplayMenuFor configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionAnimating?
        ) {
            container.viewModel.contextMenuManager?.notifyOnContextMenuInteraction(
                interaction,
                willDisplayMenuFor: configuration,
                animator: animator
            )
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willEndFor configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionAnimating?
        ) {
            container.viewModel.contextMenuManager?.notifyOnContextMenuInteraction(
                interaction,
                willEndFor: configuration,
                animator: animator
            )
        }
        
        // Content Shape
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
        ) -> UITargetedPreview? {
            guard let targetView = interaction.view else { return nil }
        
            let bubbleWithTail = BubbleWithTailPath()
            let customPath = bubbleWithTail.path(in: targetView.bounds)
        
            let parameters = UIPreviewParameters()
            parameters.visiblePath = customPath
        
            return UITargetedPreview(
                view: targetView,
                parameters: parameters
            )
        }
        
        func onRequestMenuAuxiliaryPreview(sender: ContextMenuManager) -> UIView? {
            let hostingController = UIHostingController(rootView: auxiliaryContent)
            hostingController.view.backgroundColor = .clear
            hostingController.view.layer.borderColor = UIColor.systemGray.cgColor
            hostingController.view.layer.borderWidth = 1
            return hostingController.view
        }
    }
}

// MARK: - View Extension
extension View {
    func auxiliaryContextMenu<AuxiliaryContent: View>(
        auxiliaryContent: AuxiliaryContent,
        config: AuxiliaryPreviewConfig = AuxiliaryPreviewConfig(
            verticalAnchorPosition: .top,
            horizontalAlignment: .targetTrailing,
            preferredWidth: .constant(100),
            preferredHeight: .constant(100),
            marginInner: 10,
            marginOuter: 10,
            transitionConfigEntrance: .syncedToMenuEntranceTransition(),
            transitionExitPreset: .fade
        ),
        @MenuBuilder menuItems: @escaping () -> [UIMenuElement]
    ) -> some View {
        modifier(AuxiliaryContextMenuModifier(
            auxiliaryContent: auxiliaryContent,
            menuItems: menuItems,
            config: config
        ))
    }
}

// MARK: - Menu Builder
@resultBuilder
struct MenuBuilder {
    static func buildBlock(_ components: UIMenuElement...) -> [UIMenuElement] {
        components
    }
}

struct DarkModeWindowModifier: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let uiWindow = window.windows.first {
            uiWindow.overrideUserInterfaceStyle = .dark
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
