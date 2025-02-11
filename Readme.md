# AdaptiveModal-Demo

<div align="center">
  <img src="https://img.shields.io/badge/iOS-13.0%2B-blue" alt="iOS 13.0+"/>
  <img src="https://img.shields.io/badge/Swift-5.0%2B-orange" alt="Swift 5.0+"/>
  <img src="https://img.shields.io/badge/Dependencies-None-green" alt="No Dependencies"/>
  <br><br>
  
  <img src="demo.gif" 
       width="500"
       style="border-radius: 10px"
       alt="Modal Demo Animation"/>
  
  <p>Elegant and adaptive modal presenter with smooth transitions built with UIPresentationController</p>
</div>

## Key Features
✨ **Native Implementation**
- Built with UIPresentationController
- Custom transition animations
- Dynamic content sizing
- Gesture-driven interactions

🚀 **Smooth Experience**
- Scale-based transitions
- Hardware-accelerated animations
- Adaptive layout support
- Native iOS feel

## Usage

### Basic Setup
```swift
// Create transition delegate
let transitionDelegate = PresentationController()

// Configure your view controller
let contentVC = YourViewController()
let navigationController = UINavigationController(rootViewController: contentVC)
navigationController.modalPresentationStyle = .custom
navigationController.transitioningDelegate = transitionDelegate

// Present modally
present(navigationController, animated: true)
```

### Customization
```swift
let config = YFModalPresentationConfiguration(
    showDismissButton: true,
    cornerRadius: 36,
    backgroundColor: .systemBackground,
    dismissWhenTouchOutside: true,
    placement: .bottom
)
```

### Navigation Support
```swift
extension ViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push: return TransitionAnimator(type: .present)
        default: return TransitionAnimator(type: .dismiss)
        }
    }
}
```

## Technical Highlights
- 🎯 Built on native UIPresentationController
- 🔄 Custom UIViewControllerAnimatedTransitioning
- 📱 Full navigation stack support
- 🎨 Highly customizable appearance
- 📐 Automatic size adaptation

## Requirements
- iOS 13.0+
- Swift 5.0+
- Xcode 13.0+

## Author
Created by [Vlad Tretiak](your_linkedin_url)

## License
MIT License - feel free to use in your projects 😉
