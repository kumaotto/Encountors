//
//  PairsStoreViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/26.
//

import UIKit
import Firebase
import StoreKit

class PairsStoreViewController: UIViewController {

    @IBOutlet weak var likeCollectionView: UICollectionView!
    @IBOutlet weak var readCollectionView: UICollectionView!
    
    let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    let itemsPerRow: CGFloat = 1
    let likeNumberArray = ["5", "10", "20", "50"]
    let readNumberArray = ["1", "3", "5", "10"]
    
    var purchasedCount = Int()
    let sendDBModel = SendDBModel()
    var selectItemIndex = Int()
    
    var consumeItems: Array<SKProduct>?
    var paymentManager: PaymentManager!
    var productRequest:SKProductsRequest?
    var alert: UIAlertController?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "アイテム購入"

        likeCollectionView.delegate = self
        likeCollectionView.dataSource = self
        readCollectionView.delegate = self
        readCollectionView.dataSource = self

        paymentManager = PaymentManager.sharedInstance
        paymentManager.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            let consumeItemIds = ProductManager.sharedInstance.consumeItemIds()
            self.productRequest = self.paymentManager.startProductRequest(consumeItemIds)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func onClickPurchase(_ sender: UIButton) {
        let alert = UIAlertController(title: "処理中", message: "\(consumeItems![sender.tag].localizedTitle)の購入処理中です",
                                      preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        self.alert = alert
        
        selectItemIndex = sender.tag
        purchasedCount = (ProductManager.sharedInstance.getConsumeItemData(consumeItems![sender.tag].productIdentifier)?.count)!
        paymentManager.buyProduct(consumeItems![sender.tag])
    }

}


extension PairsStoreViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return likeNumberArray.count
        }
        else {
            return readNumberArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let likeCell = likeCollectionView.dequeueReusableCell(withReuseIdentifier: "likeCell", for: indexPath)
        let readCell = readCollectionView.dequeueReusableCell(withReuseIdentifier: "readCell", for: indexPath)
        likeCell.layer.borderWidth = 0.4
        likeCell.layer.borderColor = UIColor.lightGray.cgColor
        readCell.layer.borderWidth = 0.4
        readCell.layer.borderColor = UIColor.lightGray.cgColor
        
        if collectionView == likeCollectionView! {
            let numberLabel = likeCell.contentView.viewWithTag(1) as! UILabel
            numberLabel.text = likeNumberArray[indexPath.row]
            
            let button = likeCell.contentView.viewWithTag(2) as! UIButton
            button.tag = indexPath.row
            Util.rectButton(button: button)
            button.addTarget(self, action: #selector(onClickPurchase), for: .touchUpInside)
            
            return likeCell
        }
        else {
            let numberLabel = readCell.contentView.viewWithTag(1) as! UILabel
            numberLabel.text = readNumberArray[indexPath.row]
            
            let button = readCell.contentView.viewWithTag(2) as! UIButton
            button.tag = indexPath.row + 4
            Util.rectButton(button: button)
            button.addTarget(self, action: #selector(onClickPurchase), for: .touchUpInside)

            return readCell
        }
    }
}

extension PairsStoreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        return CGSize(width: collectionView.bounds.width / 4, height: (collectionView.frame.height) - paddingSpace)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
}


extension PairsStoreViewController: PaymentManagerProtocol {
    func finishRequest(_ request: SKProductsRequest, products: Array<SKProduct>) {
//        self.likeItems = likeItems
        self.consumeItems = products
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.alert?.dismiss(animated: true, completion: nil)
            self.alert = nil
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
        
        if selectItemIndex <= 3 {
            sendDBModel.sendLikeItemCount(count: purchasedCount)
        } else {
            sendDBModel.sendReadItemCount(count: purchasedCount)
        }
        
        let newAlert = UIAlertController(title: "購入処理完了", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { action in
            self.alert = nil
        }

        newAlert.addAction(action)
        present(newAlert, animated: true, completion: nil)
        alert = newAlert
    }
    
    func finishRestore(_ queue: SKPaymentQueue) {}
    
    func finishRestore(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error) {}
    
}
