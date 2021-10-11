//
//  PaymentManager.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/25.
//

import Foundation
import StoreKit
import Firebase

protocol PaymentManagerProtocol {
    func finishRequest(_ request: SKProductsRequest, products: Array<SKProduct>)
    func finishRequest(_ request: SKRequest, didFailWithError: Error)
    func finishPayment(_ paymentTransaction: SKPaymentTransaction)
    func finishPayment(faild paymentTransaction: SKPaymentTransaction)
    func finishRestore(_ queue: SKPaymentQueue)
    func finishRestore(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error)
    func finishVerifyReceipt(_ contentExpiresDate: UInt64)
}

class PaymentManager: NSObject {
    
    var delegate:PaymentManagerProtocol?
    static let sharedInstance = PaymentManager()
    
    public static let paymentCompletedNotification = "PaymentCompletedNotification"
    public static let paymentErrorNotification = "PaymentErrorNotification"
    public static let remainTransactionKey = "IsRemainTransaction"
    
    
    /**
     *  Product Section
     */
    func startProductRequest(_ productIds: Set<String>) -> SKProductsRequest {
        print(#function)
        let productRequest = SKProductsRequest(productIdentifiers: productIds)
        productRequest.delegate = self
        productRequest.start()
        
        return productRequest
    }
    
    func buyProduct(_ product: SKProduct) -> Bool {
        print(#function)
        
        guard SKPaymentQueue.canMakePayments() else {
            return false
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        return true
    }
    
    
    
    /**
     *  Transaction Section
     */
    func startTransactionObserve() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopTransactonObserve() {
        SKPaymentQueue.default().remove(self)
    }
    
    func isRemainTransaction() -> Bool {
        let result = UserDefaults.standard.bool(forKey: PaymentManager.remainTransactionKey)
        return result
    }
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PaymentManager.paymentCompletedNotification), object: transaction)
        delegate?.finishPayment(transaction)
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PaymentManager.paymentErrorNotification), object: transaction)
        delegate?.finishPayment(faild: transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    
    
    /**
     *  verifyReceipt Section
     */
    func verifyReceipt(_ receipt: String) {
        #if DEBUG
        let today = Date()
        let effectiveDate = Calendar.current.date(byAdding: .hour, value: 1, to: today)!.timeIntervalSince1970
        
        self.delegate?.finishVerifyReceipt(UInt64(effectiveDate))
        #else
        #endif
    }
    
    
}


extension PaymentManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print(#function)
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("purchased")
                completeTransaction(transaction)
                break
            case .failed:
                print("failed")
                failedTransaction(transaction)
                break
            case .deferred:
                print("deferred")
                break
            case .restored:
                print("restored")
                break
            case .purchasing:
                print("purchasing")
                UserDefaults.standard.set(true, forKey: PaymentManager.remainTransactionKey)
                UserDefaults.standard.synchronize()
                break
            @unknown default:
                fatalError()
            }
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print(#function)
        UserDefaults.standard.set(false, forKey: PaymentManager.remainTransactionKey)
        UserDefaults.standard.synchronize()
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(#function)
        delegate?.finishRestore(queue, restoreCompletedTransactionsFailedWithError: error)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print(#function)
        delegate?.finishRestore(queue)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print(#function)
    }
}


extension PaymentManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for invalidIds in response.invalidProductIdentifiers {
            print(invalidIds)
        }
        
        delegate?.finishRequest(request, products:response.products)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)

        delegate?.finishRequest(request, didFailWithError: error)
    }
}
