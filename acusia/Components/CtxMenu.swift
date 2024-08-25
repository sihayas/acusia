import SwiftUI
import UIKit

struct CustomContextMenuHelper<Content: View>: UIViewRepresentable {
    var content: Content
    var menu: UIMenu
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        hostView.view.backgroundColor = .clear
        
        view.addSubview(hostView.view)
        NSLayoutConstraint.activate([
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Any updates to the view hierarchy should be handled here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: CustomContextMenuHelper
        
        init(_ parent: CustomContextMenuHelper) {
            self.parent = parent
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                self.parent.menu
            }
        }
    }
}

extension View {
    func customContextMenu(menu: @escaping () -> UIMenu) -> some View {
        CustomContextMenuHelper(content: self, menu: menu())
            .background(Color.clear) // Ensure the background doesn't interfere
    }
}
