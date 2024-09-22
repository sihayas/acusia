//
//  CustomTransition.swift
//  acusia
//
//  Created by decoherence on 9/17/24.
//
import SwiftUI
import Transmission
import UIKit

class SheetPresentationController: InteractivePresentationController {
    var edge: Edge = .bottom

    override var presentationStyle: UIModalPresentationStyle {
        .custom // Custom presentation style to make it a sheet.
    }

    init(
        edge: Edge = .bottom,
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        self.edge = edge
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }

    override func presentedViewTransform(for translation: CGPoint) -> CGAffineTransform {
        return .identity
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()

        presentingViewController.view.isHidden = presentedViewController.presentedViewController != nil
    }

    // The frame of the presented view controller.
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)

        frame.origin.y = containerView!.frame.height * (0.3 / 3.0)
        return frame
    }

}

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
        let presentationController = SheetPresentationController(
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
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        context: Context
    ) -> UIViewControllerAnimatedTransitioning? {
        CustomSheetTransition(
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
        guard let presentationController = dismissed.presentationController as? SheetPresentationController else {
            return nil
        }
        let transition = CustomSheetTransition(
            sourceView: context.sourceView,
            isPresenting: false,
            animation: nil,
            onTransitionCompleted: onTransitionCompleted
        )
        presentationController.transition(with: transition)
        return transition
    }

    /// The interaction controller to use for the transition dismissal.
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning,
        context: Context
    ) -> UIViewControllerInteractiveTransitioning? {
        return animator as? CustomSheetTransition
    }
}

class CustomSheetTransition: PresentationControllerTransition {
    weak var sourceView: UIView?
    var onTransitionCompleted: (() -> Void)?

    static let displayCornerRadius: CGFloat = {
        #if targetEnvironment(macCatalyst)
        return 12
        #else
        return max(UIScreen.main.displayCornerRadius, 12)
        #endif
    }()

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

    override func cancel() {
        let clampedPercentComplete = min(max(percentComplete, 0.0), 0.5)
        
        let minSpeed: CGFloat = 0.1
        let maxSpeed: CGFloat = 0.3
        
        completionSpeed = minSpeed + (maxSpeed - minSpeed) * (clampedPercentComplete / 0.5)
        timingCurve = UISpringTimingParameters(dampingRatio: 1.0)
        super.cancel()
    }

    override func transitionAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewPropertyAnimator {
        let isPresenting = self.isPresenting
        let animator = UIViewPropertyAnimator(animation: animation) ??
            UIViewPropertyAnimator(duration: duration, curve: completionCurve)

        /// UIKit encapsulates the entire transition inside a container view to simplify managing both the view hierarchy and the animations.
        /// Get a reference to the container view and determine what the final frame of the new view will be.
        let containerView = transitionContext.containerView

        /// Extract a reference to both the view controller being replaced and the one being presented.
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return animator
        }

        /// Place the passed SwiftUI view into a hosting controller.
        let hostingController = toVC as? AnyHostingController
        hostingController?.disableSafeArea = true

        /// Scale the from view controller down and move it down.
        let isScaleEnabled = toVC.view.convert(toVC.view.frame.origin, to: nil).y == 0
        let safeAreaInsets = containerView.safeAreaInsets
        var dzTransform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        dzTransform = dzTransform.translatedBy(x: 0, y: safeAreaInsets.top / 2)

        let cornerRadius = Self.displayCornerRadius

        /// The source view that was tapped to initiate the transition.
        let sourceFrame = sourceView?.convert(sourceView?.frame ?? .zero, to: containerView) ?? containerView.frame

        /// Create a container view to hold the snapshot.
        let snapshotContainer = UIView(frame: sourceFrame)

        /// Determine the final frame of the presented view controller.
        let presentedFrame = isPresenting
            ? transitionContext.finalFrame(for: toVC)
            : transitionContext.initialFrame(for: fromVC)

        toVC.view.layer.cornerCurve = .continuous
        fromVC.view.layer.cornerCurve = .continuous

        if isPresenting {
            /// Make a snapshot of the source view to animate from.
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
                    snapshot.heightAnchor.constraint(equalToConstant: snapshot.frame.height)
                ])
            }

            containerView.addSubview(toVC.view)
            containerView.addSubview(snapshotContainer)

            /// Set up toVC view for presentation as sheet
            fromVC.view.layer.cornerRadius = cornerRadius

            toVC.view.frame = presentedFrame
            toVC.view.backgroundColor = UIColor.systemGray6
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
                if isScaleEnabled {
                    fromVC.view.transform = dzTransform
                    fromVC.view.layer.cornerRadius = 12
                }
            } else {
                toVC.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                toVC.view.layer.cornerRadius = cornerRadius
                fromVC.view.transform = CGAffineTransform(translationX: 0, y: presentedFrame.height)
            }
        }

        /// Clean up the snapshot and container view when the animation completes.
        animator.addCompletion { position in
            snapshotContainer.removeFromSuperview()

            let completed = position == .end
            if isPresenting {
                if completed {
                    self.onTransitionCompleted?()
                } /// Call the completion handler so parent SwiftUI view knows.
                transitionContext.completeTransition(completed)
            } else {
                if completed {
                    toVC.view.layer.cornerRadius = 0
                }
                transitionContext.completeTransition(completed)
            }
        }

        return animator
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
