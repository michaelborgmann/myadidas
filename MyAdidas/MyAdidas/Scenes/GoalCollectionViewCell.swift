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
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var goalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createDropShadows()
    }
    
    func configure(with item: Item) {
        createGradient()
        
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        typeImageView.image = UIImage(named: item.type.rawValue)
        
        if item.type == .step {
            goalLabel.text = "\(item.goal) steps"
        } else {
            goalLabel.text = "\(item.goal / 1000) km"
        }
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
    
    private func createGradient() {
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        
        gradient.colors = [
            UIColor(named: "gradient_start")?.cgColor,
            UIColor(named: "gradient_end")?.cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 1, y: 0.1)
        gradient.endPoint = CGPoint(x: 0.2, y: 1)
        
        containerView.layer.insertSublayer(gradient, at: 0)
    }
    
}
