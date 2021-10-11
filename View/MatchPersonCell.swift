//
//  MatchPersonCell.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/06.
//

import UIKit

class MatchPersonCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    
    static let identifire = "MatchPersonCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "MatchPersonCell", bundle: nil)
    }
    
    func configure(nameLabelString: String, ageLabelString: String, workLabelString: String, profileImageViewString: String) {
        
        nameLabel.text = nameLabelString
        ageLabel.text = ageLabelString
        workLabel.text = workLabelString
        profileImageView.sd_setImage(with: URL(string: profileImageViewString), completed: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
