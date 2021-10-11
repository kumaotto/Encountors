//
//  ProductManager.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/25.
//

import Foundation
import StoreKit

struct PlanData {
    var name: String?
    var priod: Int?
    var price: String?
    var pricePerMonth: String?
}

struct ConsumeItemData {
    var count: Int?
    var price: String?
}


class ProductManager: NSObject {
    enum userDefaultsKey : String {
        case contentExpiresDate = "Conten1ExpiresDate"
    }
    
    static let sharedInstance = ProductManager()
    
    let userDefaults = UserDefaults.standard
    
    
    override init() {
        super.init()
    }
    
    func productIds() -> Set<String> {
        return Set(arrayLiteral: "com.temporary.id.12month",
                   "com.temporary.id.6month",
                   "com.temporary.id.3month")
    }
    
    func consumeItemIds() -> Set<String> {
        return Set(arrayLiteral: "com.temporary.id.5like",
                   "com.temporary.id.10like",
                   "com.temporary.id.20like",
                   "com.temporary.id.50like",
                   "com.temporary.id.1read",
                   "com.temporary.id.3read",
                   "com.temporary.id.5read",
                   "com.temporary.id.10read")
    }
    

    func getPlanProductData(_ productId: String) -> PlanData? {
        var productData = PlanData(name: "", priod: 0, price: "")
        
        switch productId {
        case "com.temporary.id.12month":
            productData.name = "12ヶ月プラン"
            productData.priod = 12
            productData.price = "12,120"
            productData.pricePerMonth = "1,010"
        case "com.temporary.id.6month":
            productData.name = "6ヶ月プラン"
            productData.priod = 6
            productData.price = "9,180"
            productData.pricePerMonth = "1,530"
        case "com.temporary.id.3month":
            productData.name = "3ヶ月プラン"
            productData.priod = 3
            productData.price = "6,120"
            productData.pricePerMonth = "2,040"
        default:
            break
        }
        
        return productData
    }
    
    func getConsumeItemData(_ productId: String) -> ConsumeItemData? {
        var consumeItem = ConsumeItemData(count: 0, price: "")
        
        switch productId {
        case "com.temporary.id.5like":
            consumeItem.count = 5
            consumeItem.price = "500"
        case "com.temporary.id.10like":
            consumeItem.count = 10
            consumeItem.price = "800"
        case "com.temporary.id.20like":
            consumeItem.count = 20
            consumeItem.price = "1500"
        case "com.temporary.id.50like":
            consumeItem.count = 50
            consumeItem.price = "3000"
        case "com.temporary.id.1read":
            consumeItem.count = 1
            consumeItem.price = "100"
        case "com.temporary.id.3read":
            consumeItem.count = 3
            consumeItem.price = "200"
        case "com.temporary.id.5read":
            consumeItem.count = 5
            consumeItem.price = "300"
        case "com.temporary.id.10read":
            consumeItem.count = 10
            consumeItem.price = "500"
        default:
            break
        }
        
        return consumeItem
    }
    
    
    func saveExpiresDate(_ content: UInt64) {
        if content > 0 {
            userDefaults.set(content, forKey: userDefaultsKey.contentExpiresDate.rawValue)
        }
    }
}
