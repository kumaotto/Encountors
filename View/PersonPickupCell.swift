//
//  PersonPickupCell.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/20.
//

import UIKit
import VerticalCardSwiper

class PersonPickupCell: CardCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var prefecureLabel: UILabel!
    @IBOutlet weak var quickWordLabel: UILabel!
    @IBOutlet weak var isOnlineLabel: UIImageView!
    @IBOutlet weak var textBackgroundView: UIView!
    
    static let identifire = "PersonPickupCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "PersonPickupCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib() 
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width * 0.1
        textBackgroundView.layer.cornerRadius = textBackgroundView.frame.width * 0.1
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
    }

    override func layoutSubviews() {
        self.layer.cornerRadius = 12
        super.layoutSubviews()
    }
    
    
    
}
