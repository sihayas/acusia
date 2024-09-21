//
//  CustomTransition.swift
//  acusia
//
//  Created by decoherence on 9/17/24.
//
import SwiftUI
import Transmission
import UIKit

extension PresentationLinkTransition {
    static let custom: PresentationLinkTransition = .custom(
        options: .init(),
        SheetTransition()
    )
}

struct SheetTransition: PresentationLinkTransitionRepresentable {
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
            animation: nil
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
            animation: nil
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

    init(
        sourceView: UIView,
        isPresenting: Bool,
        animation: Animation?
    ) {
        super.init(isPresenting: isPresenting, animation: animation)
        sourceView.isHidden = false // Source view measures a frame. No content.
        self.sourceView = sourceView
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

        /// Determine the final frame of the presented view controller.
        let presentedFrame = isPresenting
            ? transitionContext.finalFrame(for: toVC)
            : transitionContext.initialFrame(for: fromVC)
        
        
        /// Make a snapshot of the source view to animate from.
        let originalColor = fromVC.view.backgroundColor
        fromVC.view.backgroundColor = .clear
        let snapshot = fromVC.view.resizableSnapshotView(from: sourceFrame,
                                                         afterScreenUpdates: true,
                                                         withCapInsets: .zero)
        fromVC.view.backgroundColor = originalColor


        if isPresenting {
            /// Set up the toVC view for the presentation animation.
            containerView.addSubview(toVC.view)


            let snapshotContainer = UIView()
            snapshotContainer.frame = sourceFrame
            if let snapshot = snapshot {
                snapshotContainer.addSubview(snapshot)

                snapshot.translatesAutoresizingMaskIntoConstraints = false

                // Center the snapshot in the snapContainer
                NSLayoutConstraint.activate([
                    snapshot.centerYAnchor.constraint(equalTo: snapshotContainer.centerYAnchor),
                    snapshot.centerXAnchor.constraint(equalTo: snapshotContainer.centerXAnchor)
                ])

                snapshot.widthAnchor.constraint(equalToConstant: snapshot.frame.width).isActive = true
                snapshot.heightAnchor.constraint(equalToConstant: snapshot.frame.height).isActive = true
            }

            containerView.addSubview(snapshotContainer)

            /// Set up the toVC view for the presentation animation.
            toVC.view.frame = presentedFrame
            toVC.view.backgroundColor = .white

            /// Move the background off-screen for the slide-up animation.
            toVC.view.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)

            /// Ensure layout is updated before animations.
            toVC.view.layoutIfNeeded()
            hostingController?.render()

            /// Define animations for presenting.
            animator.addAnimations {
                snapshotContainer.frame = presentedFrame
                snapshot?.layoutIfNeeded()
                toVC.view.transform = .identity
                toVC.view.layoutIfNeeded()
            }

            /// Clean up snapshot and complete transition after animation.
            animator.addCompletion { animatingPosition in
                snapshot?.removeFromSuperview()
                switch animatingPosition {
                case .end:
                    transitionContext.completeTransition(true)
                default:
                    transitionContext.completeTransition(false)
                }
            }
        } else {
            /// Dismissal animations.
            animator.addAnimations {
                fromVC.view.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)
            }

            /// Complete transition after dismissal.
            animator.addCompletion { animatingPosition in
                snapshot?.removeFromSuperview()
                switch animatingPosition {
                case .end:
                    transitionContext.completeTransition(true)
                default:
                    transitionContext.completeTransition(false)
                }
            }
        }

        return animator
    }
}
