//
//  LikeListViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/05.
//

import UIKit

class LikeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GetLikeDataProtocol, GetWhoIsMatchProtocol {

    @IBOutlet weak var tableView: UITableView!
    var userDataModelArray = [UserDataModel]()
    var userData = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LikeProfileCell.nib(), forCellReuseIdentifier: LikeProfileCell.identifire)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        // likeに入っている人たちの情報を取得
        let loadDBModel = LoadDBModel()
        loadDBModel.getLikeDataProtocol = self
        loadDBModel.loadLikeList()
        loadDBModel.getWhoIsMatchProtocol = self
        loadDBModel.LoadMatchingPersonData()
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDataModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LikeProfileCell.identifire, for: indexPath) as! LikeProfileCell
        cell.configure(nameLabelString: userDataModelArray[indexPath.row].name!, ageLabelString: userDataModelArray[indexPath.row].age!, prefectureLabelString: userDataModelArray[indexPath.row].prefecture!, bloodlabelString: userDataModelArray[indexPath.row].bloodType!, genderLabelString: userDataModelArray[indexPath.row].gender!, heightLabelString: userDataModelArray[indexPath.row].height!, workLabelString: userDataModelArray[indexPath.row].work!, quickWordLabelString: userDataModelArray[indexPath.row].quickWord!, profileImageViewString: userDataModelArray[indexPath.row].profileImageString!, uid: userDataModelArray[indexPath.row].uid!, userData: userData)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
    func getLikeDataProtocol(userDataModelArray: [UserDataModel]) {
        self.userDataModelArray = []
        
        self.userDataModelArray = userDataModelArray
        tableView.reloadData()
    }
    

    func getWhoIsMatchProtocol(userDataModelArray: [UserDataModel]) {
        
        var count = 0
        
        var matchArray = [Int]()
        
        for i in 0..<userDataModelArray.count {
            if (self.userDataModelArray.firstIndex(where: {$0.uid == userDataModelArray[i].uid}) != nil) {
                matchArray.append(i)
            }
        }
        
        for i in 0..<matchArray.count {
            self.userDataModelArray.remove(at: matchArray[i] - count)
            count += 1
        }
        
        self.tableView.reloadData()
    }
    
}
