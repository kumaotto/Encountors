//
//  StatusViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/13.
//

import UIKit
import Firebase

class StatusViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var verifyStatusField: UILabel!
    @IBOutlet weak var planStatusLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var selectPlanButton: UIButton!
    
    var verifiedImage = UIImage()
    var userData = [String: Any]()
    var userDataFromDB: UserDataModel?
    var userSubscribeData: SubscribeModel?
    
    let loadDBModel = LoadDBModel()
    let sendDBModel = SendDBModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "会員ステータス"
        
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        loadDBModel.getOwnProfileDataProtocol = self
        loadDBModel.getSubscribedDataProtocol = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        loadDBModel.loadUsersProfileWithoutGender(uid: Auth.auth().currentUser!.uid)
        
        if userDataFromDB?.isSubscribe == true {
            loadDBModel.loadUserSubscriptionData()
        }
        
        
        if (userData["isVerified"] as! Bool) == true {
            verifyStatusField.text = "本人確認済"
            Util.unableRectButton(button: verifyButton)
        } else {
            verifyStatusField.text = "未確認"
            Util.rectButton(button: verifyButton)
        }
        
        if userDataFromDB?.isSubscribe == true {
            planStatusLabel.text = userSubscribeData?.type
            Util.unableRectButton(button: selectPlanButton)
        } else {
            planStatusLabel.text = "未加入"
            Util.orangeRectButton(button: selectPlanButton)
        }
        
    }
    
    
    @IBAction func verified(_ sender: Any) {
        openCamera()
    }
    
    @IBAction func selectPlan(_ sender: Any) {
        let selectPlanVC = self.storyboard?.instantiateViewController(identifier: "selectPlanVC") as! SelectPlanViewController
        self.navigationController?.pushViewController(selectPlanVC, animated: true)
    }
    
    
    func openCamera() {
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            present(cameraPicker, animated: true, completion: nil)
            
        } else {}

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage {
            self.verifiedImage = pickedImage
            picker.dismiss(animated: true, completion: nil)
            
            submitVerifyImage()
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func submitVerifyImage() {
        sendDBModel.sendVerifiedImage(senderID: Auth.auth().currentUser!.uid, verifiedImage: (self.verifiedImage.jpegData(compressionQuality: 0.4))!, userData: self.userData)
        
        let alert: UIAlertController = UIAlertController(title: "送信完了", message:  "本人確認書類を送信しました。", preferredStyle:  UIAlertController.Style.alert)
        
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
}


extension StatusViewController: GetOwnProfileDataProtocol {
    func getOwnProfileDataProtocol(userDataModel: UserDataModel) {
        userDataFromDB = userDataModel
        self.viewWillAppear(true)
    }
}


extension StatusViewController: GetSubscribedDataProtocol {
    func GetSubscribedDataProtocol(subscribeData: SubscribeModel) {
        self.userSubscribeData = subscribeData
    }
}
