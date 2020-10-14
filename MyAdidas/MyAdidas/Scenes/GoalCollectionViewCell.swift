//
//  GoalCollectionViewCell.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 01/10/2020.
//

import UIKit

class GoalCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    
    // MARK: - Properties
    
    private let gradient = CAGradientLayer()
    
    private var item: Item? = nil {
        
        didSet {
            updateGradient(with: .colors(for: item))
            
            updateTitleLabel(title: item?.title ?? "")
            updateDescriptionLabel(description: item?.description ?? "")
            updateGoalLabel(goal: goalByType ?? "")
            
            updateTypeImage()
            updateBackgroundImage()
        }
        
    }
    
    // MARK: - Lifetime
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDropShadows()
        setupGradient()
    }
    
    // MARK: - Cell Configuration
    
    func configure(with item: Item) {
        self.item = item
    }
    
}

// MARK: - Setup

extension GoalCollectionViewCell {
        
    private func setupDropShadows() {
        
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
        
    }
    
    private func setupGradient(colors: Gradient = .grey) {

        gradient.frame = bounds
        
        gradient.colors = [
            colors.start.cgColor,
            colors.end.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 1, y: 0.1)
        gradient.endPoint = CGPoint(x: 0.2, y: 1)
        
        containerView.layer.insertSublayer(gradient, at: 0)

    }
    
}

// MARK: - Computed Properties

extension GoalCollectionViewCell {
    
    private var goalByType: String? {
        
        guard
            let type = item?.type,
            let goal = item?.goal
        else {
            return nil
        }
        
        switch type {
        case .step:
            return "\(goal) steps"
        case .walking, .running:
            return "\(goal / 1000) km"
        }
        
    }
    
}

// MARK: - Update UI Components

extension GoalCollectionViewCell {
    
    private func updateTitleLabel(title: String, color: UIColor = Style.labelColor) {
        titleLabel.text = title
        titleLabel.textColor = color
    }
    
    private func updateDescriptionLabel(description: String, color: UIColor = Style.labelColor) {
        descriptionLabel.text = description
        descriptionLabel.textColor = Style.labelColor
    }
    
    private func updateGoalLabel(goal: String, color: UIColor = Style.labelColor) {
        goalLabel.text = goalByType
        goalLabel.textColor = color
    }
    
    private func updateGradient(with colors: Gradient) {
        
        gradient.frame = bounds
        
        gradient.colors = [
            colors.start.cgColor,
            colors.end.cgColor
        ]
    }
    
    private func updateTypeImage() {
        typeImageView.image = UIImage(named: (item?.type.rawValue)!)
    }
    
    private func updateBackgroundImage() {
        
        let noImage = {
            self.backgroundImageView.image = nil
            self.backgroundImageView.isHidden = true
        }
        
        guard let type = item?.type else {
            noImage()
            return
        }
        
        guard let image = UIImage(named: type.imageName) else {
            noImage()
            return
        }
        
        backgroundImageView.alpha = 0.25
        backgroundImageView.image = image
        backgroundImageView.isHidden = false
        
    }
    
}

// MARK: - Gradient

extension GoalCollectionViewCell {
    
    private enum Gradient: String {
        case red
        case blue
        case green
        case grey
        
        var start: UIColor {
            guard
                let color = UIColor(named: "gradient_\(self.rawValue)_start")
            else {
                return .lightGray
            }
            
            return color
        }
        
        var end: UIColor {
            guard
                let color = UIColor(named: "gradient_\(self.rawValue)_start")
            else {
                return .darkGray
            }
            
            return color
        }
        
        static func colors(for item: Item?) -> Gradient {
            
            guard let item = item else {
                return .grey
            }
            
            switch item.type {
            case .step:
                return .red
            case .walking:
                return .green
            case .running:
                return .blue
            }
        }
        
    }
    
}

// MARK: - Constants

extension GoalCollectionViewCell {
    
    private struct Style {
        static let labelColor = UIColor.white
    }
    
}
