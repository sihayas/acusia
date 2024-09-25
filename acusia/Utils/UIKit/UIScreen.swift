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
        
        // If the hit view is the root view, check for interactive subviews.
        if hitView == rootViewController?.view {
            for subview in hitView.subviews {
                let subviewPoint = subview.convert(point, from: self)
                if let subviewHitView = subview.hitTest(subviewPoint, with: event) {
                    return subviewHitView
                }
            }
        }
        
        // If no interactive subview is found, return nil to allow pass through.
        return hitView == rootViewController?.view ? nil : hitView
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
