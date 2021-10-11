//
//  ProfileDetailCell.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/05.
//

import UIKit

class ProfileDetailCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bloodLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    
    static let identifire = "ProfileDetailCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ProfileDetailCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(nameLabelString: String, ageLabelString: String, prefectureLabelString: String, bloodlabelString: String, genderLabelString: String, heightLabelString: String, workLabelString: String) {
        
        nameLabel.text = nameLabelString
        ageLabel.text = ageLabelString
        prefectureLabel.text = prefectureLabelString
        bloodLabel.text = bloodlabelString
        genderLabel.text = genderLabelString
        heightLabel.text = heightLabelString
        workLabel.text = workLabelString
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
