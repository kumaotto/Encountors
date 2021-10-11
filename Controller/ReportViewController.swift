//
//  ReportViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/13.
//

import UIKit
import Firebase

class ReportViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    var sendDBModel = SendDBModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        Util.unableRectButton(button: sendButton)
    }
    
    
    @objc func textViewDidChange(_ textView: UITextView) {
        let textNum = 200 - (textView.text.count)
        
        // MARK: バリデーションのメッセージちゃんとする
        if textNum <= 0 && textNum >= -800 {
            textCount.text = "OK"
            Util.rectButton(button: sendButton)
        } else {
            textCount.text = String(textNum)
            Util.unableRectButton(button: sendButton)
        }
    }
    
    
    @IBAction func sendText(_ sender: Any) {
        
        sendDBModel.sendReportWithPersonID(text: textView.text, id: Auth.auth().currentUser!.uid)
        
        let alert: UIAlertController = UIAlertController(title: "送信完了", message:  "違反内容を送信しました。", preferredStyle:  UIAlertController.Style.alert)
        
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)

    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
