//
//  HumansViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/02.
//

import UIKit
import Firebase
import SDWebImage
import CoreLocation


class HumansViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var ashiatoButton: UIButton!
    
    var searchORNot = Bool()
    var loadedLikeArray = [String]()
    var loadedBlockArray = [String]()
    var blcokedListArray = [String]()
    var userData = [String: Any]()
    let loadDBModel = LoadDBModel()
    let sendDBModel = SendDBModel()
    var locationManager = CLLocationManager()

    let sectionInsets = UIEdgeInsets(top: 10.0, left: 2.0, bottom: 2.0, right: 2.0)
    
    let itemsPerRow: CGFloat = 2
    var userDataModelArray = [UserDataModel]()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        Util.rectButton(button: searchButton)
        Util.rectButton(button: ashiatoButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillEnterForeground(_:)), name: UIScene.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIScene.didEnterBackgroundNotification, object: nil)
        
        
        if Auth.auth().currentUser?.uid != nil && self.searchORNot == false && userData.count != 0 {
                        
            collectionView.delegate = self
            collectionView.dataSource = self
                        
            loadDBModel.getProfileUserDataProtocol = self
            loadDBModel.getLikeDataProtocol = self
            loadDBModel.loadUsersProfile(gender: userData["gender"] as! String)
            loadDBModel.loadRandomUserProfile(max: 5, gender: userData["gender"] as! String)
            
            loadDBModel.loadLikeList()
            
            self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").document(Auth.auth().currentUser!.uid).setData (
                ["gender": userData["gender"] as Any, "uid": userData["uid"] as Any,"age": userData["age"] as Any,"height": userData["height"] as Any,"profileImageString": userData["profileImageString"] as Any,"prefecture": userData["prefecture"] as Any,"name": userData["name"] as Any,"quickWord": userData["quickWord"] as Any,"profile": userData["profile"] as Any,"bloodType": userData["bloodType"] as Any, "work": userData["work"] as Any, "isVerified": userData["isVerified"] as Any]
            )
            
            loadDBModel.LoadMatchingPersonData()
            
        } else if Auth.auth().currentUser?.uid != nil && self.searchORNot == true && userData.count != 0 {
            
            collectionView.reloadData()
            
        } else if Auth.auth().currentUser?.uid != nil && userData.count == 0 {
            let createUserVC = self.storyboard?.instantiateViewController(identifier: "createUserVC") as! CreateNewUserViewController
            self.navigationController?.present(createUserVC, animated: true, completion: nil)
        } else {
            let signinVC = self.storyboard?.instantiateViewController(identifier: "signInVC") as! SignInViewController
            self.navigationController?.present(signinVC, animated: true, completion: nil)
        }
    }
    
    @objc func viewWillEnterForeground(_ notification: NSNotification?) {
        locationManager.requestLocation()
        Util.updateOnlineStatus(onlineORNot: true)
    }
    
    @objc func didEnterBackground(_ notification: NSNotification?) {
        Util.updateOnlineStatus(onlineORNot: false)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userDataModelArray.count
    }
    
    // スクリーンサイズに応じてセルのサイズを変える
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        let availablewidth = view.frame.width - paddingSpace
        let widthPerItem = availablewidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem + 42)
    }
    
    // setting margin
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
        
    }
    
    // 行間
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // セルを構築して返す
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        cell.layer.borderWidth = 0.0
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.4
        cell.layer.masksToBounds = true
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.sd_setImage(with: URL(string: userDataModelArray[indexPath.row].profileImageString!), completed: nil)
        imageView.layer.cornerRadius = imageView.frame.width/2
        
        let ageLabel = cell.contentView.viewWithTag(2) as! UILabel
        ageLabel.text = userDataModelArray[indexPath.row].age
        
        let prefecureLabel = cell.contentView.viewWithTag(3) as! UILabel
        prefecureLabel.text = userDataModelArray[indexPath.row].prefecture
        
        let onlineMarkImageView = cell.contentView.viewWithTag(4) as! UIImageView
        onlineMarkImageView.layer.cornerRadius = onlineMarkImageView.frame.width / 2
        
        if userDataModelArray[indexPath.row].onlineORNot == true {
            onlineMarkImageView.image = UIImage(named: "online")
        } else {
            onlineMarkImageView.image = UIImage(named: "offLine")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let profileVC = self.storyboard?.instantiateViewController(identifier: "profileVC") as! ProfileViewController
        profileVC.userDataModel = userDataModelArray[indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    @IBAction func search(_ sender: Any) {
        performSegue(withIdentifier: "searchVC", sender: nil)
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchVC" {
            let userData = KeyChainConfig.getKeyArrayData(key: "userData")
            
            // 遷移先のControllerを取得
            let searchVC = segue.destination as? SearchViewController
            searchVC?.gender = userData["gender"] as! String
            
            // 遷移先のpropetyに処理ごと直す
            searchVC?.resultHandler = { userDataModelArray, searchDone in
                
                self.searchORNot = searchDone
                self.userDataModelArray = userDataModelArray
                self.collectionView.reloadData()
                
            }
        }
    }
    
    func topViewController(controller: UIViewController?) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }

}


