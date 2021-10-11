//
//  PlanTransactionObserver.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/25.
//

import Foundation
import StoreKit

class PlanTransactionObserver: NSObject {
    public static let kPaymentCompletedNotification = "PaymentCompletedNotification"
    public static let kPaymentErrorNotification = "PaymentErrorNotification"
    
    static let sharedInstance = PlanTransactionObserver()
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PlanTransactionObserver.kPaymentCompletedNotification), object: transaction)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        
        if let error = transaction.error as NSError? {
            if error.code == SKError.paymentCancelled.rawValue {
                print("キャンセル \(error.localizedDescription)")
            } else {
                print("エラー \(error.localizedDescription)")
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PlanTransactionObserver.kPaymentErrorNotification), object: transaction)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}



extension PlanTransactionObserver: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print(#function)
        
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased: // 購入処理完了
                print("purchased")
                completeTransaction(transaction)
                break
            case .failed: // 購入処理失敗
                print("failed")
                failedTransaction(transaction)
                break
            case .restored: // リストア
                print("restored")
                break
            case .deferred: // 保留中
                print("deferred")
                break
            case .purchasing: // 購入処理開始
                print("purchasing")
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print(#function)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(#function)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print(#function)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print(#function)
    }
}
