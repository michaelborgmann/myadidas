//
//  ErrorViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import UIKit

protocol ErrorViewDelegate: class {
    func dismiss()
}

class ErrorViewController: UIViewController, ViewModelBindalbe {
    
    // MARK: - Outlets
    
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    // MARK: - Properties
    
    private let viewModel: ErrorViewModel?
    
    private weak var delegate: ErrorViewDelegate?

    private let gradient = CAGradientLayer()
    
    // MARK: - Lifecycle
    
    required public init?<T>(coder: NSCoder, viewModel: T) {
        self.viewModel = viewModel as? ErrorViewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradient()
        setupErrorMessage()
        
        NetworkMonitor.shared.delegate = self
    }
    
    private func setupGradient(colors: Gradient = .error) {

        gradient.frame = view.frame
        
        gradient.colors = [
            colors.light.cgColor,
            colors.dark.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        view.layer.insertSublayer(gradient, at: 0)

    }
    
    private func setupErrorMessage() {
        emojiLabel.text = viewModel?.emoji ?? "🤔"
        
        titleLabel.text = viewModel?.title ?? "Ooops"
        titleLabel.textColor = Style.labelColor
        
        detailsLabel.text = viewModel?.details ?? "Something went wrong"
        detailsLabel.textColor = Style.labelColor
    }
    
    private struct Style {
        static let labelColor = UIColor.white
    }
    
}

// MARK: - Network Monitoring

extension ErrorViewController: NetworkMonitorDelegate {
    
    func onConnect() {
        delegate?.dismiss()
    }
    
    func onDisconnect() {
        // nothing to be done
    }
    
}

// MARK: - Storyboard

extension ErrorViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: ErrorViewModel, delegate: ErrorViewDelegate) -> ErrorViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}