extension HumansViewController: GetProfileDataProtocol, GetBlockedListProtocol {
    
    func getProfileData(userDataModelArray: [UserDataModel]) {
        
        var deleteArray = [Int]()
        var count = 0
        self.loadDBModel.getBlockedListProtocol = self
        self.loadDBModel.loadBlockedList()
        
        loadedLikeArray = []
        self.userDataModelArray = userDataModelArray
        loadedLikeArray = KeyChainConfig.getKeyArrayListData(key: "ownLikeList")
        loadedBlockArray = KeyChainConfig.getKeyArrayListData(key: "blockList")
        
        for i in 0..<self.userDataModelArray.count {
            
            if loadedLikeArray.contains(self.userDataModelArray[i].uid!) == true {
                deleteArray.append(i)
            }
            
            if loadedBlockArray.contains(self.userDataModelArray[i].uid!) == true {
                deleteArray.append(i)
            }
            
            if self.blcokedListArray.contains(self.userDataModelArray[i].uid!) == true {
                deleteArray.append(i)
            }
            
        }
        
        for i in 0..<deleteArray.count {
            self.userDataModelArray.remove(at: deleteArray[i] - count)
            count += 1
        }
        
        self.collectionView.reloadData()
    }
    
    
    func getBlockedListProtocol(uid: [String]) {
        
        self.blcokedListArray = uid
        
        var deleteArray = [Int]()
        var count = 0
        
        for i in 0..<self.userDataModelArray.count {
            
            if self.blcokedListArray.contains(self.userDataModelArray[i].uid!) == true {
                deleteArray.append(i)
            }
            
        }
        
        for i in 0..<deleteArray.count {
            self.userDataModelArray.remove(at: deleteArray[i] - count)
            count += 1
        }
        
        self.collectionView.reloadData()
    }

}


extension HumansViewController: GetLikeDataProtocol {
    // 自分にLikeした人を取ってくる
    func getLikeDataProtocol(userDataModelArray: [UserDataModel]) {
        var count = 0
        
        var likeArray = [Int]()
        
        // 現在の配列に同じ要素があればその要素を配列から削除
        for i in 0..<userDataModelArray.count {
            if self.userDataModelArray.contains(userDataModelArray[i]) == true {
                likeArray.append(i)
            }
        }
        
        for i in 0..<likeArray.count {
            self.userDataModelArray.remove(at: likeArray[i] - count)
            count += 1
        }
        
        self.collectionView.reloadData()
    }
}


extension HumansViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        
        let latitude = loc.coordinate.latitude
        let longitude = loc.coordinate.longitude
        
        let userData = UserDataModel(
            name: self.userData["name"] as? String,
            age: self.userData["age"] as? String,
            height: self.userData["height"] as? String,
            bloodType: self.userData["bloodType"] as? String,
            prefecture: self.userData["prefecture"] as? String,
            gender: self.userData["gender"] as? String,
            profile: self.userData["profile"] as? String,
            profileImageString: self.userData["profileImageString"] as? String,
            uid: Auth.auth().currentUser?.uid,
            quickWord: self.userData["quickWord"] as? String,
            work: self.userData["work"] as? String,
            date: Date().timeIntervalSince1970,
            onlineORNot: true,
            isVerified: self.userData["isVerified"] as? Bool,
            location: self.userData["location"] as? [Double],
            isSubscribe: self.userData["isSubscribe"] as? Bool,
            restOfLike: 0,
            restOfRead: 0)
        self.sendDBModel.sendProfileDataWithLocation(userData: userData, latitude: latitude, longitude: longitude)
        
    }
}
