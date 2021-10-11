//
//  InputProfileTextViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/07/30.
//

import UIKit

class InputProfileTextViewController: UIViewController {
    
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    var profileText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if profileText != nil {
            self.profileTextView.text = profileText
        }

        profileTextView.layer.borderWidth = 0.5
        Util.rectButton(button: doneButton)
    }
    
    
    @IBAction func done(_ sender: Any) {
        
        let manager = Manager.shared
                
        manager.profile = profileTextView.text
        dismiss(animated: true, completion: nil)
        
    }
    

}
