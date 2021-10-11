//
//  PickupViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/19.
//

import UIKit
import VerticalCardSwiper
import Firebase


class PickupViewController: UIViewController {
    
    @IBOutlet weak var cardSwiper: VerticalCardSwiper!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var leftBarButton: UIBarButtonItem!
    
    var userDataModelArray = [UserDataModel]()
    var sendDBModel = SendDBModel()
    var loadDBModel = LoadDBModel()
    
    var indexNumber = Int()
    var loadedLikeArray = [String]()
    var blcokedListArray = [String]()
    var loadedBlockArray = [String]()
    var likeCount = Int()
    var likeFlag = Bool()
    var userData = [String: Any]()
    
    let semaphore = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        
        loadDBModel.getLikeCountProtocol = self
        cardSwiper.register(nib: UINib(nibName: "PersonPickupCell", bundle: nil), forCellWithReuseIdentifier: "PersonPickupCell")
        
        cardSwiper.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController!.navigationBar.isHidden = true

        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationBar.tintColor = .black
        
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationBar.titleTextAttributes = (titleDict as! [NSAttributedString.Key : Any])
        
        loadDBModel.getLikeDataProtocol = self
        loadDBModel.loadLikeList()
        loadDBModel.getBlockedListProtocol = self
        loadDBModel.loadBlockedList()
        loadDBModel.getProfileUserDataProtocol = self
        loadDBModel.loadRandomUserProfile(max: 5, gender: userData["gender"] as! String)
         
        cardSwiper.delegate = self
        cardSwiper.datasource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}



extension PickupViewController: VerticalCardSwiperDelegate, VerticalCardSwiperDatasource, LikeSendDelegate, UINavigationControllerDelegate {
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return userDataModelArray.count
    }
    
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        
        if let cardCell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "PersonPickupCell", for: index) as? PersonPickupCell {
            
            if index != userDataModelArray.count {
                let profileImage = userDataModelArray[index].profileImageString
                let name = userDataModelArray[index].name
                let age = userDataModelArray[index].age
                let prefecture = userDataModelArray[index].prefecture
                let quickWord = userDataModelArray[index].quickWord
                
                cardCell.profileImageView.sd_setImage(with: URL(string: profileImage!), completed: nil)
                cardCell.nameLabel.text = name
                cardCell.ageLabel.text = age
                cardCell.prefecureLabel.text = prefecture
                cardCell.quickWordLabel.text = quickWord
                
                
                
                if userDataModelArray[index].onlineORNot == true {
                    cardCell.isOnlineLabel.image = UIImage(named: "online")
                } else {
                    cardCell.isOnlineLabel.image = UIImage(named: "offLine")
                }
                
                return cardCell
                
            } else {
                
            }
            
        }
                
        return CardCell()
    }
    
    
    
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
       
        if userDataModelArray[index].uid != Auth.auth().currentUser?.uid {
            
            sendDBModel.likeSendDelegate = self
            
            if self.likeFlag == false {
                sendDBModel.sendToLike(likeFlag: true, objectUserID: (userDataModelArray[index].uid)!, objectUserData: userDataModelArray[index])
                userDataModelArray.remove(at: index)
                
                if userDataModelArray.isEmpty {
                    semaphore.wait()
                    dismiss(animated: true, completion: nil)
                }
            } else {
                sendDBModel.sendToLike(likeFlag: false, objectUserID: (userDataModelArray[index].uid)!, objectUserData: userDataModelArray[index])
            }
            
        }
    }
    

    func like() {
        Util.startAnimation(name: "heart", view: self.view)
        semaphore.signal()
    }
    
    
    
    func didSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        indexNumber = index
    }

    
    func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int) {
        
        let vc = storyboard?.instantiateViewController(identifier: "profileVC") as! ProfileViewController
        vc.userDataModel = userDataModelArray[index]
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func moveToProfileVC() {}
    
}


extension PickupViewController: GetProfileDataProtocol, GetBlockedListProtocol {
    func getProfileData(userDataModelArray: [UserDataModel]) {
        
        var deleteArray = [Int]()
        var count = 0
        
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
        
        cardSwiper.reloadData()
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
        
        cardSwiper.reloadData()
    }
}


extension PickupViewController: GetLikeDataProtocol {
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
        
        cardSwiper.reloadData()
    }
}

extension PickupViewController: GetLikeCountProtocol {
    func getLikeCount(likeCount: Int, likeFlag: Bool) {
        self.likeFlag = likeFlag
        self.likeCount = likeCount
    }
}
