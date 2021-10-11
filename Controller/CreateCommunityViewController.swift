//
//  CreateCommunityViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/18.
//

import UIKit
import PKHUD

class CreateCommunityViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var communityImageView: UIImageView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var imageViewText: UILabel!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    var categoryPicker = UIPickerView()
    
    var categoryArray = ["音楽", "映画", "芸能人・テレビ", "ゲーム", "本・マンガ", "アート"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "コミュニティ作成"
        self.createButton.isEnabled = false
        
        categoryField.inputView = categoryPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    @IBAction func create(_ sender: Any) {
        HUD.show(.progress)
        
        let sendDBModel = SendDBModel()
        sendDBModel.communityCreateDone = self
        sendDBModel.sendNewCommunity(communityName: nameField.text!, communityCategory: categoryField.text!, communityImageData: (communityImageView.image?.jpegData(compressionQuality: 0.4))!)

    }
    
    @IBAction func tapImageSelector(_ sender: Any) {
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

        } else {}

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let pickedImage = info[.editedImage] as? UIImage
        {
            communityImageView.image = pickedImage
            cameraImage.isHidden = true
            imageViewText.isHidden = true
            
            if !(nameField.text!.isEmpty) && !(categoryField.text!.isEmpty) {
                self.createButton.isEnabled = true
            }
            
            picker.dismiss(animated: true, completion: nil)
        }

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}



extension CreateCommunityViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        categoryField.text = categoryArray[row]
        categoryField.resignFirstResponder()
        
        if !(nameField.text!.isEmpty) && communityImageView.image != nil {
            self.createButton.isEnabled = true
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row]
    }
}

extension CreateCommunityViewController: CommunityCreateDone {
    func communityCreateDone() {
        HUD.hide()
        self.navigationController?.popViewController(animated: true)
    }
    
}
