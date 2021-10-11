//
//  ProfileViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/02.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LikeSendDelegate, GetLikeCountProtocol {
    
    var userDataModel: UserDataModel?
    var ownUserData: UserDataModel?
    
    var likeCount = Int()
    var likeFlag = Bool()

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var loadDBModel = LoadDBModel()
    let sendDBModel = SendDBModel()
    let profileImageCellDelegate = ProfileImageCell()
    
    var items = UIMenu()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ProfileImageCell.nib(), forCellReuseIdentifier: ProfileImageCell.identifire)
        tableView.register(ProfileTextCell.nib(), forCellReuseIdentifier: ProfileTextCell.identifire)
        tableView.register(ProfileDetailCell.nib(), forCellReuseIdentifier: ProfileDetailCell.identifire)
        
        loadDBModel.getLikeCountProtocol = self
        loadDBModel.getOwnProfileDataProtocol = self
        sendDBModel.likeSendDelegate = self
        loadDBModel.loadLikeCount(uuid: (userDataModel?.uid)!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = false
        setprofileMenu()
        
        loadDBModel.loadUsersProfileWithoutGender(uid: Auth.auth().currentUser!.uid)
        sendDBModel.sendAshiato(partnerUserId: (userDataModel?.uid)!)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageCell.identifire, for: indexPath) as! ProfileImageCell
            cell.menuButton.menu = UIMenu(title: "", children: [items])
            cell.menuButton.showsMenuAsPrimaryAction = true
            cell.configure(profileImageViewString: (userDataModel?.profileImageString)!, nameLabelString: (userDataModel?.name)!, ageLabelString: (userDataModel?.age)!, prefectureLabelString: (userDataModel?.prefecture)!, quickWordLabelString: (userDataModel?.quickWord)!, likeLabelString: String(likeCount))
            return cell
        
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTextCell.identifire, for: indexPath) as! ProfileTextCell
            cell.profileTextView.text = userDataModel?.profile
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDetailCell.identifire, for: indexPath) as! ProfileDetailCell
            cell.configure(nameLabelString: (userDataModel?.name)!, ageLabelString: (userDataModel?.age)!, prefectureLabelString: (userDataModel?.prefecture)!, bloodlabelString: (userDataModel?.bloodType)!, genderLabelString: (userDataModel?.gender)!, heightLabelString: (userDataModel?.height)!, workLabelString: (userDataModel?.work)!)
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            return 450
        } else if indexPath.row == 2 {
            return 370
        } else if indexPath.row == 3 {
            return 480
        } else {
            return 1
        }
        
    }
    

    @IBAction func lileAction(_ sender: Any) {
        
        if (ownUserData?.restOfLike)! > 0 {
            
            if self.likeFlag == false {
                sendDBModel.sendToLike(likeFlag: true, objectUserID: (userDataModel?.uid)!, objectUserData: userDataModel!)
                sendDBModel.sendLikeItemCount(count: -1)
            } else {
                sendDBModel.sendToLike(likeFlag: false, objectUserID: (userDataModel?.uid)!, objectUserData: userDataModel!)
            }
            
        } else {
            let alert: UIAlertController = UIAlertController(title: "いいねが足りません", message:  "アイテム購入に移りますか？", preferredStyle:  UIAlertController.Style.alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default)
            
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) -> Void in
                
                let storeVC = self.storyboard?.instantiateViewController(identifier: "storeVC") as! PairsStoreViewController
                self.navigationController?.pushViewController(storeVC, animated: true)
                
            })
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func like() {
        Util.startAnimation(name: "heart", view: self.view)
    }
    
    func getLikeCount(likeCount: Int, likeFlag: Bool) {
        
        self.likeFlag = likeFlag
        self.likeCount = likeCount
        
        if self.likeFlag == false {
            likeButton.setImage(UIImage(named: "notLike"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "like"), for: .normal)
        }
        
        tableView.reloadData()
        
    }
    
    
    func setprofileMenu() {
        items = UIMenu(options: .displayInline, children: [
            UIAction(title: "お気に入りに追加する", image: nil, handler: { _ in
                print("お気に入りに追加するが押されました")
            }),
            UIAction(title: "違反報告する", image: nil, handler: {_ in
                self.performSegue(withIdentifier: "toReport", sender: nil)
            }),
            UIAction(title: "非表示・ブロックの設定", image: nil, handler: { _ in
                let alert: UIAlertController = UIAlertController(title: "ブロックしますか？", message:  "一度ブロックすると解除できません。", preferredStyle:  UIAlertController.Style.alert)
                
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default)
                
                let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) -> Void in
                    
                    self.sendDBModel.sendBlockUser(senderID: Auth.auth().currentUser!.uid, blockedUser: (self.userDataModel?.uid)!)
                    self.navigationController?.popToRootViewController(animated: true)
                    
                })
                
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
            }),
        ])
    }
}


extension ProfileViewController: GetOwnProfileDataProtocol {
    func getOwnProfileDataProtocol(userDataModel: UserDataModel) {
        self.ownUserData = userDataModel
    }
}
