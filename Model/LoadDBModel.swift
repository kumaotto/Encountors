//
//  LoadDBMobel.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/02.
//

import Foundation
import Firebase
import CoreLocation

protocol GetProfileDataProtocol {
    func getProfileData(userDataModelArray: [UserDataModel])
}

protocol GetOwnProfileDataProtocol {
    func getOwnProfileDataProtocol(userDataModel: UserDataModel)
}

protocol GetLikeCountProtocol {
    func getLikeCount(likeCount: Int, likeFlag: Bool)
}

protocol GetLikeDataProtocol {
    func getLikeDataProtocol(userDataModelArray: [UserDataModel])
}

protocol GetWhoIsMatchProtocol {
    func getWhoIsMatchProtocol(userDataModelArray: [UserDataModel])
}

protocol GetAshiatoProtocol {
    func getAshiatoData(userDataModelArray: [UserDataModel])
}

protocol GetSearchResultProtocol {
    func getSearchResultProtocol(userDataModelArray: [UserDataModel], searchDone: Bool)
}

protocol GetMessageProtocol {
    func getMessageProtocol(messageArray: [Message])
}

protocol GetBlockedListProtocol {
    func getBlockedListProtocol(uid: [String])
}

protocol GetCategoryListDataProtocol {
    func getCategoryListDataProtocol(categoryModelArray: [CategoryDataModel])
}

protocol GetCommunityListDataProtocol {
    func getCommunityListDataProtocol(communityModelArray: [CommunityDataModel])
}

protocol GetSubscribedDataProtocol {
    func GetSubscribedDataProtocol(subscribeData: SubscribeModel)
}


class LoadDBModel {
    
    var db = Firestore.firestore()
    var getProfileUserDataProtocol: GetProfileDataProtocol?
    var getOwnProfileDataProtocol: GetOwnProfileDataProtocol?
    var getLikeCountProtocol: GetLikeCountProtocol?
    var getLikeDataProtocol: GetLikeDataProtocol?
    var getWhoIsMatchProtocol: GetWhoIsMatchProtocol?
    var getAshiatoProtocol: GetAshiatoProtocol?
    var getSearchResultProtocol: GetSearchResultProtocol?
    var getMessageProtocol: GetMessageProtocol?
    var getBlockedListProtocol: GetBlockedListProtocol?
    var getCategoryListDataProtocol: GetCategoryListDataProtocol?
    var getCommunityListDataProtocol: GetCommunityListDataProtocol?
    var getSubscribedDataProtocol: GetSubscribedDataProtocol?

    var currentUser = Sender(senderId: "", displayName: "")
    var otherUser = Sender(senderId: "", displayName: "")
    
    var matchingIDArray = [String]()
    var blockedIDArray = [String]()
    var messages = [Message]()
    
    var categoryListArray = [CategoryDataModel]()
    var communityListArray = [CommunityDataModel]()
    var profileModelArray = [UserDataModel]()
    var userData: UserDataModel?
    var subscribedData: SubscribeModel?
    
    
    func loadUsersProfile(gender: String) {
        
        let ownLikeListArray = KeyChainConfig.getKeyArrayListData(key: "ownLikeList")
        
        db.collection("users").whereField("gender", isNotEqualTo: gender).addSnapshotListener { snapshot, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.profileModelArray = []
                
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                                        
                    if ownLikeListArray.contains(data["uid"] as! String) != true {
                        
                        if let name = data["name"] as? String,
                           let age = data["age"] as? String,
                           let height = data["height"] as? String,
                           let bloodType = data["bloodType"] as? String,
                           let prefecture = data["prefecture"] as? String,
                           let gender = data["gender"] as? String,
                           let profile = data["profile"] as? String,
                           let profileImageString = data["profileImageString"] as? String,
                           let uid = data["uid"] as? String,
                           let quickWord = data["quickWord"] as? String,
                           let onlineORNot = data["onlineORNot"] as? Bool,
                           let work = data["work"] as? String,
                           let isVerified = data["isVerified"] as? Bool,
                           let location = data["location"] as? [Double],
                           let isSubscribe = data["isSubscribe"] as? Bool {
                            
                            let userDataModel = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: 0, onlineORNot: onlineORNot, isVerified: isVerified, location: location, isSubscribe: isSubscribe, restOfLike: 0, restOfRead: 0)
                            
                            self.profileModelArray.append(userDataModel)
                            
                        }
                        
                    }
                    
                }
                
