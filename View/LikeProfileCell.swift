//
//  LikeProfileCell.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/05.
//

import UIKit

class LikeProfileCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var quickWordLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bloodLabel: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    var userData = [String: Any]()
    var uid = String()
    var profileImageViewString = String()
    
    static let identifire = "LikeProfileCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "LikeProfileCell", bundle: nil)
    }
    
    func configure(nameLabelString: String, ageLabelString: String, prefectureLabelString: String, bloodlabelString: String, genderLabelString: String, heightLabelString: String, workLabelString: String, quickWordLabelString: String, profileImageViewString: String, uid: String, userData: [String:Any]) {
        
        nameLabel.text = nameLabelString
        ageLabel.text = ageLabelString
        prefectureLabel.text = prefectureLabelString
        bloodLabel.text = bloodlabelString
        genderLabel.text = genderLabelString
        heightLabel.text = heightLabelString
        workLabel.text = workLabelString
        quickWordLabel.text = quickWordLabelString
        profileImageView.sd_setImage(with: URL(string: profileImageViewString), completed: nil)
        self.uid = uid
        self.userData = userData
        self.profileImageViewString = profileImageViewString
        
        Util.rectButton(button: likeButton)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: TODO: 無駄が多い
    @IBAction func likeAction(_ sender: Any) {
        
        let sendDBModel = SendDBModel()
        sendDBModel.sendToLikeFromLike(likeFlag: true, thisUserID: self.uid, matchedUserName: nameLabel.text!, matchedID: self.uid)
        
        sendDBModel.sendToMatchingList(thisUserID: self.uid, name: nameLabel.text!, age: ageLabel.text!, bloodType: bloodLabel.text!, prefecture: prefectureLabel.text!, height: heightLabel.text!, gender: genderLabel.text!, profile: "", profileImageString: profileImageViewString, uid: self.uid, quickWord: quickWordLabel.text!, work: workLabel.text!, userData: self.userData)
    }
    
}
