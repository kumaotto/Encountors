//
//  UserDataModel.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/07/30.
//

import Foundation

struct UserDataModel: Equatable {
    
    let name: String?
    let age: String?
    let height: String?
    let bloodType: String?
    let prefecture: String?
    let gender: String?
    let profile: String?
    let profileImageString: String?
    let uid: String?
    let quickWord: String?
    let work: String?
    let date: Double?
    let onlineORNot: Bool?
    let isVerified: Bool?
    let location: [Double]?
    let isSubscribe: Bool?
    let restOfLike: Int?
    let restOfRead: Int?
    
}