                self.getProfileUserDataProtocol?.getProfileData(userDataModelArray: self.profileModelArray)
                
            }
            
        }
    }
    
    
    
    func loadUsersProfileWithoutGender(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let data = snapshot?.data() {
                if let name = data["name"] as? String,
                   let age = data["age"] as? String,
                   let height = data["height"] as? String,
                   let bloodType = data["bloodType"] as? String,
                   let prefecture = data["prefecture"] as? String,
                   let gender = data["gender"] as? String,
                   let profile = data["profile"] as? String,
                   let profileImageString = data["profileImageString"] as? String,
                   let uid = data["uid"] as? String,
                   let quickWord = data["quickWord"] as? String,
                   let onlineORNot = data["onlineORNot"] as? Bool,
                   let work = data["work"] as? String,
                   let isVerified = data["isVerified"] as? Bool,
                   let location = data["location"] as? [Double],
                   let isSubscribe = data["isSubscribe"] as? Bool,
                   let restOfLike = data["restOfLike"] as? Int,
                   let restOfRead = data["restOfRead"] as? Int {
                    self.userData = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: 0, onlineORNot: onlineORNot, isVerified: isVerified, location: location, isSubscribe: isSubscribe, restOfLike: restOfLike, restOfRead: restOfRead)
                }
                
                self.getOwnProfileDataProtocol?.getOwnProfileDataProtocol(userDataModel: self.userData!)
            
            }
        }
    }
    
    
    func loadRandomUserProfile(max: Int, gender: String) {
        
        let ownLikeListArray = KeyChainConfig.getKeyArrayListData(key: "ownLikeList")
        
        db.collection("users").whereField("gender", isNotEqualTo: gender).limit(to: max).addSnapshotListener { snapshot, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.profileModelArray = []
                
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                                        
                    if ownLikeListArray.contains(data["uid"] as! String) != true {
                        
                        if let name = data["name"] as? String,
                           let age = data["age"] as? String,
                           let height = data["height"] as? String,
                           let bloodType = data["bloodType"] as? String,
                           let prefecture = data["prefecture"] as? String,
                           let gender = data["gender"] as? String,
                           let profile = data["profile"] as? String,
                           let profileImageString = data["profileImageString"] as? String,
                           let uid = data["uid"] as? String,
                           let quickWord = data["quickWord"] as? String,
                           let onlineORNot = data["onlineORNot"] as? Bool,
                           let work = data["work"] as? String,
                           let isVerified = data["isVerified"] as? Bool,
                           let location = data["location"] as? [Double],
                           let isSubscribe = data["isSubscribe"] as? Bool {
                            
                            let userDataModel = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: 0, onlineORNot: onlineORNot, isVerified: isVerified, location: location, isSubscribe: isSubscribe, restOfLike: 0, restOfRead: 0)
                            
                            self.profileModelArray.append(userDataModel)
                            
                        }
                        
                    }
                    
                }
                
                self.getProfileUserDataProtocol?.getProfileData(userDataModelArray: self.profileModelArray)
                
            }
            
        }
    }
    
    
    // get like coout
    func loadLikeCount(uuid: String) {
        
        var likeFlag = Bool()
        
        db.collection("users").document(uuid).collection("like").addSnapshotListener{ snapshot, error in
            
            if error != nil {
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                for doc in snapshotDoc {
                    let data = doc.data()
                    
                    if doc.documentID == Auth.auth().currentUser?.uid {
                        
                        if let like = data["like"] as? Bool {
                            likeFlag = like
                        }
                        
                    }
                    
                }
                
                let docCount = snapshotDoc.count
                self.getLikeCountProtocol?.getLikeCount(likeCount: docCount, likeFlag: likeFlag)
            }
        }
    }
    
    
    
    func loadLikeList() {
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("like").addSnapshotListener { snapshot, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.profileModelArray = []
                
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                    
                    if let name = data["name"] as? String,
                       let age = data["age"] as? String,
                       let height = data["height"] as? String,
                       let bloodType = data["bloodType"] as? String,
                       let prefecture = data["prefecture"] as? String,
                       let gender = data["gender"] as? String,
                       let profile = data["profile"] as? String,
                       let profileImageString = data["profileImageString"] as? String,
                       let uid = data["uid"] as? String,
                       let quickWord = data["quickWord"] as? String,
                       let work = data["work"] as? String
                       {
                        
                        let userDataModel = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: 0, onlineORNot: true, isVerified: false, location: [0, 0], isSubscribe: false, restOfLike: 0, restOfRead: 0)
                        
                        self.profileModelArray.append(userDataModel)
                        
                    }
                }
                
                self.getLikeDataProtocol?.getLikeDataProtocol(userDataModelArray: self.profileModelArray)
                
            }
            
        }
    }
    

    func LoadMatchingPersonData() {
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").addSnapshotListener{ snapshot, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.profileModelArray = []
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                    
                    if let name = data["name"] as? String,
                       let age = data["age"] as? String,
                       let height = data["height"] as? String,
                       let bloodType = data["bloodType"] as? String,
                       let prefecture = data["prefecture"] as? String,
                       let gender = data["gender"] as? String,
                       let profile = data["profile"] as? String,
                       let profileImageString = data["profileImageString"] as? String,
                       let uid = data["uid"] as? String,
                       let quickWord = data["quickWord"] as? String,
                       let work = data["work"] as? String {
                        
                        self.matchingIDArray = KeyChainConfig.getKeyArrayListData(key: "matchingID")
                        
                        if self.matchingIDArray.contains(where: {$0 == uid}) == false {
                            
                            if uid == Auth.auth().currentUser?.uid {
                                
                                self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").document(Auth.auth().currentUser!.uid).delete()
                                
                            } else {
                                
                                Util.matchNotification(name: name, id: uid)
                                
                                self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").document(Auth.auth().currentUser!.uid).delete()
                                
                                self.matchingIDArray.append(uid)
                                KeyChainConfig.setKeyArrayData(value: self.matchingIDArray, key: "matchingID")
                                
                            }
                        }
                        
                        let userDataModel = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: 0, onlineORNot: true, isVerified: false, location: [0,0], isSubscribe: false, restOfLike: 0, restOfRead: 0)
                        self.profileModelArray.append(userDataModel)
                
                    }
                    
                }
                
                self.getWhoIsMatchProtocol?.getWhoIsMatchProtocol(userDataModelArray: self.profileModelArray)
                
            }
            
        }
        
    }
    
    
    func loadAshiatoData() {
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("ashiato").order(by: "date").addSnapshotListener{ snapshot, error in
            
            if error != nil {
                print(error.debugDescription)
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.profileModelArray = []
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                    if let name = data["name"] as? String,
                       let age = data["age"] as? String,
                       let height = data["height"] as? String,
                       let bloodType = data["bloodType"] as? String,
                       let prefecture = data["prefecture"] as? String,
                       let gender = data["gender"] as? String,
                       let profile = data["profile"] as? String,
                       let profileImageString = data["profileImageString"] as? String,
                       let uid = data["uid"] as? String,
                       let quickWord = data["quickWord"] as? String,
                       let work = data["work"] as? String,
                       let date = data["date"] as? Double,
                       let isVerified = data["isVerified"] as? Bool,
                       let location = data["location"] as? [Double],
                       let isSubscribe = data["isSubscribe"] as? Bool {
                        
                        let userData = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: date, onlineORNot: true, isVerified: isVerified, location: location, isSubscribe: isSubscribe, restOfLike: 0, restOfRead: 0)
                        self.profileModelArray.append(userData)
                        
                    }
                    
                }
                
                self.getAshiatoProtocol?.getAshiatoData(userDataModelArray: self.profileModelArray)
                
            }
            
        }
        
    }
    
    
    func loadSearch(ageMin: String, ageMax: String, heightMin: String, heightMax: String, blood: String, prefecture: String, gender: String,  range: Int, ownLatitude: Double, ownLongitude: Double) {
        
        db.collection("users").whereField("age", isLessThan: ageMax).addSnapshotListener {snapshot, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.profileModelArray = []
                
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                    if let name = data["name"] as? String,
                       let age = data["age"] as? String,
                       let height = data["height"] as? String,
                       let bloodType = data["bloodType"] as? String,
                       let prefecture = data["prefecture"] as? String,
                       let gender = data["gender"] as? String,
                       let profile = data["profile"] as? String,
                       let profileImageString = data["profileImageString"] as? String,
                       let uid = data["uid"] as? String,
                       let quickWord = data["quickWord"] as? String,
                       let onlineORNot = data["onlineORNot"] as? Bool,
                       let work = data["work"] as? String,
                       let isVerified = data["isVerified"] as? Bool,
                       let location = data["location"] as? [Double],
                       let isSubscribe = data["isSubscribe"] as? Bool {
                        
                        let userDataModel = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: 0, onlineORNot: onlineORNot, isVerified: isVerified, location: location, isSubscribe: isSubscribe, restOfLike: 0, restOfRead: 0)
                        
                        self.profileModelArray.append(userDataModel)
                        
                    }
                }
                
                if prefecture.isEmpty && range != 0 {
                    var filteredProfileDataArray = [UserDataModel]()
                    
                    for data in self.profileModelArray {
                        if data.gender != gender {
                            let center = CLLocationCoordinate2D(latitude: ownLatitude, longitude: ownLongitude)
                            let location = CLLocationCoordinate2D(latitude: data.location![0], longitude: data.location![1])
                            let circulationRegion = CLCircularRegion(center: center, radius: CLLocationDistance(range), identifier: "locationRange")
                            if circulationRegion.contains(location) {
                                filteredProfileDataArray.append(data)
                            }
                        }
                    }
                    
                    self.profileModelArray = filteredProfileDataArray.filter({
                        $0.bloodType! == blood &&
                        $0.age! >= ageMin &&
                        $0.age! <= ageMax &&
                        $0.height! >= heightMin &&
                        $0.height! <= heightMax
                    })

                } else if !(prefecture.isEmpty) && range == 0 {
                    self.profileModelArray = self.profileModelArray.filter({
                        $0.bloodType! == blood &&
                        $0.prefecture! == prefecture &&
                        $0.age! >= ageMin &&
                        $0.age! <= ageMax &&
                        $0.height! >= heightMin &&
                        $0.height! <= heightMax &&
                        $0.gender != gender
                    })
                }
                
                self.getSearchResultProtocol?.getSearchResultProtocol(userDataModelArray: self.profileModelArray, searchDone: true)
                
            }
        }
    }
    
    
    func loadMessage(userData: [String:Any], partnerData: UserDataModel, currentUser: Sender, otherUser: Sender) {
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").document((partnerData.uid)!).collection("chat").order(by: "date").addSnapshotListener { snapshot, error in
            
            if error != nil {
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.messages = []
                
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                    
                    if let text = data["text"] as? String,
                       let senderID = data["senderID"] as? String,
                       let imageURLString = data["imageURLString"] as? String,
                       let date = data["date"] as? TimeInterval,
                       let isRead = data["isRead"] as? Bool {
                        
                        if senderID == Auth.auth().currentUser?.uid {
                            
                            self.currentUser = Sender(senderId: Auth.auth().currentUser!.uid, displayName: (userData["name"] as? String)!)
                            
                            let message = Message(sender: currentUser, messageId: senderID, sentDate: Date(timeIntervalSince1970: date), kind: .text(text), isRead: isRead, userImagePath: imageURLString, messageImageString: "")
                            self.messages.append(message)
                            
                        } else {
                            
                            self.otherUser = Sender(senderId: senderID, displayName: otherUser.displayName)
                            let message = Message(sender: otherUser, messageId: senderID, sentDate: Date(timeIntervalSince1970: date), kind: .text(text), isRead: isRead, userImagePath: imageURLString, messageImageString: "")
                            self.messages.append(message)
                            
                        }
                        
                    }
                    

                    if let senderID = data["senderID"] as? String,
                       let profileImageString = data["profileURLString"] as? String,
                       let date = data["date"] as? TimeInterval,
                       let attachImageString = data["attachImageString"] as? String,
                       let isRead = data["isRead"] as? Bool {
                        
                        if senderID == Auth.auth().currentUser?.uid {
                            
                            self.currentUser = Sender(senderId: Auth.auth().currentUser!.uid, displayName: userData["name"] as! String)
                            
                            let message = Message(sender: currentUser, messageId: senderID, sentDate: Date(timeIntervalSince1970: date), kind: .photo(ImageMediaItem(imageURL: URL(string: attachImageString)!)), isRead: isRead, userImagePath: profileImageString, messageImageString: attachImageString)
                            self.messages.append(message)
                            
                        } else {
                            
                            self.otherUser = Sender(senderId: senderID, displayName: otherUser.displayName)
                            
                            let message = Message(sender: otherUser, messageId: senderID, sentDate: Date(timeIntervalSince1970: date), kind: .photo(ImageMediaItem(imageURL: URL(string: attachImageString)!)), isRead: isRead, userImagePath: profileImageString, messageImageString: attachImageString)
                            self.messages.append(message)
                            
                        }
                    }
                }
                self.getMessageProtocol?.getMessageProtocol(messageArray: self.messages)
                
            }
        }
    }
    

    func loadBlockedList() {
        self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("blocked").addSnapshotListener{ snapshot, error in
            
            if error != nil {
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                for doc in snapshotDoc {
                    let data = doc.data()
                    let documentID = doc.documentID
                    if let blockedByID = data["blockedBy"] as? String {

                        if self.blockedIDArray.contains(where: {$0 == blockedByID}) == false {

                            if blockedByID != Auth.auth().currentUser?.uid {
                                self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("blocked").document(Auth.auth().currentUser!.uid).delete()

                                self.blockedIDArray.append(blockedByID)
                            }
                        }

                    }
                    self.blockedIDArray.append(documentID)
                }
                self.getBlockedListProtocol?.getBlockedListProtocol(uid: self.blockedIDArray)
            }
        }
    }
    
    
    func loadCategoryListData() {
        
        self.db.collection("communityCategories").addSnapshotListener{ categorySnapshot, error in
            
            if let categorySnapshotDoc = categorySnapshot?.documents {
                
                self.categoryListArray = []
                
                for categoryDoc in categorySnapshotDoc {
                    
                    let categoryData = categoryDoc.data()
                    
                    if let uid = categoryData["uid"] as? String,
                       let categoryName = categoryData["name"] as? String,
                       let categoryImage = categoryData["categoryImage"] as? String {
                        
                        let communityData = CategoryDataModel(uid: uid, name: categoryName, image: categoryImage, communities: self.communityListArray)
                        
                        self.categoryListArray.append(communityData)

                    }
                }
                
                self.getCategoryListDataProtocol?.getCategoryListDataProtocol(categoryModelArray: self.categoryListArray)
            }
        }
    }
    
    
    func loadCommunityListData(categoryID: String) {

        self.db.collection("communityCategories").document(categoryID).collection("communities").addSnapshotListener{ snapshot, error in

            if let snapshotDoc = snapshot?.documents {

                self.communityListArray = []

                for doc in snapshotDoc {

                    let data = doc.data()
                    if let name = data["name"] as? String,
                       let communityImage = data["communityImage"] as? String {

                        let communityData = CommunityDataModel(uid: doc.documentID, name: name, image: communityImage, categoryID: categoryID)
                        self.communityListArray.append(communityData)
                    }
                }
                self.getCommunityListDataProtocol?.getCommunityListDataProtocol(communityModelArray: self.communityListArray)
            }
        }
    }
    
    
    func laodCommunityMenberListData(categoryID: String, communityID: String) {
                
        self.db.collection("communityCategories").document(categoryID).collection("communities").document(communityID).collection("users").addSnapshotListener { snapshot, error in
            
            if error != nil {
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                self.profileModelArray = []
                
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                    
                    if let name = data["name"] as? String,
                       let age = data["age"] as? String,
                       let height = data["height"] as? String,
                       let bloodType = data["bloodType"] as? String,
                       let prefecture = data["prefecture"] as? String,
                       let gender = data["gender"] as? String,
                       let profile = data["profile"] as? String,
                       let profileImageString = data["profileImageString"] as? String,
                       let uid = data["uid"] as? String,
                       let quickWord = data["quickWord"] as? String,
                       let onlineORNot = data["onlineORNot"] as? Bool,
                       let work = data["work"] as? String,
                       let isVerified = data["isVerified"] as? Bool,
                       let location = data["location"] as? [Double],
                       let isSubscribe = data["isSubscribe"] as? Bool {
                        
                        let userDataModel = UserDataModel(name: name, age: age, height: height, bloodType: bloodType, prefecture: prefecture, gender: gender, profile: profile, profileImageString: profileImageString, uid: uid, quickWord: quickWord, work: work, date: 0, onlineORNot: onlineORNot, isVerified: isVerified, location: location, isSubscribe: isSubscribe, restOfLike: 0, restOfRead: 0)
                        
                        self.profileModelArray.append(userDataModel)
                        
                    }
                }
                
                self.getProfileUserDataProtocol?.getProfileData(userDataModelArray: self.profileModelArray)
            }
        }
        
    }
    
    
    func loadUserSubscriptionData() {
        self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("subscription").addSnapshotListener { snapshot, error in
            
            if error != nil {
                return
            }
            
            if let snapshotDoc = snapshot?.documents {
                                
                for doc in snapshotDoc {
                    
                    let data = doc.data()
                    
                    if let type = data["type"] as? String,
                       let startDate = data["startDate"] as? Double,
                       let endDate = data["endDate"] as? Double {
                        self.subscribedData = SubscribeModel(type: type, startDate: startDate, endDate: endDate)
                    }
                }
                
                self.getSubscribedDataProtocol?.GetSubscribedDataProtocol(subscribeData: self.subscribedData!)
            }
        }
    }
    
}
