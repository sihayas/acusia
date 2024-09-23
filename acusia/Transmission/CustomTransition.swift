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
        UISheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
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
        CoverTransitionAnimator(sourceView: context.sourceView, isPresenting: true, duration: 0.5)
    }

    func animationController(
        forDismissed dismissed: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        let animator = CoverTransitionAnimator(sourceView: context.sourceView, isPresenting: false, duration: 0.5)
        return animator
    }
}

class CoverTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    weak var sourceView: UIView?
    let isPresenting: Bool
    let duration: TimeInterval

    var animator: UIViewPropertyAnimator?

    init(sourceView: UIView?, isPresenting: Bool, duration: TimeInterval) {
        self.sourceView = sourceView
        self.isPresenting = isPresenting
        self.duration = duration
        super.init()
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return transitionContext?.isAnimated == true ? duration : 0
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
            duration: nil,
            curve: .linear
        )

        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        let fromFrame = transitionContext.viewController(forKey: .from).map { transitionContext.finalFrame(for: $0) } ?? containerView.bounds
        let toFrame = transitionContext.viewController(forKey: .to).map { transitionContext.finalFrame(for: $0) } ?? containerView.bounds

        let sourceFrame = sourceView?.convert(sourceView?.frame ?? .zero, to: containerView) ?? containerView.frame

        let snapshotContainer = UIView(frame: sourceFrame)
        snapshotContainer.layer.borderColor = UIColor.red.cgColor
        snapshotContainer.layer.borderWidth = 10

        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return animator
        }
        if isPresenting {
            let originalColor = fromVC.view.backgroundColor
            fromVC.view.backgroundColor = .clear
            let snapshot = fromVC.view.resizableSnapshotView(from: sourceFrame,
                                                             afterScreenUpdates: true,
                                                             withCapInsets: .zero)
            fromVC.view.backgroundColor = originalColor

            /// Set up snapshot
            if let snapshot = snapshot {
                snapshotContainer.addSubview(snapshot)
                snapshot.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    snapshot.centerYAnchor.constraint(equalTo: snapshotContainer.centerYAnchor),
                    snapshot.centerXAnchor.constraint(equalTo: snapshotContainer.centerXAnchor),
                    snapshot.widthAnchor.constraint(equalToConstant: snapshot.frame.width),
                    snapshot.heightAnchor.constraint(equalToConstant: snapshot.frame.height),
                ])
            }

            // transitioning view is toView
            toView?.frame = toFrame
            toView?.transform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height)

            if let fromView {
                containerView.addSubview(fromView)
            }
            if let toView {
                containerView.addSubview(toView)
                containerView.addSubview(snapshotContainer)
            }

            animator.addAnimations {
                toView?.transform = CGAffineTransform.identity
                snapshotContainer.frame = toFrame /// Center the snapshot.
                snapshotContainer.layoutIfNeeded()
            }
        } else {
            // transitioning view is fromView
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
            // remove teh snapshot container
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
