//
//  GoalCollectionViewCell.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 01/10/2020.
//

import UIKit

@IBDesignable
class GoalCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    
    private let labelColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createDropShadows()
    }
    
    private func goalString(for item: Item) -> String? {
        switch item.type {
        case .step:
            return "\(item.goal) steps"
        case .walking, .running:
            return "\(item.goal / 1000) km"
        }
    }
    
    func configure(with item: Item) {
        let colors = GradientColors.itemColor(for: item)
        createGradient(with: colors)
        
        titleLabel.text = item.title
        titleLabel.textColor = labelColor
        
        descriptionLabel.text = item.description
        descriptionLabel.textColor = labelColor
        
        goalLabel.text = goalString(for: item)
        goalLabel.textColor = labelColor
        
        typeImageView.image = UIImage(named: item.type.rawValue)
    }
    
    private func createDropShadows() {
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
    }
    
    private func createGradient(with colors: GradientColors) {
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        
        gradient.colors = [
            UIColor(named: colors.start)?.cgColor,
            UIColor(named: colors.end)?.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 1, y: 0.1)
        gradient.endPoint = CGPoint(x: 0.2, y: 1)
        
        containerView.layer.insertSublayer(gradient, at: 0)
    }
    
}
    
extension GoalCollectionViewCell {
    
    enum GradientColors {
        case red
        case blue
        
        var start: String {
            switch self {
            case .red:
                return "gradient_red_start"
            case .blue:
                return "gradient_blue_start"
            }
        }
        
        var end: String {
            switch self {
            case .red:
                return "gradient_red_end"
            case .blue:
                return "gradient_blue_end"
            }
        }
        
        static func itemColor(for item: Item) -> GradientColors {
            switch item.type {
            case .step:
                return .red
            case .walking, .running:
                return .blue
            }
        }
        
    }
    
}
