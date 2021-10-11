//
//  ContactViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/13.
//

import UIKit
import Firebase

class ContactViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var contactTextView: PlaceHolderTextView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var categoryPicker = UIPickerView()
    var dataStringArray = [String]()
    
    var sendDBModel = SendDBModel()
    
    let contactCategoryArray = ["お支払いについて", "不快なユーザがいる", "技術的な問題について", "その他"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "お問い合わせ"
        
        categoryField.inputView = categoryPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        contactTextView.delegate = self
        categoryPicker.tag = 1
        
        Util.unableRectButton(button: sendButton)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if contactTextView.text.count <= 1000 && contactTextView.text.count != 0 && categoryField.text != "タップして選択" {
            Util.rectButton(button: sendButton)
        } else {
            Util.unableRectButton(button: sendButton)
        }
    }
    
    @IBAction func sendContact(_ sender: Any) {
        
        sendDBModel.sendContactData(category: categoryField.text!, text: contactTextView.text, email: emailField.text!, id: Auth.auth().currentUser!.uid)
        
        let alert: UIAlertController = UIAlertController(title: "送信完了", message:  "お問い合わせ内容を送信しました。", preferredStyle:  UIAlertController.Style.alert)
        
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}



extension ContactViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch categoryPicker.tag {
        case 1:
            dataStringArray = contactCategoryArray
            return dataStringArray.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            categoryField.text = dataStringArray[row]
            categoryField.resignFirstResponder()
            
            if contactTextView.text.count <= 1000 && contactTextView.text.count != 0
            {
                self.sendButton.isEnabled = true
            } else {
                self.sendButton.isEnabled = false
            }
            
            break
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return dataStringArray[row]
        default:
            return ""
        }
    }
    
    
}
