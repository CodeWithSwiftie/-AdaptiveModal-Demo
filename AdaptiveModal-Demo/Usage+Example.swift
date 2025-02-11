//
//  Usage+Example.swift
//  UIPresentationController + Transitioning
//
//  Created by Vlad Tretiak on 2/11/25.
//

import UIKit

// This view controller demonstrates a custom modal presentation using a custom transitioning delegate.
final class ViewController: UIViewController {

    // Delegate responsible for managing the custom presentation and transition animations.
    let transitionDelegate = PresentationController()
    
    // Button that triggers the modal presentation when tapped.
    private let exampleButton: UIButton = {
        // Create a plain button configuration.
        let button = UIButton(configuration: .plain())
        // Set the title for the button.
        button.configuration?.title = "Present Modal"
        return button
    }()
    
    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup subviews layout.
        setupLayout()
        // Setup actions for interactive elements.
        setupActions()
    }
    
    // Configures the layout of subviews using Auto Layout constraints.
    private func setupLayout() {
        // Set the background color of the main view.
        view.backgroundColor = .systemGray6
        // Add the example button to the main view.
        view.addSubview(exampleButton)
        exampleButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Center the example button horizontally and adjust its vertical position.
        NSLayoutConstraint.activate([
            exampleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exampleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300)
        ])
    }
    
    // Sets up button actions using UIAction.
    private func setupActions() {
        // Add a tap action to present the modal container.
        exampleButton.addAction(.init(handler: { [weak self] _ in
            self?.presentModalContainer()
        }), for: .touchUpInside)
    }
    
    // Presents a custom modal container with a navigation controller that uses custom transitions.
    private func presentModalContainer() {
        // Instantiate the initial view controller for the modal presentation.
        let vcA = InvestmentOverviewController()
        // Embed the view controller in a navigation controller.
        let presentationNC = UINavigationController(rootViewController: vcA)
        // Set the modal presentation style to custom.
        presentationNC.modalPresentationStyle = .custom
        // Assign the custom transitioning delegate.
        presentationNC.transitioningDelegate = transitionDelegate
        // Set self as the navigation controller's delegate to handle transition animations.
        presentationNC.delegate = self
        
        // Present the navigation controller modally.
        present(presentationNC, animated: true)
    }
}

extension ViewController: UINavigationControllerDelegate {
    // Returns the custom animator object for push and pop transitions.
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        // Choose transition type based on the navigation operation.
        switch operation {
        case .push:
            // Return animator for presenting new view controller.
            return TransitionAnimator(type: .present)
        default:
            // Return animator for dismissing (or popping) the current view controller.
            return TransitionAnimator(type: .dismiss)
        }
    }
}

@available(iOS 17, *)
#Preview {
    let controller = UINavigationController(rootViewController: ViewController())   // Create your view controller instance
    return controller   // Return the configured view controller
}
