//
//  CreateNewUserViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/07/30.
//

import UIKit
import Firebase
import AVFoundation
import PKHUD

class CreateNewUserViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProfileSendDone {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var quickWordTextField: UITextField!
    
    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var player = AVPlayer()
    
    var agePicker = UIPickerView()
    var heightPicker = UIPickerView()
    var prefecturePicker = UIPickerView()
    var bloodPicker = UIPickerView()
    
    var gender = String()
    
    var dataStringArray = [String]()
    var dataIntArray = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        textField2.inputView = agePicker
        textField3.inputView = heightPicker
        textField4.inputView = bloodPicker
        textField5.inputView = prefecturePicker
        
        // UIPickerViewDelegateメソッドが実行されるタイミングを誰が担うのか？
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
        
        gender = "男性"
        
        Util.rectButton(button: toProfileButton)
        Util.rectButton(button: doneButton)
        
        setUpVideo()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // 行数のみ規定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 1:
            dataIntArray = ([Int])(18...80)
            return dataIntArray.count
        case 2:
            dataIntArray = ([Int])(130...220)
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
    
    // 多分上だと複雑になるから分けている？
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        switch pickerView.tag {
        case 1:
            textField2.text = String(dataIntArray[row]) + "歳"
            textField2.resignFirstResponder()
            break
        case 2:
            textField3.text = String(dataIntArray[row]) + "cm"
            textField3.resignFirstResponder()
            break
        case 3:
            textField4.text = dataStringArray[row] + "型"
            textField4.resignFirstResponder()
            break
        case 4:
            textField5.text = dataStringArray[row]
            textField5.resignFirstResponder()
            break
        default:
            break
        }
    
    }
    
    // 行に記載する文字列
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
    
    @IBAction func genderSwitch(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            gender = "男性"
        } else {
            gender = "女性"
        }
        
    }
    
    @IBAction func toProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    
    @IBAction func done(_ sender: Any) {
        HUD.show(.progress)
        // save to firebase
        let manager = Manager.shared.profile
            
        if let range1 = self.textField2.text?.range(of: "歳") {
            self.textField2.text?.replaceSubrange(range1, with: "")
        }
        
        if let range2 = self.textField3.text?.range(of: "cm") {
            self.textField3.text?.replaceSubrange(range2, with: "")
        }
        
        let userData = UserDataModel(
            name: self.textField1.text,
            age: self.textField2.text,
            height: self.textField3.text,
            bloodType: self.textField4.text,
            prefecture: self.textField5.text,
            gender: self.gender,
            profile: manager,
            profileImageString: "",
            uid: Auth.auth().currentUser?.uid,
            quickWord: self.quickWordTextField.text,
            work: self.textField6.text,
            date: Date().timeIntervalSince1970,
            onlineORNot: true,
            isVerified: false,
            location: [0.0, 0.0],
            isSubscribe: false,
            restOfLike: 0,
            restOfRead: 0)
        
        let sendDBModel = SendDBModel()
        sendDBModel.profileSendDone = self
        sendDBModel.sendProfleData(userData: userData, profileImageData: (self.imageView.image?.jpegData(compressionQuality: 0.4))!)
        
    }
    

    func profileSendDone() {
        HUD.hide()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func tap(_ sender: Any) {
        // open camera or albam
        openCamera()
    }
    
    func openCamera() {
        // シュミレータはカメラ起動しないため、.cameraはなし
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // カメラが利用可能かチェック
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
//            cameraPicker.showsCameraControls = true
            present(cameraPicker, animated: true, completion: nil)
            
        } else {
            
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage
        {
            imageView.image = pickedImage
            // close
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    // 撮影がキャンセルされた時によばれる
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
        
        // 終わったらまた再生
        // AVPlayerItemDidPlayToEndTimeで終了のタイミングを検知
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { (_) in
            
            self.player.seek(to: .zero)  //開始時間に戻す
            self.player.play()
            
        }
        
        self.player.play()
        
    }
    
}
