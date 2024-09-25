//
//  CustomTransition.swift
//  acusia
//
//  Created by decoherence on 9/17/24.
//
import SwiftUI
import Transmission
import UIKit
import Wave

extension UISheetPresentationController.Detent {
    static func fraction(_ value: CGFloat) -> UISheetPresentationController.Detent {
        .custom(identifier: Identifier("Fraction:\(value)")) { context in
            context.maximumDetentValue * value
        }
    }
}

struct CustomTransition: PresentationLinkTransitionRepresentable {
    var completion: (() -> Void)?
    
    func makeUIPresentationController(presented: UIViewController, presenting: UIViewController?, context: Context) -> UIPresentationController {
        let sheet = UISheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        sheet.detents = [.medium()]
        sheet.preferredCornerRadius = 40
        sheet.prefersGrabberVisible = true
        presented.view.backgroundColor = .clear
        
        return sheet
    }

    /// Updates the presentation controller for the transition
    func updateUIPresentationController(
        presentationController: UIPresentationController,
        context: Context
    ) {}

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        // Pass the completion handler to the presenting animator
        return CoverTransitionAnimator(sourceView: context.sourceView, isPresenting: true, completion: completion)
    }

    func animationController(
        forDismissed dismissed: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        // Pass the completion handler to the dismissing animator
        return CoverTransitionAnimator(sourceView: context.sourceView, isPresenting: false, completion: completion)
    }
}

class CoverTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    weak var sourceView: UIView?
    let isPresenting: Bool
    var animator: UIViewPropertyAnimator?
    var completion: (() -> Void)? // Add a completion closure

    let animatedSpring = Spring(dampingRatio: 1.68, response: 1.8)

    lazy var sheetPresentationAnimator = SpringAnimator<CGFloat>(spring: animatedSpring)

    init(sourceView: UIView?, isPresenting: Bool, completion: (() -> Void)? = nil) {
        self.sourceView = sourceView
        self.isPresenting = isPresenting
        self.completion = completion // Store the completion closure
        super.init()
    }

    // Dismissal cancel animation duration
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return transitionContext?.isAnimated == true ? 0.5 : 0
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let animator = makeAnimatorIfNeeded(using: transitionContext)
        animator.startAnimation()

        if !transitionContext.isAnimated {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
        }
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        makeAnimatorIfNeeded(using: transitionContext)
    }

    func animationEnded(_ transitionCompleted: Bool) {
        animator = nil
    }

    func makeAnimatorIfNeeded(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewPropertyAnimator {
        if let animator = animator {
            return animator
        }

        // Presentation animation
        let animator = UIViewPropertyAnimator(
            duration: 0.5,
            timingParameters: UISpringTimingParameters(dampingRatio: 1.0)
        )

        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return animator
        }

        /// !IMPORTANT: For some weird reason, accessing the views of the view controller
        /// directly, like `fromVC.view` or `toVC.view` will break the sheet transition and gestures.
        /// Instead, use the `view(forKey:)` method of the `transitionContext` to get the views.
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        let containerView = transitionContext.containerView

        let fromFrame = transitionContext.viewController(forKey: .from).map { transitionContext.finalFrame(for: $0) } ?? containerView.bounds
        let toFrame = transitionContext.viewController(forKey: .to).map { transitionContext.finalFrame(for: $0) } ?? containerView.bounds

        // Calculate the frame of sourceView relative to fromVC.view to capture the correct snapshot area.
        let snapshotFrameInFromVC = sourceView?.convert(sourceView?.frame ?? .zero, to: fromVC.view) ?? containerView.frame

        // Calculate the frame of sourceView relative to containerView to position the snapshot correctly.
        let snapshotFrameInContainer = sourceView?.convert(sourceView?.frame ?? .zero, to: containerView) ?? containerView.frame

        let snapshot: UIView?

        if isPresenting {
            // Create a snapshot of fromVC.view from the defined area (snapshotFrameInFromVC).
            let originalColor = fromVC.view.backgroundColor
            fromVC.view.backgroundColor = .clear
            snapshot = fromVC.view.resizableSnapshotView(from: snapshotFrameInFromVC,
                                                         afterScreenUpdates: true,
                                                         withCapInsets: .zero)

            fromVC.view.backgroundColor = originalColor

            // Position the snapshot correctly within the snapshot container
            snapshot?.frame = snapshotFrameInContainer

            toView?.frame = toFrame
            toView?.transform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height)
            toView?.layoutIfNeeded()

            if let fromView {
                containerView.addSubview(fromView)
            }
            if let toView {
                containerView.addSubview(toView)
                containerView.addSubview(snapshot ?? UIView())
            }

            let toViewCenter = CGPoint(
                x: toFrame.midX,
                y: toFrame.midY + 55
            )

            let gestureVelocity = CGPoint(x: 0, y: -5000)

            animator.addAnimations {
                Wave.animate(
                    withSpring: self.animatedSpring,
                    mode: .animated,
                    gestureVelocity: gestureVelocity
                ) {
                    snapshot?.animator.frame.size = CGSize(width: 204, height: 204) // Important to animate first
                    snapshot?.animator.center = toViewCenter
                } completion: { finished, retargeted in
                    print("finished: \(finished), retargeted: \(retargeted)")
                }
                toView?.transform = CGAffineTransform.identity
            }
            
            animator.addCompletion { animatingPosition in
                switch animatingPosition {
                case .end:
                    snapshot?.removeFromSuperview()
                    transitionContext.completeTransition(true)
                default:
                    transitionContext.completeTransition(false)
                }
            }
        } else {
            // Transitioning view is fromView
            if let toView {
                containerView.addSubview(toView)
            }
            if let fromView {
                containerView.addSubview(fromView)
            }

            animator.addAnimations {
                fromView?.transform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height)
            }
            
            animator.addCompletion { animatingPosition in
                switch animatingPosition {
                case .end:
                    transitionContext.completeTransition(true)
                default:
                    transitionContext.completeTransition(false)
                }
            }
        }
        
        self.animator = animator
        return animator
    }
}
