//
//  Community.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/17.
//

import Foundation

struct CategoryDataModel: Equatable {
    
    let uid: String?
    let name: String?
    let image: String?
    let communities: [CommunityDataModel]?
    
}

struct CommunityDataModel: Equatable {
    
    let uid: String?
    let name: String?
    let image: String?
    let categoryID: String?
    
}
