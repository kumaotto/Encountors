//
//  EditProfileViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/16.
//

import UIKit
import Firebase
import AVFoundation
import PKHUD

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var bloodTypeField: UITextField!
    @IBOutlet weak var prefectureField: UITextField!
    @IBOutlet weak var workField: UITextField!
    @IBOutlet weak var quickWordField: UITextField!
    
    @IBOutlet weak var InputProfileButton: UIButton!
    @IBOutlet weak var saveProfileButton: UIButton!
    
    var agePicker = UIPickerView()
    var heightPicker = UIPickerView()
    var prefecturePicker = UIPickerView()
    var bloodPicker = UIPickerView()
    var player = AVPlayer()
    
    var userData = [String: Any]()
    
    let loadDBModel = LoadDBModel()
    let sendDBModel = SendDBModel()
    
    var dataStringArray = [String]()
    var dataIntArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideo()
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        
        ageField.inputView = agePicker
        heightField.inputView = heightPicker
        bloodTypeField.inputView = bloodPicker
        prefectureField.inputView = prefecturePicker
        
        agePicker.delegate = self
        agePicker.dataSource = self
        heightPicker.delegate = self
        heightPicker.dataSource = self
        bloodPicker.delegate = self
        bloodPicker.dataSource = self
        prefecturePicker.delegate = self
        prefecturePicker.dataSource = self
        
        agePicker.tag = 1
        heightPicker.tag = 2
        bloodPicker.tag = 3
        prefecturePicker.tag = 4
        
        self.title = "プロフィール編集"
        
        Util.rectButton(button: InputProfileButton)
        Util.rectButton(button: saveProfileButton)
    
        // dataSet
        profileImageView.sd_setImage(with: URL(string: userData["profileImageString"] as! String), completed: nil)
        
        agePicker.selectRow(intSelectedCountIndex(18, selectedValue: userData["age"] as! String, dataArray: ([Int])(18...80)), inComponent: 0, animated: false)
        heightPicker.selectRow(intSelectedCountIndex(130, selectedValue: userData["height"] as! String, dataArray: ([Int])(130...200)), inComponent: 0, animated: false)
        bloodPicker.selectRow(stringSelectedCountIndex(selectedValue: userData["bloodType"] as! String, dataArray: ["A", "B", "O", "AB"]), inComponent: 0, animated: false)
        prefecturePicker.selectRow(stringSelectedCountIndex(selectedValue: userData["prefecture"] as! String, dataArray: Util.prefectures()), inComponent: 0, animated: false)
        
        nameField.text = userData["name"] as? String
        ageField.text = (userData["age"] as? String)! + "歳"
        heightField.text = (userData["height"] as? String)! + "cm"
        bloodTypeField.text = userData["bloodType"] as? String
        prefectureField.text = userData["prefecture"] as? String
        workField.text = userData["work"] as? String
        quickWordField.text = userData["quickWord"] as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    private func intSelectedCountIndex(_ value: Int, selectedValue: String, dataArray: [Int]) -> Int {
        let select = Int(selectedValue)
        
        if dataArray != [] {
            for index in dataArray {
                if index == select {
                    return index - value
                }
            }
        }
        return 0
        
    }
    
    private func stringSelectedCountIndex(selectedValue: String, dataArray: [String]) -> Int {
        var count: Int = 0
        
        for value in dataArray {
            count += 1
            if value == selectedValue {
                break
            }
        }
        return count - 1
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditProfole" {
            let next = segue.destination as? InputProfileTextViewController
            next?.profileText = userData["profile"] as? String
        }
    }
    
    @IBAction func editProfileText(_ sender: Any) {
        self.performSegue(withIdentifier: "toEditProfole", sender: nil)
    }
    
    
    @IBAction func saveProfile(_ sender: Any) {
        HUD.show(.progress)
        
        let manager = Manager.shared.profile
        
        if let range1 = self.ageField.text?.range(of: "歳") {
            self.ageField.text?.replaceSubrange(range1, with: "")
        }
        
        if let range2 = self.heightField.text?.range(of: "cm") {
            self.heightField.text?.replaceSubrange(range2, with: "")
        }
        
        let userData = UserDataModel(name: self.nameField.text, age: self.ageField.text, height: self.heightField.text, bloodType: self.bloodTypeField.text, prefecture: self.prefectureField.text, gender: userData["gender"] as? String, profile: manager, profileImageString: "", uid: Auth.auth().currentUser?.uid, quickWord: self.quickWordField.text, work: self.workField.text, date: Date().timeIntervalSince1970, onlineORNot: true, isVerified: userData["isVerified"] as? Bool, location: userData["location"] as? [Double], isSubscribe: userData["isSubscribe"] as? Bool,restOfLike: 0, restOfRead: 0)
        
        sendDBModel.profileSendDone = self
        sendDBModel.sendProfleData(userData: userData, profileImageData: (self.profileImageView.image?.jpegData(compressionQuality: 0.4))!)
        
    }
    
    
    // -------- protocol --------------------------------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 1:
            dataIntArray = ([Int])(18...80)
            return dataIntArray.count
        case 2:
            dataIntArray = ([Int])(130...200)
            return dataIntArray.count
        case 3:
            dataStringArray = ["A", "B", "O", "AB"]
            return dataStringArray.count
        case 4:
            dataStringArray = Util.prefectures()
            return dataStringArray.count
        default:
            return 0
        }
        
    }
    

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            ageField.text = String(dataIntArray[row]) + "歳"
            ageField.resignFirstResponder()
            break
        case 2:
            heightField.text = String(dataIntArray[row]) + "cm"
            heightField.resignFirstResponder()
            break
        case 3:
            bloodTypeField.text = dataStringArray[row] + "型"
            bloodTypeField.resignFirstResponder()
            break
        case 4:
            prefectureField.text = dataStringArray[row]
            prefectureField.resignFirstResponder()
            break
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return String(dataIntArray[row]) + "歳"
        case 2:
            return String(dataIntArray[row]) + "cm"
        case 3:
            return dataStringArray[row] + "型"
        case 4:
            return dataStringArray[row]
        default:
            return ""
        }
    }
    
    @IBAction func tapProfileImage(_ sender: Any) {
        openCamera()
    }
    
    func openCamera() {
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            present(cameraPicker, animated: true, completion: nil)
            
        } else {
            
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage
        {
            profileImageView.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func setUpVideo() {
        // ファイルパス
        player = AVPlayer(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/matchapp1-d8a78.appspot.com/o/Clouds%20-%2064767.mp4?alt=media&token=0b5961e0-a3d7-4f5c-8f4d-c2b3ccd35ebc")!)
        
        // AVPlayer用のレイヤーを生成
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.repeatCount = 0  // 無限ループ(終わったらまた再生のイベント後述)
        playerLayer.zPosition = -1   // 奥行
        view.layer.insertSublayer(playerLayer, at: 0)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (_) in
            
            self.player.seek(to: .zero)  //開始時間に戻す
            self.player.play()
            
        }
        
        self.player.play()
        
    }
    
}

extension EditProfileViewController: ProfileSendDone{
    func profileSendDone() {
        HUD.hide()
        self.navigationController?.popViewController(animated: true)
    }
}
