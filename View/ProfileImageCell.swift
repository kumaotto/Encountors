//
//  ProfileImageCell.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/05.
//

import UIKit
import SDWebImage

protocol ProfileImageCellDelegate: AnyObject {
    func tapMenu()
}

class ProfileImageCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var quickWordLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    var profileImageCellDelegate: ProfileImageCellDelegate?
    
    static let identifire = "ProfileImageCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ProfileImageCell", bundle: nil)
    }
    
    func configure(profileImageViewString: String, nameLabelString: String, ageLabelString: String, prefectureLabelString: String, quickWordLabelString: String, likeLabelString: String) {
        
        profileImageView.sd_setImage(with: URL(string: profileImageViewString), completed: nil)
        nameLabel.text = nameLabelString
        ageLabel.text = ageLabelString
        prefectureLabel.text = prefectureLabelString
        quickWordLabel.text = quickWordLabelString
        likeLabel.text = likeLabelString
        
    }
    
    // viewdidloadの役割
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
