//
//  SendDBModel.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/07/30.
//

import Foundation
import Firebase

protocol ProfileSendDone {
    func profileSendDone()
}

protocol CommunityCreateDone {
    func communityCreateDone()
}

protocol ReadUpdateDone {
    func readUpdateDone()
}

protocol LikeSendDelegate {
    func like()
}

protocol GetAttachProtocol {
    func getAttachProtocol(attachImageString: String)
}

class SendDBModel {
    
    let db = Firestore.firestore()
    var profileSendDone: ProfileSendDone?
    var communityCreateDone: CommunityCreateDone?
    var readUpdateDone: ReadUpdateDone?
    var likeSendDelegate: LikeSendDelegate?
    var getAttachProtocol: GetAttachProtocol?
    
    
    func sendProfleData(userData: UserDataModel, profileImageData: Data) {
        
        let imageRef = Storage.storage().reference().child("ProfileImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpeg")
        
        imageRef.putData(profileImageData, metadata: nil) { metaData, error  in
            
            if error != nil {
                return
            }
            
            imageRef.downloadURL { url, error in
                
                if error != nil {
                    return
                }
                
                if url != nil {
                    
                    self.db.collection("users").document(Auth.auth().currentUser!.uid).setData(
                        [
                            "name": userData.name as Any,
                            "age": userData.age as Any,
                            "height": userData.height as Any,
                            "bloodType": userData.bloodType as Any,
                            "prefecture": userData.prefecture as Any,
                            "gender": userData.gender as Any,
                            "profile": userData.profile as Any,
                            "profileImageString": url?.absoluteString as Any,
                            "uid": Auth.auth().currentUser?.uid as Any,
                            "quickWord": userData.quickWord as Any,
                            "work": userData.work as Any,
                            "onlineORNot": userData.onlineORNot as Any,
                            "isVerified": userData.isVerified as Any,
                            "location": [0.0, 0.0],
                            "isSubscribe": false,
                            "restOfLike": userData.restOfLike as Any,
                            "restOfRead": userData.restOfRead as Any
                        ]
                    )
                    
                    KeyChainConfig.setKeyData(value: [
                        "name": userData.name as Any,
                        "age": userData.age as Any,
                        "height": userData.height as Any,
                        "bloodType": userData.bloodType as Any,
                        "prefecture": userData.prefecture as Any,
                        "gender": userData.gender as Any,
                        "profile": userData.profile as Any,
                        "profileImageString": url?.absoluteString as Any,
                        "uid": Auth.auth().currentUser?.uid as Any,
                        "quickWord": userData.quickWord as Any,
                        "work": userData.work as Any,
                        "isVerified": userData.isVerified as Any,
                        "location": userData.location as Any,
                        "isSubscribe": false as Any
                    ], key: "userData")
                    
                    self.profileSendDone?.profileSendDone()
                }
            }
        }
    }
    
    
    
