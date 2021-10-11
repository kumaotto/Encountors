//
//  CommunityDetailViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/17.
//

import UIKit

class CommunityViewController: UIViewController {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noIndexText: UILabel!
    @IBOutlet weak var createCommunityButton: UIButton!
    
    let sectionInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
    let itemsPerRow: CGFloat = 3
    let loadDBModel = LoadDBModel()
    
    var categoryDataModel: CategoryDataModel?
    var communityDataModel = [CommunityDataModel]()
    var filterdCommunityDataModel = [CommunityDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        loadDBModel.getCommunityListDataProtocol = self
        loadDBModel.loadCommunityListData(categoryID: (categoryDataModel?.uid)!)

        self.searchTextField.attributedPlaceholder = NSAttributedString(string: "このカテゴリー内を検索", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        Util.rectButton(button: createCommunityButton)
        
        categoryImageView.sd_setImage(with: URL(string: (categoryDataModel?.image)!), completed: nil)
        nameLabel.text = categoryDataModel?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.noIndexText.isHidden = true
        self.createCommunityButton.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if self.filterdCommunityDataModel.isEmpty {
            self.noIndexText.isHidden = false
            self.createCommunityButton.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    

    @IBAction func search(_ sender: Any) {
        let inputText = searchTextField.text
        
        if !(inputText!.isEmpty) {
            
            for data in filterdCommunityDataModel {
                
                if data.name!.contains(inputText!) == false {
                    self.filterdCommunityDataModel.remove(at: filterdCommunityDataModel.firstIndex(of: data)!)
                    self.collectionView.reloadData()
                }
            }
        } else {
            self.filterdCommunityDataModel = communityDataModel
            self.noIndexText.isHidden = true
            self.createCommunityButton.isHidden = true
            self.collectionView.reloadData()
        }
        
        if self.filterdCommunityDataModel.isEmpty {
            self.noIndexText.isHidden = false
            self.createCommunityButton.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func toCreateCommunityPage(_ sender: Any) {
        self.performSegue(withIdentifier: "toCreateCommunity", sender: nil)
    }
    
}

    
extension CommunityViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterdCommunityDataModel.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityCell", for: indexPath)
        
        cell.layer.borderWidth = 0.0
        cell.layer.masksToBounds = true
        
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.1
        imageView.clipsToBounds = true
        imageView.sd_setImage(with: URL(string: filterdCommunityDataModel[indexPath.row].image!), completed: nil)
        
        let nameLabel = cell.contentView.viewWithTag(2) as! UILabel
        nameLabel.text = filterdCommunityDataModel[indexPath.row].name
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let communityDetailVC = self.storyboard?.instantiateViewController(identifier: "communityDetailVC") as! CommunityDetailViewController
        communityDetailVC.communityDataModel = communityDataModel[indexPath.row]
        self.navigationController?.pushViewController(communityDetailVC, animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}


extension CommunityViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem + 20)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
}


extension CommunityViewController: GetCommunityListDataProtocol {
    func getCommunityListDataProtocol(communityModelArray: [CommunityDataModel]) {
        self.communityDataModel = communityModelArray
        self.filterdCommunityDataModel = communityDataModel
        self.collectionView.reloadData()
    }
}
