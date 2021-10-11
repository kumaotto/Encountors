//
//  MyPageViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/12.
//

import UIKit
import Firebase
import FirebaseAuthUI

class MyPageViewController: UIViewController, FUIAuthDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var goodPromote: UITextField!
    @IBOutlet weak var restOfLikeLabel: UILabel!
    @IBOutlet weak var restOfReadLabel: UILabel!
    @IBOutlet weak var restOfLikeView: UIView!
    @IBOutlet weak var restOfReadView: UIView!
    
    let loadDBModel = LoadDBModel()
    var userData = [String:Any]()
    var userDataFromDB: UserDataModel?
    var pickupUserData = [UserDataModel]()
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDBModel.getProfileUserDataProtocol = self
        loadDBModel.getOwnProfileDataProtocol = self
        
        authUI.delegate = self
        
        goodPromote.borderStyle = .none
        restOfLikeView.layer.cornerRadius = 20
        restOfReadView.layer.cornerRadius = 20
        editProfileButton.setTitleColor(UIColor(hex: "#42c4cc"), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        loadDBModel.loadUsersProfileWithoutGender(uid: Auth.auth().currentUser!.uid)
        
        let profileImageString = userData["profileImageString"] as! String
        self.profileImage.sd_setImage(with: URL(string: profileImageString), completed: nil)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width/2
        self.nameLabel.text = (userData["name"] as! String)
        
        if userDataFromDB != nil {
            restOfLikeLabel.text = String((userDataFromDB?.restOfLike)!)
            restOfReadLabel.text = String((userDataFromDB?.restOfRead)!)
        }
        
    }
    
    
    
    @IBAction func moveToContact(_ sender: Any) {
        self.performSegue(withIdentifier: "toContact", sender: nil)
    }
    
    @IBAction func moveToStatus(_ sender: Any) {
        self.performSegue(withIdentifier: "toStatus", sender: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title: "ログアウト", message:  "本当にログアウトしますか？", preferredStyle:  UIAlertController.Style.alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default)
        
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
            do { try Auth.auth().signOut() }
            catch { print("already logged out") }
            
            let UINavigationController = self.tabBarController?.viewControllers?[0];
            self.tabBarController?.selectedViewController = UINavigationController;
        })
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func prepareForPickup(_ sender: Any) {
        loadDBModel.loadRandomUserProfile(max: 5, gender: userData["gender"] as! String)
    }
    
    @IBAction func editProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "toEditProfile", sender: nil)
    }
    
    @IBAction func moveToStore(_ sender: Any) {
        let storeVC = storyboard?.instantiateViewController(identifier: "storeVC") as! PairsStoreViewController
        navigationController?.pushViewController(storeVC, animated: true)
    }
    
    
}



extension MyPageViewController {
    func moveToPickupView() {
        let pickupVC = self.storyboard?.instantiateViewController(identifier: "pickupVC") as! PickupViewController
        pickupVC.userDataModelArray = pickupUserData
        
        let navigationController = UINavigationController(rootViewController: pickupVC)
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
}


extension MyPageViewController: GetProfileDataProtocol {
    func getProfileData(userDataModelArray: [UserDataModel]) {
        self.pickupUserData = userDataModelArray
        moveToPickupView()
    }
}

extension MyPageViewController: GetOwnProfileDataProtocol {
    func getOwnProfileDataProtocol(userDataModel: UserDataModel) {
        userDataFromDB = userDataModel
        self.viewWillAppear(true)
    }
}
