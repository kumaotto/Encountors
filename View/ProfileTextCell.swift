//
//  ProfileTextCell.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/05.
//

import UIKit

class ProfileTextCell: UITableViewCell {
    
    @IBOutlet weak var profileTextView: UITextView!
    static let identifire = "ProfileTextCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ProfileTextCell", bundle: nil)
    }
    
    func configure(profileTextViewString: String) {
        profileTextView.text = profileTextViewString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
