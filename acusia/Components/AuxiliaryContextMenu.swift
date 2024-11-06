//
//  AuxiliaryContextMenu.swift
//  acusia
//
//  Created by decoherence on 11/2/24.
//

import ContextMenuAuxiliaryPreview
import SwiftUI
import SwiftUIX

// MARK: - View Modifier

struct AuxiliaryContextMenuModifier<AuxiliaryContent: View>: ViewModifier {
    let auxiliaryContent: AuxiliaryContent
    let menuItems: () -> [UIMenuElement]
    
    @Binding var gestureTranslation: CGPoint
    @Binding var gestureVelocity: CGPoint
     
    let config: AuxiliaryPreviewConfig
    func body(content: Content) -> some View {
        content.overlay(
            ContextMenuContainer(
                content: content,
                auxiliaryContent: auxiliaryContent,
                menuItems: menuItems,
                gestureTranslation:  $gestureTranslation,
                gestureVelocity: $gestureVelocity,
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
    @Binding var gestureTranslation: CGPoint
    @Binding var gestureVelocity: CGPoint
    let config: AuxiliaryPreviewConfig
    
    @StateObject private var viewModel = ContainerViewModel()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(container: self, gestureTranslation: $gestureTranslation, gestureVelocity: $gestureVelocity)
    }
    
    func makeUIView(context: Context) -> UIView {
        // Create a container view to host the content.
        let container = UIView()
        container.backgroundColor = .clear
        
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
        
        // Create a context menu interaction.
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        viewModel.interaction = interaction
        container.addInteraction(interaction)
        
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
    
    // MARK: - Coordinator / Delegate

    class Coordinator: NSObject, UIContextMenuInteractionDelegate, ContextMenuManagerDelegate {
        var container: ContextMenuContainer
        var auxiliaryContent: AuxiliaryContent
        var menuItems: () -> [UIMenuElement]
        @Binding var gestureTranslation: CGPoint
        @Binding var gestureVelocity: CGPoint
        

        init(container: ContextMenuContainer, gestureTranslation: Binding<CGPoint>, gestureVelocity: Binding<CGPoint>) {
            self.container = container
            self.auxiliaryContent = container.auxiliaryContent
            self.menuItems = container.menuItems
            self._gestureTranslation = gestureTranslation
            self._gestureVelocity = gestureVelocity
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
            
            /// When the context menu appears, interactions and such are now handled by the root view of ContextMenu.
            /// Both the menu and the preview share this root view. In ContextMenuManager, this is
            /// contextMenuContainerViewWrapper. Hook into the pan gesture to read its values.
            animator?.addAnimations { [weak self] in
                guard let self = self else { return }
                guard let window = interaction.view?.window else { return }
            
                if let containerView = window.subviews.first(where: {
                    String(describing: type(of: $0)).contains("ContextMenuContainer")
                }) {
                    if let panGesture = containerView.gestureRecognizers?.first(where: {
                        $0 is UIPanGestureRecognizer &&
                            $0.description.contains("PreviewPlatterPan")
                    }) as? UIPanGestureRecognizer {
                        panGesture.addTarget(self, action: #selector(handleContextMenuPan(_:)))
                        print("Successfully hooked into context menu pan gesture from Coordinator")
                    }
                }
            }
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
            return hostingController.view
        }
        
        @objc private func handleContextMenuPan(_ gesture: UIPanGestureRecognizer) {
             let translation = gesture.translation(in: gesture.view)
             let velocity = gesture.velocity(in: gesture.view)
            
            self.gestureTranslation = translation
            self.gestureVelocity = velocity

         }
    }
}

// MARK: - View Extension

extension View {
    func auxiliaryContextMenu<AuxiliaryContent: View>(
        auxiliaryContent: AuxiliaryContent,
        gestureTranslation: Binding<CGPoint>,
        gestureVelocity: Binding<CGPoint>,
        config: AuxiliaryPreviewConfig = AuxiliaryPreviewConfig(
            verticalAnchorPosition: .top,
            horizontalAlignment: .targetTrailing,
            preferredWidth: .constant(100),
            preferredHeight: .constant(100),
            marginInner: 10,
            marginOuter: 10,
            marginLeading: 0,
            marginTrailing: 0,
            transitionConfigEntrance: .syncedToMenuEntranceTransition(),
            transitionExitPreset: .fade
        ),
        @MenuBuilder menuItems: @escaping () -> [UIMenuElement]
    ) -> some View {
        modifier(AuxiliaryContextMenuModifier(
            auxiliaryContent: auxiliaryContent,
            menuItems: menuItems,
            gestureTranslation: gestureTranslation,
            gestureVelocity: gestureVelocity,
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
           let uiWindow = window.windows.first
        {
            uiWindow.overrideUserInterfaceStyle = .dark
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
