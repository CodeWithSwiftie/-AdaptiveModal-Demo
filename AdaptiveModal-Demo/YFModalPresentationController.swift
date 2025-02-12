//
//  YFModalPresentationController.swift
//  UIPresentationController + Transitioning
//
//  Created by Vlad Tretiak on 2/11/25.
//

import UIKit

// MARK: - Configuration

public struct YFModalPresentationConfiguration {
    public var showDismissButton = true
    public var cornerRadius: CGFloat
    public var backgroundColor: UIColor
    public var dismissWhenTouchOutside: Bool
    public var placement: Placement
    
    public enum Placement {
        case center, bottom
    }
    
    public init(
        showDismissButton: Bool = true,
        cornerRadius: CGFloat = 36,
        backgroundColor: UIColor = .systemBackground,
        dismissWhenTouchOutside: Bool = true,
        placement: Placement = .bottom
    ) {
        self.showDismissButton = showDismissButton
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.dismissWhenTouchOutside = dismissWhenTouchOutside
        self.placement = placement
    }
    
    public static var `default`: YFModalPresentationConfiguration {
        YFModalPresentationConfiguration(
            showDismissButton: false,
            cornerRadius: 36,
            backgroundColor: .systemBackground,
            dismissWhenTouchOutside: true,
            placement: .bottom
        )
    }
}

// MARK: - Modal Presenter

public final class YFModalPresentationController: UIPresentationController {
    
    private let configuration: YFModalPresentationConfiguration
    
    // Adding a background dimming view
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    private lazy var closeButton: UIButton = { [weak self] in
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let colorConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .systemFill])
        let finalConfiguration = symbolConfiguration.applying(colorConfiguration)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: finalConfiguration)
        let button = UIButton(configuration: .plain())
        button.configuration?.image = image
        button.tintColor = .systemFill
        
        button.addAction(.init(handler: { _ in
            self?.presentedViewController.dismiss(animated: true)
        }), for: .touchUpInside)
        
        return button
    }()
    
    init(
        presentedViewController: UIViewController,
        presenting: UIViewController?,
        configuration: YFModalPresentationConfiguration = .default
    ) {
        self.configuration = configuration
        super.init(
            presentedViewController: presentedViewController,
            presenting: presenting
        )
        configureTapGestureRecognizer()
    }
    
    override public func presentationTransitionWillBegin() {
        
        guard let containerView else { return }
        
        // Add the dimming view to the container view
        containerView.insertSubview(dimmingView, at: 0)
        dimmingView.frame = containerView.bounds
        
        // Configure dismiss button
        if let presentedView, configuration.showDismissButton {
            presentedView.addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: presentedView.topAnchor, constant: 12),
                closeButton.trailingAnchor.constraint(equalTo: presentedView.trailingAnchor, constant: -12),
                closeButton.widthAnchor.constraint(equalToConstant: 40),
                closeButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        // Animate the appearance of the dimming view
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
        
    }
    
    // Called before the dismissal transactions begin
    override public func dismissalTransitionWillBegin() {
        
        // Animate the disappearance of the dimming view
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }
    
    // Layout the presented view and dimming view if needed
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let preferredSize = presentedViewController.preferredContentSize(for: containerView.bounds)
        
        let yOffset = {
            switch configuration.placement {
            case .center:
                containerView.frame.midY - preferredSize.height / 2
            case .bottom:
                containerView.bounds.height - preferredSize.height - containerView.safeAreaInsets.bottom
            }
        }()
        return CGRect(
            x: (containerView.bounds.width - preferredSize.width) / 2,
            y: yOffset,
            width: preferredSize.width,
            height: preferredSize.height
        )
    }
    
    private func configureTapGestureRecognizer() {
        guard configuration.dismissWhenTouchOutside else { return }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchOnDimmingView))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func touchOnDimmingView() {
        presentingViewController.dismiss(animated: true)
    }

}
// MARK: - UI Presentation Controller

public final class PresentationController: NSObject, UIViewControllerTransitioningDelegate {
    
    private let configuration: YFModalPresentationConfiguration
    
