//
//  CommunityDetai;ViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/19.
//

import UIKit
import Firebase

class CommunityDetailViewController: UIViewController, ProfileSendDone {

    @IBOutlet weak var communityImageView: UIImageView!
    @IBOutlet weak var communityName: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var communityDataModel: CommunityDataModel?
    var userDataModelArray = [UserDataModel]()
    var userData: [String: Any] = [:]
    var loadDBModel = LoadDBModel()
    var sendDBModel = SendDBModel()
    var isJoined = Bool()
    
    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 2.0, bottom: 2.0, right: 2.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        communityImageView.sd_setImage(with: URL(string: (communityDataModel?.image)!), completed: nil)
        communityName.text = communityDataModel?.name
        communityImageView.layer.cornerRadius = communityName.frame.size.width * 0.1
        communityImageView.clipsToBounds = true
        Util.rectButton(button: self.joinButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userData = KeyChainConfig.getKeyArrayData(key: "userData")
        
        loadDBModel.getProfileUserDataProtocol = self
        loadDBModel.laodCommunityMenberListData(categoryID: (communityDataModel?.categoryID)!, communityID: (communityDataModel?.uid)!)
        
    }
    
    
    @IBAction func join(_ sender: Any) {
        
        let userData = UserDataModel(
            name: userData["name"] as? String,
            age: userData["age"] as? String,
            height: userData["height"] as? String,
            bloodType: userData["bloodType"] as? String,
            prefecture: userData["prefecture"] as? String,
            gender: userData["gender"] as? String,
            profile: userData["profile"] as? String,
            profileImageString: userData["profileImageString"] as? String,
            uid: Auth.auth().currentUser?.uid,
            quickWord: userData["quickWord"] as? String,
            work: userData["work"] as? String,
            date: Date().timeIntervalSince1970,
            onlineORNot: true,
            isVerified: userData["isVerified"] as? Bool,
            location: [0.0, 0.0],
            isSubscribe: self.userData["isSubscribe"] as? Bool,
            restOfLike: 0,
            restOfRead: 0)
        
        if self.isJoined == false {
            
            self.isJoined = true
            Util.grayRectButton(button: self.joinButton)

            sendDBModel.profileSendDone = self
            sendDBModel.sendNewCommunityMemberData(categoryID: (communityDataModel?.categoryID)!, communityID: (communityDataModel?.uid)!, userData: userData, isJoined: true)
            
        } else {
            
            self.isJoined = false
            Util.rectButton(button: self.joinButton)
            
            sendDBModel.profileSendDone = self
            sendDBModel.sendNewCommunityMemberData(categoryID: (communityDataModel?.categoryID)!, communityID: (communityDataModel?.uid)!, userData: userData, isJoined: false)
            
        }
        
    }
    
    
    func profileSendDone() {
        self.collectionView.reloadData()
    }

}



extension CommunityDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userDataModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityDetailCell", for: indexPath)
        
        cell.layer.borderWidth = 0.0
        cell.layer.masksToBounds = true
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.sd_setImage(with: URL(string: userDataModelArray[indexPath.row].profileImageString!), completed: nil)
        imageView.layer.cornerRadius = imageView.frame.width/2
        
        let ageLabel = cell.contentView.viewWithTag(2) as! UILabel
        ageLabel.text = userDataModelArray[indexPath.row].age
        
        let prefectureLabel = cell.contentView.viewWithTag(3) as! UILabel
        prefectureLabel.text = userDataModelArray[indexPath.row].prefecture
        
        let onlineMarkImageView = cell.contentView.viewWithTag(4) as! UIImageView
        onlineMarkImageView.layer.cornerRadius = onlineMarkImageView.frame.width/2
        
        if userDataModelArray[indexPath.row].onlineORNot == true {
            onlineMarkImageView.image = UIImage(named: "online")
        } else {
            onlineMarkImageView.image = UIImage(named: "offLine")
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
}


extension CommunityDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        let availablewidth = view.frame.width - paddingSpace
        let widthPerItem = availablewidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem + 42)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
}


extension CommunityDetailViewController: GetProfileDataProtocol {
    func getProfileData(userDataModelArray: [UserDataModel]) {
        self.userDataModelArray = userDataModelArray
        
        for user in userDataModelArray {
            if user.uid! == Auth.auth().currentUser!.uid {
                self.isJoined = true
                Util.grayRectButton(button: self.joinButton)
                self.joinButton.setTitle("参加中", for: .normal)
            } else {
                self.isJoined = false
                Util.rectButton(button: self.joinButton)
                self.joinButton.setTitle("参加", for: .normal)
            }
        }
        
        self.collectionView.reloadData()
    }
}
