//
//  MatchListViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/06.
//

import UIKit
import Firebase

class MatchListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GetWhoIsMatchProtocol {

    var tableView = UITableView()
    var matchingArray = [UserDataModel]()
    var userData = [String:Any]()
    
    override func viewDidLoad() {
        // 一回しか呼ばれない
        super.viewDidLoad()

        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MatchPersonCell.nib(), forCellReuseIdentifier: MatchPersonCell.identifire)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // マッチングしている人のデータを取得
        let loadDBModel = LoadDBModel()
        loadDBModel.getWhoIsMatchProtocol = self
        loadDBModel.LoadMatchingPersonData()
        userData = KeyChainConfig.getKeyArrayData(key: "userData")
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MatchPersonCell.identifire, for: indexPath) as! MatchPersonCell
        cell.configure(nameLabelString: matchingArray[indexPath.row].name!, ageLabelString: matchingArray[indexPath.row].age!, workLabelString: matchingArray[indexPath.row].work!, profileImageViewString: matchingArray[indexPath.row].profileImageString!)
        return cell
    }
    
    func getWhoIsMatchProtocol(userDataModelArray: [UserDataModel]) {
        
        matchingArray = userDataModelArray
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chatVC = self.storyboard?.instantiateViewController(identifier: "chatVC") as! ChatViewController
        chatVC.userDataModelArray = matchingArray[indexPath.row]
        chatVC.userData = userData
        
        self.navigationController?.pushViewController(chatVC, animated: true)
        
        
    }

}
