//
//  SearchViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/10.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ageMinTextField: UITextField!
    @IBOutlet weak var ageMaxTextField: UITextField!
    @IBOutlet weak var heightMinTextField: UITextField!
    @IBOutlet weak var heightMaxTextField: UITextField!
    @IBOutlet weak var bloodTypeField: UITextField!
    @IBOutlet weak var prefectureTextField: UITextField!
    @IBOutlet var prefectureLabel: UILabel!
    @IBOutlet weak var searchForLocationToggle: UISwitch!
    @IBOutlet weak var locationRangeLabel: UILabel!
    @IBOutlet weak var locationRangeSlider: UISlider!
    @IBOutlet weak var locationRangeNumber: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    
    var ageMinPicker = UIPickerView()
    var ageMaxPicker = UIPickerView()
    var heightMinPicker = UIPickerView()
    var heightMaxPicker = UIPickerView()
    var bloodPicker = UIPickerView()
    var prefecturePicker = UIPickerView()
    
    var dataStringArray = [String]()
    var dataIntArray = [Int]()
    var gender = String()
    
    var userDataModelArray = [UserDataModel]()
    var userData = [String: Any]()
    
    var resultHandler: (([UserDataModel], Bool) -> Void)?
    
    let locationRangeArray = [10, 30, 50, 100]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        ageMinTextField.inputView = ageMinPicker
        ageMaxTextField.inputView = ageMaxPicker
        heightMinTextField.inputView = heightMinPicker
        heightMaxTextField.inputView = heightMaxPicker
        bloodTypeField.inputView = bloodPicker
        prefectureTextField.inputView = prefecturePicker
        
        prefectureTextField.isEnabled = true
        locationRangeSlider.isEnabled = false
        locationRangeLabel.textColor = UIColor(hex: "#a9a9a9")
        
        ageMinPicker.delegate = self
        ageMinPicker.dataSource = self
        ageMaxPicker.delegate = self
        ageMaxPicker.dataSource = self
        heightMaxPicker.delegate = self
        heightMaxPicker.dataSource = self
        heightMinPicker.delegate = self
        heightMinPicker.dataSource = self
        bloodPicker.delegate = self
        bloodPicker.dataSource = self
        prefecturePicker.delegate = self
        prefecturePicker.dataSource = self
        
        ageMinPicker.tag = 1
        ageMaxPicker.tag = 11
        heightMinPicker.tag = 2
        heightMaxPicker.tag = 22
        bloodPicker.tag = 3
        prefecturePicker.tag = 4
        
        Util.rectButton(button: searchButton)
        Util.rectButton(button: resetButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.userData = KeyChainConfig.getKeyArrayData(key: "userData")
            
        locationRangeSlider.minimumValue = 10
        locationRangeSlider.maximumValue = 100
        locationRangeSlider.isContinuous = true
    }
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction func search(_ sender: Any) {        
        if let range1 = self.ageMinTextField.text?.range(of: "歳") {
            self.ageMinTextField.text?.replaceSubrange(range1, with: "")
        }
        
        if let range2 = self.ageMaxTextField.text?.range(of: "歳") {
            self.ageMaxTextField.text?.replaceSubrange(range2, with: "")
        }
        
        if let range3 = self.heightMinTextField.text?.range(of: "cm") {
            self.heightMinTextField.text?.replaceSubrange(range3, with: "")
        }
        
        if let range3 = self.heightMaxTextField.text?.range(of: "cm") {
            self.heightMaxTextField.text?.replaceSubrange(range3, with: "")
        }
        
        // 条件に合ったものを受信する
        let loadDBModel = LoadDBModel()
        loadDBModel.getSearchResultProtocol = self
        
        if searchForLocationToggle.isOn == true {
            loadDBModel.loadSearch(ageMin: ageMinTextField.text!, ageMax: ageMaxTextField.text!, heightMin: heightMinTextField.text!, heightMax: heightMaxTextField.text!, blood: bloodTypeField.text!, prefecture: prefectureTextField.text!, gender: gender, range: Int(locationRangeSlider.value), ownLatitude: self.userData["latitude"] as! Double, ownLongitude: self.userData["longitude"] as! Double)
        } else {
            loadDBModel.loadSearch(ageMin: ageMinTextField.text!, ageMax: ageMaxTextField.text!, heightMin: heightMinTextField.text!, heightMax: heightMaxTextField.text!, blood: bloodTypeField.text!, prefecture: prefectureTextField.text!, gender: gender, range: 0, ownLatitude: 0.0, ownLongitude: 0.0)
        }
        

    }
    
    
    @IBAction func reset(_ sender: Any) {
        ageMinTextField.text = ""
        ageMaxTextField.text = ""
        heightMinTextField.text = ""
        heightMaxTextField.text = ""
        bloodTypeField.text = ""
        prefectureTextField.text = ""
        locationRangeSlider.value = 10
        searchForLocationToggle.isOn = false
    }
    
    @IBAction func touchToggle(_ sender: UISwitch) {
        if sender.isOn {
            prefectureTextField.isEnabled = false
            prefectureLabel.textColor = UIColor(hex: "#a9a9a9")
            locationRangeSlider.isEnabled = true
            locationRangeLabel.textColor = .black
        } else {
            prefectureTextField.isEnabled = true
            prefectureLabel.textColor = UIColor.black
            locationRangeSlider.isEnabled = false
            locationRangeLabel.textColor = UIColor(hex: "#a9a9a9")
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        
        switch currentValue {
        case 0...10:
            locationRangeSlider.value = 10
            locationRangeNumber.text = "10"
        case 11...30:
            locationRangeSlider.value = 30
            locationRangeNumber.text = "30"
        case 31...50:
            locationRangeSlider.value = 50
            locationRangeNumber.text = "50"
        case 51...100:
            locationRangeSlider.value = 100
            locationRangeNumber.text = "100"
        default:
            locationRangeSlider.value = 10
            locationRangeNumber.text = ""
        }
    }
    
}



extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 1:
            dataIntArray = ([Int])(18...80)
            return dataIntArray.count
        case 11:
            dataIntArray = ([Int])(18...80)
            return dataIntArray.count
        case 2:
            dataIntArray = ([Int])(130...220)
            return dataIntArray.count
        case 22:
            dataIntArray = ([Int])(130...220)
            return dataIntArray.count
        case 3:
            dataStringArray = ["A","B","O","AB"]
            return dataStringArray.count
        case 4:
            dataStringArray = Util.prefectures()
            return dataStringArray.count

        default:
            return 0
        }
        
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            ageMinTextField.text = String(dataIntArray[row]) + "歳"
            ageMinTextField.resignFirstResponder()
            break
        case 11:
            ageMaxTextField.text = String(dataIntArray[row]) + "歳"
            ageMaxTextField.resignFirstResponder()
            break
        case 2:
            heightMinTextField.text = String(dataIntArray[row]) + "cm"
            heightMinTextField.resignFirstResponder()
            break
        case 22:
            heightMaxTextField.text = String(dataIntArray[row]) + "cm"
            heightMaxTextField.resignFirstResponder()
            break
        case 3:
            bloodTypeField.text = dataStringArray[row] + "型"
            bloodTypeField.resignFirstResponder()
            break
        case 4:
            prefectureTextField.text = dataStringArray[row]
            prefectureTextField.resignFirstResponder()
            break
        default:
            break
        }
    }
    
    //PickerViewのコンポーネントに表示するデータを決めるメソッド
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        case 1:
            return String(dataIntArray[row]) + "歳"
        case 11:
            return String(dataIntArray[row]) + "歳"
        case 2:
            return String(dataIntArray[row]) + "cm"
        case 22:
            return String(dataIntArray[row]) + "cm"
        case 3:
            return dataStringArray[row] + "型"
        case 4:
            return dataStringArray[row]
            
        default:
            return ""
        }
        
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}



extension SearchViewController: GetSearchResultProtocol {
    func getSearchResultProtocol(userDataModelArray: [UserDataModel], searchDone: Bool) {
        
        self.userDataModelArray = []
        self.userDataModelArray = userDataModelArray
        
        if let handler = self.resultHandler {
            
            // 入力値を引数として渡された処理を実行する
            handler(self.userDataModelArray, searchDone)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}


