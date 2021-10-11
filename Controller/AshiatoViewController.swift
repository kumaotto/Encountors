//
//  AshiatoViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/06.
//

import UIKit

class AshiatoViewController: MatchListViewController, GetAshiatoProtocol {

    let loadDBModel = LoadDBModel()
    var userDataModelArray = [UserDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        // 足跡をロードする
        loadDBModel.getAshiatoProtocol = self
        loadDBModel.loadAshiatoData()
        
        tableView.register(MatchPersonCell.nib(), forCellReuseIdentifier: MatchPersonCell.identifire)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userDataModelArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MatchPersonCell.identifire, for: indexPath) as? MatchPersonCell
        cell?.configure(nameLabelString: userDataModelArray[indexPath.row].name!, ageLabelString: userDataModelArray[indexPath.row].age!, workLabelString: userDataModelArray[indexPath.row].work!, profileImageViewString: userDataModelArray[indexPath.row].profileImageString!)
        return cell!
        
    }
    
    func getAshiatoData(userDataModelArray: [UserDataModel]) {
        self.userDataModelArray = userDataModelArray
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let profileVC = self.storyboard?.instantiateViewController(identifier: "profileVC") as! ProfileViewController
        profileVC.userDataModel = userDataModelArray[indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
