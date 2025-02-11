//
//  Demo+ViewControllers.swift
//  UIPresentationController + Transitioning
//
//  Created by Vlad Tretiak on 2/11/25.
//

import UIKit

final class InvestmentOverviewController: UIViewController {
    private let headerImageView: UIImageView = {
        // Create image view with a system image
        let imageView = UIImageView(image: UIImage(systemName: "chart.xyaxis.line"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemIndigo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 18, *) {
            imageView.setSymbolImage(UIImage(systemName: "chart.bar.fill")!, contentTransition: .automatic)
        }

        return imageView
    }()
    
    private let balanceLabel: UILabel = {
        // Create balance label
        let label = UILabel()
        label.text = "$124,567.89"
        label.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        // Create subtitle label
        let label = UILabel()
        label.text = "Your Investment Overview"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let portfolioButton: UIButton = {
        // Create portfolio button
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "View Portfolio Details"
        button.configuration?.image = UIImage(systemName: "arrow.right")
        button.configuration?.imagePlacement = .trailing
        button.configuration?.cornerStyle = .capsule
        button.configuration?.titleTextAttributesTransformer = .init({ attr in
            var copy = attr
            copy.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return copy
        })
        button.configuration?.background.backgroundColor = .systemIndigo
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 36
        view.layer.masksToBounds = true
        title = "Overview"
        
        // Add subviews individually
        view.addSubview(headerImageView)
        view.addSubview(balanceLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(portfolioButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header image constraints
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            headerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 120),
            headerImageView.widthAnchor.constraint(equalToConstant: 120),
            
            // Balance label constraints
            balanceLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 16),
            balanceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            balanceLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Subtitle label constraints
            subtitleLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Portfolio button constraints
            portfolioButton.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 24),
            portfolioButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            portfolioButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            portfolioButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            portfolioButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupActions() {
        portfolioButton.addAction(.init(handler: { [weak self] _ in
            // Navigate to PortfolioDetailsController
            let detailsVC = PortfolioDetailsController()
            self?.navigationController?.pushViewController(detailsVC, animated: true)
        }), for: .touchUpInside)
    }
}


final class PortfolioDetailsController: UIViewController {
    private let stocksView = AssetTypeView(title: "Stocks", value: "$89,432.12", icon: "chart.xyaxis.line")
    private let cryptoView = AssetTypeView(title: "Crypto", value: "$23,654.77", icon: "bitcoinsign.circle")
    private let bondsView = AssetTypeView(title: "Bonds", value: "$11,481.00", icon: "building.columns")
    
    private lazy var assetsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stocksView, cryptoView, bondsView, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(24, after: bondsView)
        stack.setCustomSpacing(24, after: subtitleLabel)
        return stack
    }()
    
    // Main action button for trade
    private let tradeButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Start Trading"
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.backgroundColor = .systemIndigo
        button.configuration?.titleTextAttributesTransformer = .init({ attr in
            var copy = attr
            copy.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return copy
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Custom Back button
    private let backButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Back"
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.backgroundColor = .systemGray
        button.configuration?.titleTextAttributesTransformer = .init({ attr in
            var copy = attr
            copy.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return copy
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Stack that contains both trade and back buttons
    private lazy var actionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [backButton, tradeButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let subtitleLabel: UILabel = {
        // Create subtitle label
        let label = UILabel()
        label.text = "Your Investment Overview. See your performance and make informed decisions."
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide the default back button
        navigationItem.hidesBackButton = true
        
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 36
        view.layer.masksToBounds = true
        title = "Details"
        
        [assetsStack, actionStack].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            assetsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            assetsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            assetsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            assetsStack.bottomAnchor.constraint(equalTo: actionStack.topAnchor, constant: -24),
            
            actionStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            actionStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionStack.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupActions() {
        tradeButton.addAction(.init(handler: { [weak self] _ in
            let tradeVC = TradeViewController()
            self?.navigationController?.pushViewController(tradeVC, animated: true)
        }), for: .touchUpInside)
        
        backButton.addAction(.init(handler: { [weak self] _ in
            // Navigate back to the previous screen
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
}


final class TradeViewController: UIViewController {
    private let symbolTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter symbol (e.g. AAPL)" // Input field for symbol
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemGray4
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let amountTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter amount" // Input field for amount
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        field.backgroundColor = .systemGray4
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var inputStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [symbolTextField, amountTextField])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let buyButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Buy"
        button.configuration?.baseBackgroundColor = .systemGreen
        button.configuration?.cornerStyle = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.titleTextAttributesTransformer = .init({ attr in
            var copy = attr
            copy.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return copy
        })
        return button
    }()
    
    private let sellButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Sell"
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.cornerStyle = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.titleTextAttributesTransformer = .init({ attr in
            var copy = attr
            copy.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return copy
        })
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Back"
        button.configuration?.cornerStyle = .large
        button.configuration?.background.backgroundColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.titleTextAttributesTransformer = .init({ attr in
            var copy = attr
            copy.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return copy
        })
        return button
    }()
    
    // Горизонтальный стек с тремя кнопками
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [backButton, buyButton, sellButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        setupUI()
        setupConstraints()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 36
        view.layer.masksToBounds = true
        title = "Trade"
        
        [inputStack, buttonStack].forEach { view.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            inputStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            inputStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputStack.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -24),
            
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupActions() {
        buyButton.addAction(.init(handler: { _ in
            // Handle Buy action
        }), for: .touchUpInside)

        sellButton.addAction(.init(handler: { _ in
            // Handle Sell action
        }), for: .touchUpInside)
        
        backButton.addAction(.init(handler: { [weak self] _ in
            // Navigate back to the previous screen
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
}


private class AssetTypeView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private let changeContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }()
        
        private let changeLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .medium)
            return label
        }()
        
        private let changeArrow: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemGreen
            return imageView
        }()
        
        private var changeTimer: Timer?
        private var currentValue: Double = 0
        private var targetValue: Double = 0

    
    init(title: String, value: String, icon: String, change: Double = 2.45) {
            super.init(frame: .zero)
            targetValue = change
            
            titleLabel.text = title
            valueLabel.text = value
            iconImageView.image = UIImage(systemName: icon)
            
            setupUI()
            startChangeAnimation()
        }


    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
           backgroundColor = .tertiarySystemFill
           layer.cornerRadius = 12
           
           [iconImageView, titleLabel, valueLabel, changeContainer].forEach {
               $0.translatesAutoresizingMaskIntoConstraints = false
               addSubview($0)
           }
           
           [changeArrow, changeLabel].forEach {
               $0.translatesAutoresizingMaskIntoConstraints = false
               changeContainer.addSubview($0)
           }
           
           NSLayoutConstraint.activate([
               heightAnchor.constraint(equalToConstant: 72),
               
               iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
               iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
               iconImageView.widthAnchor.constraint(equalToConstant: 24),
               iconImageView.heightAnchor.constraint(equalToConstant: 24),
               
               titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
               titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
               
               changeContainer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
               changeContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
               changeContainer.heightAnchor.constraint(equalToConstant: 20),
               
               changeArrow.leadingAnchor.constraint(equalTo: changeContainer.leadingAnchor),
               changeArrow.centerYAnchor.constraint(equalTo: changeContainer.centerYAnchor),
               changeArrow.widthAnchor.constraint(equalToConstant: 12),
               changeArrow.heightAnchor.constraint(equalToConstant: 12),
               
               changeLabel.leadingAnchor.constraint(equalTo: changeArrow.trailingAnchor, constant: 4),
               changeLabel.centerYAnchor.constraint(equalTo: changeContainer.centerYAnchor),
               
               valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
               valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
               valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12)
           ])
       }
    
    private func startChangeAnimation() {
            updateChangeUI(value: 0)
            
          
        let duration = 0.5
            let steps = 60
            let stepDuration = duration / Double(steps)
            
            changeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                let stepValue = self.targetValue / Double(steps)
                self.currentValue += stepValue
                
                if abs(self.currentValue) >= abs(self.targetValue) {
                    self.currentValue = self.targetValue
                    timer.invalidate()
                    self.animateSuccess()
                }
                
                self.updateChangeUI(value: self.currentValue)
            }
        }
        
        private func updateChangeUI(value: Double) {
            let isPositive = value >= 0
            changeLabel.text = String(format: "%.2f%%", abs(value))
            
            let color: UIColor = isPositive ? .systemGreen : .systemRed
            changeLabel.textColor = color
            changeArrow.tintColor = color
            changeArrow.image = UIImage(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
            
            UIView.animate(withDuration: 0.2) {
                self.changeLabel.alpha = 0.8
                self.changeArrow.alpha = 0.8
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.changeLabel.alpha = 1
                    self.changeArrow.alpha = 1
                }
            }
        }
        
        private func animateSuccess() {
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [1, 1.1, 1]
            animation.keyTimes = [0, 0.5, 1]
            animation.duration = 0.3
            changeContainer.layer.add(animation, forKey: "successAnimation")
        }
        
        deinit {
            changeTimer?.invalidate()
        }


}
