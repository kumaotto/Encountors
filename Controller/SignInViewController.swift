//
//  SignInViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseEmailAuthUI
import FirebaseAuthUI
import AVFoundation

class SignInViewController: UIViewController {
    
    @IBOutlet weak var startWithEmailButton: UIButton!
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers = [FUIEmailAuth()]
    
    let loadDBModel = LoadDBModel()
    var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI.delegate = self
        authUI.providers = providers
        Auth.auth().languageCode = "jp"

        Util.rectButton(button: startWithEmailButton)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        setUpVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let bundlePath = Bundle.main.path(forResource: "FirebaseAuthUI", ofType: "strings") {
            let bundle = Bundle(path: bundlePath)
            authUI.customStringsBundle = bundle
        }
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @IBAction func startWithEmail(_ sender: Any) {
        self.login()
    }

}



extension SignInViewController: FUIAuthDelegate {
    
    func login() {
        let authViewController = authUI.authViewController()
        authViewController.navigationController?.navigationBar.isHidden = false
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error == nil {
            
            FirebaseAuth.Auth.auth().addStateDidChangeListener { auth, user in
                self.dismiss(animated: true, completion: nil)
            }
            
        } else {
            print(error?.localizedDescription as Any)
        }
    }
    
}


extension SignInViewController {
    func setUpVideo() {
        // ファイルパス
        player = AVPlayer(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/matchapp2-31bc7.appspot.com/o/Cloud.mp4?alt=media&token=fd24277c-1a2d-4ab0-a878-5475a32e2fbd")!)
        
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
