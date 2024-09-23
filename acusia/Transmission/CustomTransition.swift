//
//  CustomTransition.swift
//  acusia
//
//  Created by decoherence on 9/17/24.
//
import SwiftUI
import Transmission
import UIKit

struct CustomTransition: PresentationLinkTransitionRepresentable {
    func makeUIPresentationController(presented: UIViewController, presenting: UIViewController?, context: Context) -> UIPresentationController {
        let sheet = UISheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        sheet.preferredCornerRadius = 20

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
        CoverTransitionAnimator(sourceView: context.sourceView, isPresenting: true)
    }

    func animationController(
        forDismissed dismissed: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        let animator = CoverTransitionAnimator(sourceView: context.sourceView, isPresenting: false)
        return animator
    }
}

class CoverTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    weak var sourceView: UIView?
    let isPresenting: Bool

    var animator: UIViewPropertyAnimator?

    init(sourceView: UIView?, isPresenting: Bool) {
        self.sourceView = sourceView
        self.isPresenting = isPresenting
        super.init()
    }

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

        let sourceFrame = sourceView?.convert(sourceView?.frame ?? .zero, to: containerView) ?? containerView.frame

        let snapshotContainer = UIView(frame: sourceFrame)
        snapshotContainer.layer.borderColor = UIColor.blue.cgColor
        snapshotContainer.layer.borderWidth = 2

        if isPresenting {
            // Create a snapshot of the source view
            let originalColor = fromVC.view.backgroundColor
            fromVC.view.backgroundColor = .clear
            let snapshot = fromVC.view.resizableSnapshotView(from: sourceFrame,
                                                             afterScreenUpdates: true,
                                                             withCapInsets: .zero)
            fromVC.view.backgroundColor = originalColor

            // Add the snapshot to the snapshot container
            if let snapshot = snapshot {
                snapshotContainer.addSubview(snapshot)
                snapshot.translatesAutoresizingMaskIntoConstraints = false
                snapshot.layer.borderWidth = 2
                snapshot.layer.borderColor = UIColor.red.cgColor
                NSLayoutConstraint.activate([
                    snapshot.centerYAnchor.constraint(equalTo: snapshotContainer.centerYAnchor),
                    snapshot.centerXAnchor.constraint(equalTo: snapshotContainer.centerXAnchor),
                    snapshot.widthAnchor.constraint(equalToConstant: snapshot.frame.width),
                    snapshot.heightAnchor.constraint(equalToConstant: snapshot.frame.height),
                ])
            }

            // Transitioning view is toView
            toView?.frame = toFrame
            toView?.layer.borderColor = UIColor.green.cgColor
            toView?.layer.borderWidth = 2
            toView?.transform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height)

            if let fromView {
                containerView.addSubview(fromView)
            }
            if let toView {
                containerView.addSubview(toView)
                containerView.addSubview(snapshotContainer)
            }

            animator.addAnimations {
                toVC.view.layoutIfNeeded()
                toView?.transform = CGAffineTransform.identity
                snapshotContainer.frame = toFrame /// Center the snapshot.
                snapshotContainer.transform = CGAffineTransform(translationX: 0, y: -18)
                snapshotContainer.layoutIfNeeded()
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
        }

        animator.addCompletion { animatingPosition in
            snapshotContainer.removeFromSuperview()
            
            switch animatingPosition {
            case .end:
                transitionContext.completeTransition(true)
            default:
                transitionContext.completeTransition(false)
            }
        }
        self.animator = animator
        return animator
    }
}