    func sendToLike(likeFlag: Bool, objectUserID: String, objectUserData: UserDataModel) {
        
        if likeFlag == false {
            self.db.collection("users").document(objectUserID).collection("like").document(Auth.auth().currentUser!.uid).setData(["like": false])
            
            deleteToLike(objectUserID: objectUserID)
            
            var ownLikeListArray = KeyChainConfig.getKeyArrayListData(key: "ownLikeList")

            ownLikeListArray.removeAll(where: {$0 == objectUserID})
            KeyChainConfig.setKeyArrayData(value: ownLikeListArray, key: "ownLikeList")
            
        } else if likeFlag == true {
            
            let userData = KeyChainConfig.getKeyArrayData(key: "userData")
            
            self.db.collection("users").document(objectUserID).collection("like").document(Auth.auth().currentUser!.uid).setData(["like": true, "uid": userData["uid"] as Any, "name": userData["name"] as Any,"age": userData["age"] as Any,"height": userData["height"] as Any,"bloodType": userData["bloodType"] as Any,"prefecture": userData["prefecture"] as Any,"gender": userData["gender"] as Any,"profile": userData["profile"] as Any,"profileImageString": userData["profileImageString"] as Any,"quickWord": userData["quickWord"] as Any,"work": userData["work"] as Any])
            
            self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("ownLiked").document(objectUserID).setData(["like": true, "uid": objectUserID, "name": objectUserData.name as Any,"age": objectUserData.age as Any,"height": objectUserData.height as Any,"bloodType": objectUserData.bloodType as Any,"prefecture": objectUserData.prefecture as Any,"gender": objectUserData.gender as Any,"profile": objectUserData.profile as Any,"profileImageString": objectUserData.profileImageString as Any,"quickWord": objectUserData.quickWord as Any, "work": objectUserData.work as Any])
            
            
            var ownLikeListArray = KeyChainConfig.getKeyArrayListData(key: "ownLikeList")
            ownLikeListArray.append(objectUserID)
            KeyChainConfig.setKeyArrayData(value: ownLikeListArray, key: "ownLikeList")
            
            self.likeSendDelegate?.like()
            
        }
    }

    
    func deleteToLike(objectUserID: String) {
        
        self.db.collection("users").document(objectUserID).collection("like").document(Auth.auth().currentUser!.uid).delete()
        self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("like").document(objectUserID).delete()
        self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("ownLiked").document(objectUserID).delete()
    }
    

    func sendToLikeFromLike(likeFlag: Bool, thisUserID: String, matchedUserName: String, matchedID: String) {
        
        if likeFlag == false {
            
            self.db.collection("users").document(thisUserID).collection("like").document(Auth.auth().currentUser!.uid).setData(["like": false])
            deleteToLike(objectUserID: thisUserID)
            
            var ownListLikeArray = KeyChainConfig.getKeyArrayListData(key: "ownLikeList")
            ownListLikeArray.removeAll(where: {$0 == thisUserID})
            KeyChainConfig.setKeyArrayData(value: ownListLikeArray, key: "ownLikeList")
            
        } else if likeFlag == true {
            
            let userData = KeyChainConfig.getKeyArrayData(key: "userData")
            
            self.db.collection("users").document(thisUserID).collection("like").document(Auth.auth().currentUser!.uid).setData(["like": true, "uid": userData["uid"] as Any, "name": userData["name"] as Any,"age": userData["age"] as Any,"height": userData["height"] as Any,"bloodType": userData["bloodType"] as Any,"prefecture": userData["prefecture"] as Any,"gender": userData["gender"] as Any,"profile": userData["profile"] as Any,"profileImageString": userData["profileImageString"] as Any,"quickWord": userData["quickWord"] as Any,"work": userData["work"] as Any])
            
            self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("ownLiked").document(thisUserID).setData(["like": true, "uid": userData["uid"] as Any, "name": userData["name"] as Any,"age": userData["age"] as Any,"height": userData["height"] as Any,"bloodType": userData["bloodType"] as Any,"prefecture": userData["prefecture"] as Any,"gender": userData["gender"] as Any,"profile": userData["profile"] as Any,"profileImageString": userData["profileImageString"] as Any,"quickWord": userData["quickWord"] as Any,"work": userData["work"] as Any])
            
            var ownListLikeArray = KeyChainConfig.getKeyArrayListData(key: "ownLikeList")
            ownListLikeArray.append(thisUserID)
            KeyChainConfig.setKeyArrayData(value: ownListLikeArray, key: "ownLikeList")
            
            Util.matchNotification(name: matchedUserName, id: matchedID)
            
            deleteToLike(objectUserID: Auth.auth().currentUser!.uid)
            deleteToLike(objectUserID: matchedID)
            
            self.db.collection("users").document(matchedID).collection("matching").document(matchedID).delete()
            self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").document(Auth.auth().currentUser!.uid).delete()
            
            self.likeSendDelegate?.like()
            
        }
    }
    
    
    func sendToMatchingList(thisUserID: String, name: String, age: String, bloodType: String, prefecture: String, height: String, gender: String, profile: String, profileImageString: String, uid: String, quickWord: String, work: String, userData: [String:Any]) {
        
        if thisUserID == uid {
            
            self.db.collection("users").document(thisUserID).collection("matching").document(Auth.auth().currentUser!.uid).setData(
                ["uid": userData["uid"] as Any, "name": userData["name"] as Any,"age": userData["age"] as Any,"height": userData["height"] as Any,"bloodType": userData["bloodType"] as Any,"prefecture": userData["prefecture"] as Any,"gender": userData["gender"] as Any,"profile": userData["profile"] as Any,"profileImageString": userData["profileImageString"] as Any,"quickWord": userData["quickWord"] as Any,"work": userData["work"] as Any]
            )
            
            self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").document(thisUserID).setData(
                ["uid": uid as Any, "name": name as Any,"age": age as Any,"height": height as Any,"bloodType": bloodType as Any,"prefecture": prefecture as Any,"gender": gender as Any,"profile": profile as Any,"profileImageString": profileImageString as Any,"quickWord": quickWord as Any,"work": work as Any]
            )
            
        } else {
            
            self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("matching").document(thisUserID).setData(
                ["uid": uid as Any, "name": name as Any,"age": age as Any,"height": height as Any,"bloodType": bloodType as Any,"prefecture": prefecture as Any,"gender": gender as Any,"profile": profile as Any,"profileImageString": profileImageString as Any,"quickWord": quickWord as Any,"work": work as Any]
            )
            
        }
        
