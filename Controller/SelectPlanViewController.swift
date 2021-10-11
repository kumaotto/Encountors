//
//  SelectPlanViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/25.
//

import UIKit
import StoreKit
import Firebase

class SelectPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var products: Array<SKProduct>?
    var paymentManager: PaymentManager!
    var productRequest:SKProductsRequest?
    var alert: UIAlertController?
    
    var userData = [String: Any]()
    let sendDBModel = SendDBModel()
    var onModalDismiss: (() -> Void)?
    var purchasedPlanName = String()
    var puchasedPlanPeriod = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "有料会員"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        
        paymentManager = PaymentManager.sharedInstance
        paymentManager.delegate = self
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "処理中",
                                          message: "プロダクトリストを取得しています",
                                          preferredStyle: .alert)
            
            self.present(alert, animated: true, completion: nil)
            self.alert = alert
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            let productIds = ProductManager.sharedInstance.productIds()
            self.productRequest = self.paymentManager.startProductRequest(productIds)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



extension SelectPlanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        guard let product = products?[indexPath.row] else {
            return
        }
        
        let alert = UIAlertController(title: "処理中",
                                      message: "\(product.localizedTitle)の購入処理中です",
                                      preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        self.alert = alert
        
        purchasedPlanName = (ProductManager.sharedInstance.getPlanProductData(product.productIdentifier)?.name)!
        puchasedPlanPeriod = (ProductManager.sharedInstance.getPlanProductData(product.productIdentifier)?.priod)!
        paymentManager.buyProduct(product)
    }
}



extension SelectPlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath)
        
        cell.layer.borderWidth = 0.4
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        if let productId = products?[indexPath.row] {
            let monthLabel = cell.contentView.viewWithTag(1) as! UILabel
            let monthLabelInt = (ProductManager.sharedInstance.getPlanProductData(productId.productIdentifier)?.priod!)! as Int
            monthLabel.text = String(monthLabelInt)
            
            let priceLabel = cell.contentView.viewWithTag(2) as! UILabel
            priceLabel.text = ProductManager.sharedInstance.getPlanProductData(productId.productIdentifier)?.price
            
            let pricePerMonthLabel = cell.contentView.viewWithTag(3) as! UILabel
            pricePerMonthLabel.text = ProductManager.sharedInstance.getPlanProductData(productId.productIdentifier)?.pricePerMonth
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let marginView = UIView()
        marginView.backgroundColor = .clear
        return marginView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
}



extension SelectPlanViewController: PaymentManagerProtocol {
    func finishRequest(_ request: SKProductsRequest, products: Array<SKProduct>) {
        self.products = products
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.alert?.dismiss(animated: true, completion: nil)
            self.alert = nil
            
            self.tableView.reloadData()
        }
    }
    
    func finishRequest(_ request: SKRequest, didFailWithError: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.alert?.dismiss(animated: true, completion: nil)
            self.alert = nil
        }
    }
    
    func finishPayment(_ paymentTransaction: SKPaymentTransaction) {
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            do {

                let receiptData = try Data.init(contentsOf: receiptURL, options: .uncached)
                let base64encoded = receiptData.base64EncodedString()
                paymentManager.verifyReceipt(base64encoded)

            } catch {
                self.sendUserDataWithSubscribe(false)
                print("error")
            }
        }
    }
    
    func finishPayment(faild paymentTransaction: SKPaymentTransaction) {
        alert?.dismiss(animated: true, completion: nil)
        alert = nil
        
        let newAlert = UIAlertController(title: "購入処理失敗",
                                         message: nil,
                                         preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: .default) { action in
                                    self.alert = nil
        }
        newAlert.addAction(action)
        self.present(newAlert, animated: true, completion: nil)
        alert = newAlert
    }
    
    func finishVerifyReceipt(_ contentExpiresDate: UInt64) {
        ProductManager.sharedInstance.saveExpiresDate(contentExpiresDate)
        
        alert?.dismiss(animated: true, completion: nil)
        alert = nil
        
        let newAlert = UIAlertController(title: "購入処理完了", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { action in
            self.alert = nil
            self.sendUserDataWithSubscribe(true)
            self.onModalDismiss?()
            self.navigationController?.popViewController(animated: true)
        }

        newAlert.addAction(action)
        present(newAlert, animated: true, completion: nil)
        alert = newAlert
    }
    
    func finishRestore(_ queue: SKPaymentQueue) {}
    
    func finishRestore(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {}
}



extension SelectPlanViewController {
    func sendUserDataWithSubscribe(_ isSubscribe: Bool) {
        
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
        sendDBModel.sendUserDataWithSubscribe(userData: userData, isSubscribe: isSubscribe, planName: purchasedPlanName, periodNumber: puchasedPlanPeriod)
    }
}
