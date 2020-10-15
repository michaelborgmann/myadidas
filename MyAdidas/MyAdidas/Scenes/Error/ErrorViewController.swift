//
//  ErrorViewController.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 15.10.20.
//

import UIKit

protocol ErrorViewDelegate: class {
    func doSomething()
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
    }
    
    private func setupGradient(colors: Gradient = .error) {

        gradient.frame = view.frame
        
        gradient.colors = [
            colors.start.cgColor,
            colors.end.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 1, y: 0.1)
        gradient.endPoint = CGPoint(x: 0.2, y: 1)
        
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

// MARK: - Storyboard

extension ErrorViewController: StoryboardInstantiable {
    
    class func instantiate(with viewModel: ErrorViewModel, delegate: ErrorViewDelegate) -> ErrorViewController {
        let viewController = instanceFromStoryboard(with: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
}