        self.db.collection("users").document(thisUserID).collection("like").document(Auth.auth().currentUser!.uid).delete()
        self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("like").document(thisUserID).delete()
        
    }
    
    
    func sendAshiato(partnerUserId: String) {
        
        let userData = KeyChainConfig.getKeyArrayData(key: "userData")
        
        self.db.collection("users").document(partnerUserId).collection("ashiato").document(Auth.auth().currentUser!.uid).setData(["uid": userData["uid"] as Any, "name": userData["name"] as Any,"age": userData["age"] as Any,"height": userData["height"] as Any,"bloodType": userData["bloodType"] as Any,"prefecture": userData["prefecture"] as Any,"gender": userData["gender"] as Any,"profile": userData["profile"] as Any,"profileImageString": userData["profileImageString"] as Any,"quickWord": userData["quickWord"] as Any,"work": userData["work"] as Any, "date": Date().timeIntervalSince1970])
        
    }
    
    
    func sendImageData(image: UIImage, senderID: String, toID: String) {
        
        let userData = KeyChainConfig.getKeyArrayData(key: "userData")
            
        let imageRef = Storage.storage().reference().child("ChatImages").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpeg")
        
        imageRef.putData(image.jpegData(compressionQuality: 0.3)!, metadata: nil) { metaData, error  in
            
            if error != nil {
                return
            }
            
            imageRef.downloadURL { url, error in
                
                if error != nil {
                    return
                }
                
                if url != nil {
                    
                    self.db.collection("users").document(senderID).collection("matching").document(toID).collection("chat").document().setData(
                        [
                            "senderID": Auth.auth().currentUser!.uid,
                            "displayName": userData["name"] as Any,
                            "profileURLString": userData["profileImageString"] as Any,
                            "date": Date().timeIntervalSince1970,
                            "attachImageString": url?.absoluteString as Any,
                            "isRead": false
                        ]
                    )
                    
                    self.db.collection("users").document(toID).collection("matching").document(senderID).collection("chat").document().setData(
                        [
                            "senderID": Auth.auth().currentUser!.uid,
                            "displayName": userData["name"] as Any,
                            "profileURLString": userData["profileImageString"] as Any,
                            "date": Date().timeIntervalSince1970,
                            "attachImageString": url?.absoluteString as Any,
                            "isRead": false
                        ]
                    )
                    
                    self.getAttachProtocol?.getAttachProtocol(attachImageString: url!.absoluteString)
                }
            }
        }
    }
    
    func sendMessage(senderID: String, toID: String, text: String, displayName: String, imageURLString: String) {
        
        self.db.collection("users").document(senderID).collection("matching").document(toID).collection("chat").document().setData(
            [
                "text": text as Any,
                "senderID": senderID as Any,
                "displayName": displayName as Any,
                "imageURLString": imageURLString as Any,
                "date": Date().timeIntervalSince1970,
                "isRead": false
            ])
        
        self.db.collection("users").document(toID).collection("matching").document(senderID).collection("chat").document().setData(
            [
                "text": text as Any,
                "senderID": Auth.auth().currentUser?.uid as Any,
                "displayName": displayName as Any,
                "imageURLString": imageURLString as Any,
                "date": Date().timeIntervalSince1970,
                "isRead": false
            ])
    }
    
    // 既読機能 途中
    // 相手のメッセージを見たら、相手のDBにある相手のメッセージを既読にする
    func sendUpdateReadMessage(senderID: String, toID: String) {
        self.db.collection("users").document(toID).collection("matching").document(senderID).collection("chat").whereField("senderID", isEqualTo: senderID).getDocuments { snapshot, error in
         
            if error != nil {
                print(error.debugDescription)
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                for doc in snapshotDoc {
                    self.db.batch().updateData(["isRead": true], forDocument: doc.reference)
                }
            }
        }
    }
    
    
    func sendReportWithPersonID(text: String, id: String) {
        
        self.db.collection("report").document().setData(
            ["senderID": id, "text": text]
        )
        
    }
    
    func sendContactData(category: String, text: String, email: String, id: String) {
        self.db.collection("contact").document().setData(
            ["category": category, "text": text, "email": email, "senderID": id]
        )
    }
    
    func sendVerifiedImage(senderID: String, verifiedImage: Data, userData: [String: Any]) {
        
        let imageRef = Storage.storage().reference().child("VerifiedImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpeg")
        
        
        imageRef.putData(verifiedImage, metadata: nil) { metaData, error  in
            
            if error != nil {
                return
            }
            
            imageRef.downloadURL { url, error in
                
                if error != nil {
                    return
                }
                
                if url != nil {
                                    
                    self.db.collection("users").document(Auth.auth().currentUser!.uid).updateData(
                        ["isVerified": true]
                    )
                    
                    KeyChainConfig.setKeyData(value: [
                        "name": userData["name"] as Any,
                        "age": userData["age"] as Any,
                        "height": userData["height"] as Any,
                        "bloodType": userData["bloodType"] as Any,
                        "prefecture": userData["prefecture"] as Any,
                        "gender": userData["gender"] as Any,
                        "profile": userData["profile"] as Any,
                        "profileImageString": userData["profileImageString"] as Any,
                        "uid": Auth.auth().currentUser?.uid as Any,
                        "quickWord": userData["quickWord"] as Any,
                        "work": userData["work"] as Any,
                        "isVerified": true as Any
                    ], key: "userData")
                    
                }
                
            }
        }
    }
    
    
    func sendBlockUser(senderID: String, blockedUser: String) {
        
        var blockList = KeyChainConfig.getKeyArrayListData(key: "blockList")
        blockList.append(blockedUser)
        KeyChainConfig.setKeyArrayData(value: blockList, key: "blockList")
        
        self.db.collection("users").document(senderID).collection("block").document(blockedUser).setData(["blockID": blockedUser])
        
        self.db.collection("users").document(blockedUser).collection("blocked").document(senderID).setData(["blockedBy": senderID])
        
    }
    
    
    func sendNewCommunity(communityName: String, communityCategory: String, communityImageData: Data) {
        
        var documentID = ""
        let imageRef = Storage.storage().reference().child("CommunityImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpeg")
        
        db.collection("communityCategories").whereField("name", isEqualTo: communityCategory).addSnapshotListener { snapshot, error in
            
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            
            if let snapshotDoc = snapshot?.documents {
                
                for doc in snapshotDoc {
                    documentID = doc.documentID
                }
                
                if !(documentID.isEmpty) {
                    
                    imageRef.putData(communityImageData, metadata: nil) { metadata, error in

                        if error != nil {
                            return
                        }
                        
                        imageRef.downloadURL { url, error in
                            
                            if error != nil {
                                return
                            }
                            
                            if url != nil {
                                
                                self.db.collection("communityCategories").document(documentID).collection("communities").document().setData(
                                    [
                                        "name": communityName as Any,
                                        "communityImage": url?.absoluteString as Any
                                    ]
                                )
                                
                                self.communityCreateDone?.communityCreateDone()
                            }
                            
                        }
                    }
                }
            }            
            
        }
            
    }
    
    
    func sendNewCommunityMemberData(categoryID: String, communityID: String, userData: UserDataModel, isJoined: Bool) {
        
        if isJoined == false {
            
            self.db.collection("communityCategories").document(categoryID).collection("communities").document(communityID).collection("users").document(Auth.auth().currentUser!.uid).delete()
            
        } else if isJoined == true {
            
            self.db.collection("communityCategories").document(categoryID).collection("communities").document(communityID).collection("users").document(Auth.auth().currentUser!.uid).setData(
                [
                    "name": userData.name as Any,
                    "age": userData.age as Any,
                    "height": userData.height as Any,
                    "bloodType": userData.bloodType as Any,
                    "prefecture": userData.prefecture as Any,
                    "gender": userData.gender as Any,
                    "profile": userData.profile as Any,
                    "profileImageString": userData.profileImageString as Any,
                    "uid": Auth.auth().currentUser?.uid as Any,
                    "quickWord": userData.quickWord as Any,
                    "work": userData.work as Any,
                    "onlineORNot": userData.onlineORNot as Any,
                    "isVerified": userData.isVerified as Any,
                    "location": userData.location as Any
                ]
            )
            self.profileSendDone?.profileSendDone()
            
        }
        
    }
    
    
    
    func sendProfileDataWithLocation(userData: UserDataModel, latitude: Double, longitude: Double) {
        
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["location": [latitude, longitude] as Any])
        
        KeyChainConfig.setKeyData(value: [
            "name": userData.name as Any,
            "age": userData.age as Any,
            "height": userData.height as Any,
            "bloodType": userData.bloodType as Any,
            "prefecture": userData.prefecture as Any,
            "gender": userData.gender as Any,
            "profile": userData.profile as Any,
            "profileImageString": userData.profileImageString as Any,
            "uid": Auth.auth().currentUser?.uid as Any,
            "quickWord": userData.quickWord as Any,
            "work": userData.work as Any,
            "isVerified": userData.isVerified as Any,
            "latitude": latitude as Any,
            "longitude": longitude as Any
        ], key: "userData")
        
        self.profileSendDone?.profileSendDone()
    }
    
    
    func sendUserDataWithSubscribe(userData: UserDataModel, isSubscribe: Bool, planName: String, periodNumber: Int) {
        
        let calendar = Calendar(identifier: .gregorian)
        let endDate = calendar.date(byAdding: .month, value: periodNumber, to: Date())
        
        if isSubscribe == false {
            db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["isSubscribe": isSubscribe as Any])
            
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("subscription").document().delete()
            
            self.profileSendDone?.profileSendDone()
            
        } else {
            db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["isSubscribe": isSubscribe as Any])
            
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("subscription").document().setData([
                "type": planName,
                "startDate": Date().timeIntervalSince1970,
                "endDate": endDate!.timeIntervalSince1970
            ])

        }
        
    }
    
    
    func sendLikeItemCount(count: Int) {
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["restOfLike": FieldValue.increment(Int64(count))])
    }
    
    func sendReadItemCount(count: Int) {
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["restOfRead": FieldValue.increment(Int64(count))])
    }
}
