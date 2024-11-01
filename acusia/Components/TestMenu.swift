// Created by: Dominic Go
import ContextMenuAuxiliaryPreview
import SwiftUI
import SwiftUIX

#Preview {
    AuxiliaryPreview()
        .preferredColorScheme(.dark)
}

// define the swift struct
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
                    }
                }
            }
        }
    }
}

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
    
    func makeCoordinator() -> Coordinator {
        Coordinator(auxiliaryContent: auxiliaryContent)
    }
    
    func makeUIView(context: Context) -> UIView {
        let container = ContainerView()
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
        
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        container.addInteraction(interaction)
        
        context.coordinator.contextMenuManager = ContextMenuManager(
            contextMenuInteraction: interaction,
            menuTargetView: container
        )
        context.coordinator.contextMenuManager?.delegate = context.coordinator
        context.coordinator.contextMenuManager?.auxiliaryPreviewConfig = config
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.auxiliaryContent = auxiliaryContent
        context.coordinator.menuItems = menuItems
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UIContextMenuInteractionDelegate, ContextMenuManagerDelegate {
        var auxiliaryContent: AuxiliaryContent
        var menuItems: () -> [UIMenuElement] = { [] }
        var contextMenuManager: ContextMenuManager?
        
        init(auxiliaryContent: AuxiliaryContent) {
            self.auxiliaryContent = auxiliaryContent
            super.init()
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            contextMenuManager?.notifyOnContextMenuInteraction(
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
            contextMenuManager?.notifyOnContextMenuInteraction(
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
            contextMenuManager?.notifyOnContextMenuInteraction(
                interaction,
                willEndFor: configuration,
                animator: animator
            )
        }
        
        func onRequestMenuAuxiliaryPreview(sender: ContextMenuManager) -> UIView? {
            let hostingController = UIHostingController(rootView: auxiliaryContent)
            return hostingController.view
        }
    }
}

// MARK: - Container View
class ContainerView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

// MARK: - View Extension
extension View {
    func auxiliaryContextMenu<AuxiliaryContent: View>(
        auxiliaryContent: AuxiliaryContent,
        config: AuxiliaryPreviewConfig = AuxiliaryPreviewConfig(
            verticalAnchorPosition: .automatic,
            horizontalAlignment: .targetCenter,
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
