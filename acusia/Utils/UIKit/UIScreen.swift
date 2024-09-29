//
//  Untitled.swift
//  acusia
//
//  Created by decoherence on 9/2/24.
//
import SwiftUI


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

extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}

extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

extension UIScreen {

    var displayCornerRadius: CGFloat {
        _displayCornerRadius
    }

    public var _displayCornerRadius: CGFloat {
        let key = String("suidaRrenroCyalpsid_".reversed())
        let value = value(forKey: key) as? CGFloat ?? 0
        return value
    }
}

extension UIColor {

    var isTranslucent: Bool {
        var alpha: CGFloat = 0
        if getWhite(nil, alpha: &alpha) {
            return alpha < 1
        }
        return false
    }
}
