//
//  UIView.swift
//  acusia
//
//  Created by decoherence on 10/6/24.
//
import SwiftUI

extension UIView {
    func animateSetHidden(_ hidden: Bool, duration: CGFloat = CATransaction.animationDuration(), completion: @escaping (Bool) -> () = { _ in }) {
        if duration > 0 {
            if self.isHidden, !hidden {
                self.alpha = 0
                self.isHidden = false
            }
            UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState) {
                self.alpha = hidden ? 0 : 1
            
            } completion: { c in
          
                if c {
                    self.isHidden = hidden
                }
                completion(c)
            }

        } else {
            self.isHidden = hidden
            self.alpha = hidden ? 0 : 1
            completion(true)
        }
    }
}
