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
    @IBOutlet weak var trophyImageView: UIImageView!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var activityRingView: ActivityRingView!
    @IBOutlet weak var workoutButton: UIButton!
    
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
            
            updatePointLabel()
            updateTrophyImage()
            
            updateActivityRing()
            
            updateWorkoutButton()
        }
    }
    
    private var progressToday: Int? = nil {
        didSet {
            
            guard
                let type = item?.type,
                let goal = progressToday
            else {
                detailsLabel.isHidden = true
                return
            }
            
            detailsLabel.isHidden = false
            
            switch type {
            case .step:
                detailsLabel.text = "You made \(goal) steps today."
            case .walking:
                detailsLabel.text = "You walked \(goal) km today."
            case .running:
                detailsLabel.text = "You runned \(goal) km today."
            }
            
            updatePointLabel()
            updateTrophyImage()
        }
    }
    
    // MARK: - Lifetime
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDropShadows()
        setupGradient()
    }
    
    // MARK: - Cell Configuration
    
    func configure(with item: Item, progressToday: Int?) {
        self.item = item
        self.progressToday = progressToday
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
            colors.light.cgColor,
            colors.dark.cgColor
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
    
    private var goalReached: Bool {
        guard
            let progress = progressToday,
            let goal = item?.goal
        else {
            return false
        }
        
        return progress >= goal ? true : false
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
            colors.light.cgColor,
            colors.dark.cgColor
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
    
    private func updatePointLabel(color: UIColor = Style.labelColor) {
        
        guard
            let points = item?.reward?.points,
            goalReached
        else {
            pointLabel.isHidden = true
            return
        }
        
        pointLabel.isHidden = false
        
        pointLabel.text = "\(points) Points"
        pointLabel.textColor = color
    }
    
    private func updateTrophyImage() {
        guard
            let imageName = item?.reward?.trophy.imageName,
            let image = UIImage(named: imageName),
            goalReached
        else {
            trophyImageView.isHidden = true
            return
        }
        
        trophyImageView.isHidden = false
        
        trophyImageView.image = image
    }
    
    
    private func updateActivityRing() {
        let colors = Gradient.colors(for: item)
        
        activityRingView.startColor = colors.dark
        activityRingView.endColor = colors.light
    }
    
    private func updateWorkoutButton() {
        
        let colors = Gradient.colors(for: item)
        workoutButton.setTitleColor(colors.dark, for: .normal)
        
        guard
            let type = item?.type,
            type != .step
        else {
            workoutButton.isHidden = true
            return
        }
        
        workoutButton.isHidden = false
        workoutButton.titleLabel?.text = "START"
        
    }
}

// MARK: - Appstore Card Animation

extension GoalCollectionViewCell {
    
    private var adjustContentOffset: CGFloat {
        let keyWindow = UIApplication.shared.windows
            .filter { $0.isKeyWindow }
            .first
            
        guard let safeAreaTop = keyWindow?.safeAreaInsets.top else {
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
    
    func hide(in collectionView: UICollectionView, selectedCellFrame: CGRect) {
        originalFrame = frame
        
        let currentY = frame.origin.y
        let newY: CGFloat
        
        if currentY < selectedCellFrame.origin.y {
            let offset = selectedCellFrame.origin.y - currentY
            newY = collectionView.contentOffset.y - offset
        } else {
            let offset = currentY - selectedCellFrame.maxY
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

// MARK: Activity Ring

extension GoalCollectionViewCell {
    
    var progress: Double {
        
        let zeroForDrawingProgress = 0.00001
        
        guard
            let goal = item?.goal,
            let progressToday = progressToday
        else {
            return zeroForDrawingProgress
        }
        
        let progressInPercent = Double(progressToday) / Double(goal)
        
        return progressInPercent > 0.0 ? progressInPercent : zeroForDrawingProgress
    }
}

// MARK: - Constants

extension GoalCollectionViewCell {
    
    private struct Style {
        static let labelColor = UIColor.white
    }
}