    public init(configuration: YFModalPresentationConfiguration) {
        self.configuration = configuration
        super.init()
    }
    
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        YFModalPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            configuration: configuration
        )
    }
}

// MARK: - Transitiong Animator

final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum TransitionType {
        case present
        case dismiss
    }
    
    private let type: TransitionType
    
    init(type: TransitionType) {
        self.type = type
        super.init()
    }
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.35
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        // Configure animator
        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.85)
        
        // Setup container view
        containerView.addSubview(toView)
        containerView.backgroundColor = fromView.backgroundColor
        containerView.layer.cornerRadius = fromView.layer.cornerRadius
        containerView.layer.masksToBounds = true
        
        // Calculate content height before creating snapshot
        if let toVC = transitionContext.viewController(forKey: .to) {
           toView.frame.size.height = toVC.preferredContentSize(for: containerView.bounds).height
        }
        
        let fromSnapshotView = fromView.layer.snapshotView()
        let toSnapshotView = toView.layer.snapshotView()
        
        fromView.alpha = 0
        toView.alpha = 0
        
        containerView.addSubview(fromSnapshotView)
        containerView.addSubview(toSnapshotView)
        
        // Update presentation controller layout
        animator.addAnimations {
            let key: UITransitionContextViewControllerKey = self.type == .present ? .from : .to
            if let presentationController = transitionContext.viewController(forKey: key)?.navigationController?.presentationController {
                presentationController.containerView?.setNeedsLayout()
                presentationController.containerView?.layoutIfNeeded()
            }
        }
        
        switch type {
        case .present:
            toSnapshotView.alpha = 0
            toSnapshotView.transform = .init(scaleX: 0.87, y: 0.87)
            
            animator.addAnimations {
                toSnapshotView.alpha = 1
                toSnapshotView.transform = .identity
                fromSnapshotView.alpha = 0
            }
            
        case .dismiss:
            
            toSnapshotView.alpha = 0
            
            animator.addAnimations {
                fromSnapshotView.alpha = 0
                fromSnapshotView.transform = .init(scaleX: 0.85, y: 0.85)
                toSnapshotView.alpha = 1
            }
        }
        
        // Completion
        animator.addCompletion { _ in
            toView.alpha = 1
            fromView.alpha = 1
            fromSnapshotView.removeFromSuperview()
            toSnapshotView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator.startAnimation()
    }
}

// MARK: - Utils

private extension CALayer {
    func snapshotView() -> UIView {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let snapshotImage = renderer.image { context in
           render(in: context.cgContext)
        }

        let snapshotView = UIImageView(image: snapshotImage)
        snapshotView.frame = frame
        return snapshotView
    }
}

private extension UIViewController {
    func preferredContentSize(for bounds: CGRect, padding: CGFloat = 32) -> CGSize {
        // Ensure width is not negative after subtracting padding
        let adjustedWidth = max(0, bounds.width - padding)
        let targetSize = CGSize(width: adjustedWidth, height: UIView.layoutFittingCompressedSize.height)
        
        // Determine the view to measure, using topViewController's view for navigation controllers if possible.
        let targetView: UIView = {
            if let navigationController = self as? UINavigationController,
               let topVC = navigationController.topViewController,
               topVC.isViewLoaded {
                
                navigationController.view.setNeedsLayout()
                navigationController.view.layoutIfNeeded()
                
                return topVC.view
            }
            
            return view
        }()

        // Ensure layout is applied before measuring.
        targetView.setNeedsLayout()
        targetView.layoutIfNeeded()
        
        let calculatedSize = targetView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        
        // If the view's bounds are zero, return a zero size as fallback.
        guard calculatedSize != .zero else {
            assertionFailure("Bounds of view to measure are zero. \(targetView)")
            return .zero
        }
        
        // If auto layout did not compute a valid height, calculate height manually by summing subviews' heights.
        if calculatedSize.height <= .zero {
            let manualHeight = targetView.subviews.reduce(0) { partialResult, subview in
                partialResult + subview.frame.height
            }
            return CGSize(width: calculatedSize.width, height: manualHeight)
        }
        
        return .init(width: calculatedSize.width, height: calculatedSize.height)
    }
}
