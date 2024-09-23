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
        let presentationController = SheetPresentationController(
            sourceView: context.sourceView,
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
        guard let presentationController = presented.presentationController as? SheetPresentationController else {
            return nil
        }
        let transition = CustomSheetTransition(
            sourceView: presentationController.sourceView!,
            isPresenting: true
        )
        return transition
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
            sourceView: presentationController.sourceView!,
            isPresenting: false,
            onTransitionCompleted: onTransitionCompleted
        )
        presentationController.beginTransition(with: transition)
        return transition
    }

    /// The interaction controller to use for the transition dismissal.
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning,
        context: Context
    ) -> UIViewControllerInteractiveTransitioning? {
        // swiftlint:disable force_cast
        animator as! CustomSheetTransition
    }
}

class SheetPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    private(set) weak var sourceView: UIView?
    private weak var transition: CustomSheetTransition?

    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))

    private var isPanGestureActive = false
    private var initialTranslation: CGFloat = 0
    private var dyOffset: CGFloat = 0

    override var shouldPresentInFullscreen: Bool { false }
    override var presentationStyle: UIModalPresentationStyle { .custom }

    init(
        sourceView: UIView? = nil,
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?
    ) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.sourceView = sourceView
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let height = containerView.bounds.height * 0.5
        return CGRect(
            x: 0,
            y: containerView.bounds.height - height,
            width: containerView.bounds.width,
            height: height
        )
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else { return }
        containerView.addSubview(presentedViewController.view)
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
        presentedViewController.view.translatesAutoresizingMaskIntoConstraints = false
        setupPresentedViewConstraints(containerView: containerView)
    }

    func setupPresentedViewConstraints(containerView: UIView) {
        let frame = frameOfPresentedViewInContainerView
        NSLayoutConstraint.activate([
            presentedViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: frame.origin.y),
            presentedViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: frame.origin.x),
            presentedViewController.view.widthAnchor.constraint(equalToConstant: frame.width),
            presentedViewController.view.heightAnchor.constraint(equalToConstant: frame.height),
        ])
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        guard completed else { return }
        panGesture.delegate = self
        panGesture.allowedScrollTypesMask = .all
        containerView?.addGestureRecognizer(panGesture)
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        delegate?.presentationControllerWillDismiss?(self)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            delegate?.presentationControllerDidDismiss?(self)
        } else {
            delegate?.presentationControllerDidAttemptToDismiss?(self)
        }
    }

    func beginTransition(with transition: CustomSheetTransition) {
        self.transition = transition
        transition.wantsInteractiveStart = isPanGestureActive
    }

    @objc
    private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let containerView = containerView else { return }

        // Get the vertical translation of the gesture in the container view's coordinate space
        let translation = gestureRecognizer.translation(in: containerView)

        switch gestureRecognizer.state {
        case .began, .changed:
            transition?.animator?.stopAnimation(true)
            // Apply the translation to the view's transform to move it up and down
            presentedViewController.view.transform = CGAffineTransform(translationX: 0, y: max(0, translation.y))

        case .ended, .cancelled:
            // Reset the transform when the gesture ends or is cancelled
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.presentedViewController.view.transform = .identity
            }

        default:
            break
        }
    }
}

class CustomSheetTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    weak var sourceView: UIView?
    var onTransitionCompleted: (() -> Void)?
    var isPresenting: Bool

    var animator: UIViewImplicitlyAnimating?
    var onInteractionEnded: (() -> Void)?
    
    private var animatorForCurrentTransition: UIViewImplicitlyAnimating?

    static let displayCornerRadius: CGFloat = max(UIScreen.main.displayCornerRadius, 12)

    init(
        sourceView: UIView,
        isPresenting: Bool,
        onTransitionCompleted: (() -> Void)? = nil
    ) {
        sourceView.isHidden = false // Source view measures a frame, it does not provide content.
        self.sourceView = sourceView
        self.onTransitionCompleted = onTransitionCompleted
        self.isPresenting = isPresenting
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
         // animateTransition should work too, so let's just use the interruptibleAnimator implementation to achieve it
         let anim = self.interruptibleAnimator(using: transitionContext)
         anim.startAnimation()
     }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = animator {
            return animator
        }

        let isPresenting = isPresenting
        // let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(completionCurve.rawValue << 16))
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: completionCurve
        )

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
                    snapshot.heightAnchor.constraint(equalToConstant: snapshot.frame.height),
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

        self.animator = animator
        return animator
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionContext?.isAnimated == true ? 0.35 : 0
    }
    
    override func cancel() {
        let clampedPercentComplete = min(max(percentComplete, 0.0), 0.5)

        let minSpeed: CGFloat = 0.1
        let maxSpeed: CGFloat = 0.1

        completionSpeed = minSpeed + (maxSpeed - minSpeed) * (clampedPercentComplete / 0.5)
        timingCurve = UISpringTimingParameters(dampingRatio: 1.0)
        super.cancel()
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
