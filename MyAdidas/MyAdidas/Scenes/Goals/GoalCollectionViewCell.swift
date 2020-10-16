//
//  GoalCollectionViewCell.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 01/10/2020.
//

import UIKit
import HealthKit

class GoalCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    
    // MARK: - Properties
    
    private var originalFrame: CGRect?
    private var originalCornerRadius: CGFloat?
    
    private let gradient = CAGradientLayer()
    
    private var item: Item? = nil {
        
        didSet {
            updateGradient(with: .colors(for: item))
            
            updateTitleLabel(title: item?.title ?? "")
            updateDescriptionLabel(description: item?.details ?? "")
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
        
        gradient.opacity = 0.8
        
        backgroundImageView.layer.insertSublayer(gradient, at: 0)
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
        
        backgroundImageView.image = image
        backgroundImageView.isHidden = false
        
    }
    
}

// MARK: - Appstore Card Animation

extension GoalCollectionViewCell {
    
    private var adjustContentOffset: CGFloat {
        guard let safeAreaTop = UIApplication.shared.keyWindow?.safeAreaInsets.top else {
            return 0
        }
        
        return safeAreaTop > 0 ? 0 : 64
    }

    func expand(in collectionView: UICollectionView) {
        
        originalFrame = frame
        originalCornerRadius = contentView.layer.cornerRadius
        
        contentView.layer.cornerRadius = 0
        
        frame = CGRect(
            x: 0,
            y: collectionView.contentOffset.y + adjustContentOffset,
            width: collectionView.frame.width,
            height: collectionView.frame.height
        )
        
        updateGradient(with: .colors(for: item))
        
        layoutIfNeeded()
    }

    func collapse() {
        
        contentView.layer.cornerRadius = originalCornerRadius ?? contentView.layer.cornerRadius
        
        frame = originalFrame ?? frame
        
        originalFrame = nil
        originalCornerRadius = nil
        
        updateGradient(with: .colors(for: item))
        
        layoutIfNeeded()
    }
    
    func hide(in collectionView: UICollectionView, frameOfSelectedCell: CGRect) {
        originalFrame = frame
        
        let currentY = frame.origin.y
        let newY: CGFloat
        
        if currentY < frameOfSelectedCell.origin.y {
            let offset = frameOfSelectedCell.origin.y - currentY
            newY = collectionView.contentOffset.y - offset
        } else {
            let offset = currentY - frameOfSelectedCell.maxY
            newY = collectionView.contentOffset.y + collectionView.frame.height + offset
        }
        
        frame.origin.y = newY
        
        layoutIfNeeded()
    }

    func show() {
        frame = originalFrame ?? frame
        
        originalFrame = nil
        
        layoutIfNeeded()
    }

}

// MARK: - Constants

extension GoalCollectionViewCell {
    
    private struct Style {
        static let labelColor = UIColor.white
    }
    
}
