//
//  SheetHero.swift
//  acusia
//
//  Created by decoherence on 9/15/24.
//

import SwiftUI
import Transmission
import UIKit

extension PresentationLinkTransition {
    static let custom: PresentationLinkTransition = .custom(
        options: .init(),
        CustomTransition()
    )
}

struct CustomTransition: PresentationLinkTransitionRepresentable {
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
        return presentationController
    }

    /// Updates the presentation controller for the transition
    func updateUIPresentationController(
        presentationController: UIPresentationController,
        context: Context
    ) {}

    /// The animation controller to use for the transition presentation.
    ///
    /// > Note: This protocol implementation is optional and defaults to `nil`
    ///
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        MatchedGeometryTransition(
            sourceView: context.sourceView,
            isPresenting: true,
            animation: nil
        )
    }

    /// The animation controller to use for the transition dismissal.
    ///
    /// > Note: This protocol implementation is optional and defaults to `nil`
    ///
    func animationController(
        forDismissed dismissed: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        MatchedGeometryTransition(
            sourceView: context.sourceView,
            isPresenting: false,
            animation: nil
        )
    }

    /// The interaction controller to use for the transition dismissal.
    ///
    /// > Note: This protocol implementation is optional and defaults to `nil`
    ///
    func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning,
        context: Context
    ) -> UIViewControllerInteractiveTransitioning? {
        nil
    }

    /// The interaction controller to use for the transition dismissal.
    ///
    /// > Note: This protocol implementation is optional and defaults to `nil`
    ///
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning,
        context: Context
    ) -> UIViewControllerInteractiveTransitioning? {
        nil
    }

    /// The presentation style to use for an adaptive presentation.
    ///
    /// > Note: This protocol implementation is optional and defaults to `.none`
    ///
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        .none
    }

    /// The presentation controller to use for an adaptive presentation.
    ///
    /// > Note: This protocol implementation is optional
    ///
    func updateAdaptivePresentationController(
        adaptivePresentationController: UIPresentationController,
        context: Context
    ) {}
}

class MatchedGeometryTransition: PresentationControllerTransition {
    weak var sourceView: UIView?

    init(
        sourceView: UIView,
        isPresenting: Bool,
        animation: Animation?
    ) {
        super.init(isPresenting: isPresenting, animation: animation)
        self.sourceView = sourceView
    }

    override func transitionAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewPropertyAnimator {
        // Create an animator
        let animator = UIViewPropertyAnimator(animation: animation) ??
            UIViewPropertyAnimator(duration: duration, curve: completionCurve)

        // Get the presented (sheet) view controller
        guard let presented = transitionContext.viewController(forKey: isPresenting ? .to : .from)
        else {
            transitionContext.completeTransition(false)
            return animator
        }

        let isPresenting = isPresenting

        // Cast the presented view controller to AnyHostingController (assumed to be hosting SwiftUI views)
        let hostingController = presented as? AnyHostingController
        let oldValue = hostingController?.disableSafeArea ?? false
        hostingController?.disableSafeArea = true

        // Get the source frame from the source view
        var sourceFrame = sourceView.map {
            $0.convert($0.frame, to: transitionContext.containerView)
        } ?? transitionContext.containerView.frame

        // Get the final frame for the sheet (the final position where it should appear)
        let presentedFrame = isPresenting
            ? transitionContext.finalFrame(for: presented)
            : transitionContext.initialFrame(for: presented)

        if isPresenting {
            // MARK: Presentation

            // Add the presented view to the container view (clear background)
            transitionContext.containerView.addSubview(presented.view)

            // First frame (transparent), scaling with match geometry effect
            presented.view.frame = sourceFrame
            presented.view.layer.cornerRadius = 14
            presented.view.backgroundColor = .clear // Set background to clear
            print("Presented view frame set to sourceFrame: \(presented.view.frame)")

            // Second frame (sheet background), where the slide transition will occur
            let sheetBackgroundView = UIView(frame: presentedFrame)
            sheetBackgroundView.backgroundColor = .red // Set background to red
            sheetBackgroundView.layer.cornerRadius = 14
            transitionContext.containerView.insertSubview(sheetBackgroundView, belowSubview: presented.view)

            // Set up the slide from the bottom (start off-screen)
            sheetBackgroundView.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)

            // Layout immediately
            presented.view.layoutIfNeeded()
            hostingController?.render()

            // Animate both the match geometry effect and the slide-up transition for the sheet background
            animator.addAnimations {
                // Slide the background sheet from the bottom
                sheetBackgroundView.transform = .identity // Slide to its original position

                // Match geometry effect on the presented view
                presented.view.frame = presentedFrame
                print("Presented view frame after animation: \(presented.view.frame)")

                // Ensure layout is updated after animations
                presented.view.layoutIfNeeded()
            }

            // Clean up after the animation completes
            animator.addCompletion { animatingPosition in
                hostingController?.disableSafeArea = oldValue

                switch animatingPosition {
                case .end:
                    transitionContext.completeTransition(true)
                default:
                    transitionContext.completeTransition(false)
                }
            }
        } else {
            // MARK: Dismissal

            animator.addAnimations {
                // Slide down the visible sheet
                let sheetBackgroundView = transitionContext.containerView.subviews.first(where: { $0.backgroundColor == .red })
                sheetBackgroundView?.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)

                // Slide down the clear view/matched geometry content as part of the dismissal
                presented.view.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)
            }

            animator.addCompletion { animatingPosition in
//                hostingController?.disableSafeArea = oldValue

                switch animatingPosition {
                case .end:
                    transitionContext.completeTransition(true)
                default:
                    transitionContext.completeTransition(false)
                }
            }
        }

        // Return the animator
        return animator
    }
}
