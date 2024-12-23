import SwiftUI

struct CustomGesture: UIViewRepresentable {
    var isEnabled: Bool
    var handle: (UIPanGestureRecognizer) -> ()

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let gesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
        gesture.delegate = context.coordinator
        view.addGestureRecognizer(gesture)
        context.coordinator.handleGesture = handle
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let gesture = uiView.gestureRecognizers?.first as? UIPanGestureRecognizer {
            gesture.isEnabled = isEnabled
        }
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var handleGesture: ((UIPanGestureRecognizer) -> Void)?

        @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                print("Pan gesture began")
            case .changed:
                print("Pan gesture changed")
            case .ended, .cancelled, .failed:
                print("Pan gesture ended or cancelled")
            default:
                break
            }

            // Call the external handle closure
            handleGesture?(recognizer)
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}


