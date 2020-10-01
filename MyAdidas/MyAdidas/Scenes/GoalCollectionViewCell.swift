//
//  GoalCollectionViewCell.swift
//  MyAdidas
//
//  Created by Michael Borgmann on 01/10/2020.
//

import UIKit

class GoalCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var goalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with item: Item) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        typeImageView.image = UIImage(named: item.type.rawValue)
        
        if item.type == .step {
            goalLabel.text = "\(item.goal) steps"
        } else {
            goalLabel.text = "\(item.goal / 1000) km"
        }
    }

}
