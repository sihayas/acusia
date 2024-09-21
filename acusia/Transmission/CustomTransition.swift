//
//  CustomTransition.swift
//  acusia
//
//  Created by decoherence on 9/17/24.
//
import SwiftUI
import Transmission
import UIKit

struct SheetTransition: PresentationLinkTransitionRepresentable {
    var onTransitionCompleted: (() -> Void)? // Store the completion handler

    init(onTransitionCompleted: (() -> Void)? = nil) {
        self.onTransitionCompleted = onTransitionCompleted
    }

    /// The presentation controller to use for the transition.
    func makeUIPresentationController(
        presented: UIViewController,
        presenting: UIViewController?,
        context: Context
    ) -> UIPresentationController {
        let presentationController = UISheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        presentationController.detents = [.large()]
        presentationController.prefersGrabberVisible = true
        return presentationController
    }

    /// Updates the presentation controller for the transition
    func updateUIPresentationController(
        presentationController: UIPresentationController,
        context: Context
    ) {}

    /// The animation controller to use for the transition presentation.
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        CustomSheetAnimator(
            sourceView: context.sourceView,
            isPresenting: true,
            animation: nil,
            onTransitionCompleted: onTransitionCompleted
        )
    }

    /// The animation controller to use for the transition dismissal.
    func animationController(
        forDismissed dismissed: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        CustomSheetAnimator(
            sourceView: context.sourceView,
            isPresenting: false,
            animation: nil,
            onTransitionCompleted: onTransitionCompleted
        )
    }

    /// The interaction controller to use for the transition dismissal.
    func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning,
        context: Context
    ) -> UIViewControllerInteractiveTransitioning? {
        nil
    }

    /// The interaction controller to use for the transition dismissal.
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning,
        context: Context
    ) -> UIViewControllerInteractiveTransitioning? {
        nil
    }

    /// The presentation style to use for an adaptive presentation.
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        .none
    }

    /// The presentation controller to use for an adaptive presentation.
    func updateAdaptivePresentationController(
        adaptivePresentationController: UIPresentationController,
        context: Context
    ) {}
}

class CustomSheetAnimator: PresentationControllerTransition {
    weak var sourceView: UIView?
    var onTransitionCompleted: (() -> Void)?

    init(
        sourceView: UIView,
        isPresenting: Bool,
        animation: Animation?,
        onTransitionCompleted: (() -> Void)? = nil
    ) {
        super.init(isPresenting: isPresenting, animation: animation)
        sourceView.isHidden = false // Source view measures a frame, it does not provide content.
        self.sourceView = sourceView
        self.onTransitionCompleted = onTransitionCompleted
    }

    override func transitionAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: duration, curve: completionCurve)

        /// Extract a reference to both the view controller being replaced and the one being presented.
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return animator
        }

        /// UIKit encapsulates the entire transition inside a container view to simplify managing both the view hierarchy and the animations.
        /// Get a reference to the container view and determine what the final frame of the new view will be.
        let isPresenting = self.isPresenting
        let containerView = transitionContext.containerView

        /// Place the passed SwiftUI view into a hosting controller.
        let hostingController = toVC as? AnyHostingController
        hostingController?.disableSafeArea = true

        /// The source view that was tapped to initiate the transition.
        let sourceFrame = sourceView?.convert(sourceView?.frame ?? .zero, to: containerView) ?? containerView.frame

        /// Make a snapshot of the source view to animate from.
        let originalColor = fromVC.view.backgroundColor
        fromVC.view.backgroundColor = .clear
        let snapshot = fromVC.view.resizableSnapshotView(from: sourceFrame,
                                                         afterScreenUpdates: true,
                                                         withCapInsets: .zero)
        fromVC.view.backgroundColor = originalColor

        /// Create a container view to hold the snapshot.
        let snapshotContainer = UIView(frame: sourceFrame)

        /// Determine the final frame of the presented view controller.
        let presentedFrame = isPresenting
            ? transitionContext.finalFrame(for: toVC)
            : transitionContext.initialFrame(for: fromVC)

        if isPresenting {
            /// Set up snapshot
            if let snapshot = snapshot {
                snapshotContainer.addSubview(snapshot)
                snapshot.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    snapshot.centerYAnchor.constraint(equalTo: snapshotContainer.centerYAnchor),
                    snapshot.centerXAnchor.constraint(equalTo: snapshotContainer.centerXAnchor),
                    snapshot.widthAnchor.constraint(equalToConstant: snapshot.frame.width),
                    snapshot.heightAnchor.constraint(equalToConstant: snapshot.frame.height)
                ])
            }

            containerView.addSubview(toVC.view)
            containerView.addSubview(snapshotContainer)

            /// Set up toVC view for presentation as sheet
            toVC.view.frame = presentedFrame
            toVC.view.backgroundColor = .black
            toVC.view.layer.cornerRadius = 16
            toVC.view.layoutIfNeeded()
            hostingController?.render()

            /// Move sheet offscreen
            toVC.view.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)
        }

        /// Animate depending on whether the view is being presented or dismissed.
        animator.addAnimations {
            if isPresenting {
                snapshotContainer.frame = presentedFrame /// Center the snapshot.
                snapshotContainer.layoutIfNeeded()
                toVC.view.transform = .identity /// Move the sheet into view.
                toVC.view.layoutIfNeeded()
            } else {
                fromVC.view.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)
            }
        }

        /// Clean up the snapshot and container view when the animation completes.
        animator.addCompletion { position in
            snapshotContainer.removeFromSuperview()
            let completed = position == .end
            if isPresenting {
                if completed { self.onTransitionCompleted?() } /// Call the completion handler so parent SwiftUI view knows.
                transitionContext.completeTransition(completed)

            } else {
                transitionContext.completeTransition(completed)
            }
        }

        return animator
    }
}
