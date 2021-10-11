//
//  CommunityViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/17.
//

import UIKit

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    let itemsPerRow: CGFloat = 2
    
    let loadDBModel = LoadDBModel()
    
    var categoryDataArray = [CategoryDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadDBModel.getCategoryListDataProtocol = self
        loadDBModel.loadCategoryListData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

}



extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryDataArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath)
        
        cell.layer.borderWidth = 0.0
        cell.layer.masksToBounds = true
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
        imageView.clipsToBounds = true
        imageView.sd_setImage(with: URL(string: categoryDataArray[indexPath.row].image!), completed: nil)
        
        let nameLabel = cell.contentView.viewWithTag(2) as! UILabel
        nameLabel.text = categoryDataArray[indexPath.row].name
        
        let overlayView = cell.contentView.viewWithTag(3)!
        overlayView.layer.cornerRadius = overlayView.frame.size.width * 0.1
        overlayView.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let communityVC = self.storyboard?.instantiateViewController(identifier: "communityVC") as! CommunityViewController
        communityVC.categoryDataModel = categoryDataArray[indexPath.row]
        self.navigationController?.pushViewController(communityVC, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
}



extension CategoryViewController: GetCategoryListDataProtocol {
    
    func getCategoryListDataProtocol(categoryModelArray: [CategoryDataModel]) {
        self.categoryDataArray = categoryModelArray
        self.collectionView.reloadData()
    }
    
}
