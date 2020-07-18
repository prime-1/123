//
//  registerView.swift
//  ModelApp
//
//  Created by Chan* on 2016/09/06.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class registerView : UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var sexSeg: UISegmentedControl!

    
    let defaults = UserDefaults.standard
    
    let DatePickerView  : UIDatePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        ageText.delegate = self
        
        textField.text = ""
        
        datePickerSetter()
        
    // 完了ボタンの配置
        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(registerView.commitButtonTapped))
        
        kbToolBar.items = [spacer, commitButton]
        
        textField.inputAccessoryView = kbToolBar
        ageText.inputAccessoryView = kbToolBar
    // 完了ボタンの配置_End
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonDidTap (withSender sender: AnyObject) {
        // 入力フォーム関連
        let userID : String = textField.text!
        var sex : String = ""
        
        switch (sexSeg.selectedSegmentIndex){
            case 0:
                sex = "male"
            case 1:
                sex = "Female"
            default:
                print("該当なし")
        }
        
        var ageYear : Int64 = -1
        
        if(ageText.text != ""){
            let birthday : NSDate? = dateFormatter.date(from: ageText.text!) as NSDate?
            let ageSec = -(birthday?.timeIntervalSinceNow)!
            ageYear = Int64(ageSec/60/60/24/365.24)
        }
        
        defaults.set(userID, forKey: "userID")
        defaults.set(sex, forKey: "sex")
        defaults.set(ageYear, forKey: "ageYear")
//        print("Age :", ageYear)
//        print("Sex :", sex)
//        print("userID :", userID)
        
        if(userID == ""){
            alertBtn("入力不備があります", message: "ユーザ名を確認してください")
        }
        else if(sex == ""){
            alertBtn("入力不備があります", message: "性別を確認してください")
        }
        else if(ageYear < 0){
            alertBtn("入力不備があります", message: "年齢を確認してください")
        }
        else{
            // ページ移動
            let Mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = Mainstoryboard.instantiateViewController(withIdentifier: "main")
            self.present(nextView, animated: true, completion: nil)
        }
    }
    
    // アラート表示
    func alertBtn(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // 完了ボタンの配置
    func commitButtonTapped (){
        self.view.endEditing(true)
    }
    
    func datePickerSetter() {
        let DatePickerView : UIDatePicker = UIDatePicker()
        let today = NSDate()
        
        DatePickerView.maximumDate = today as Date
        DatePickerView.datePickerMode = UIDatePickerMode.date
        ageText.inputView = DatePickerView
        DatePickerView.addTarget(self, action: #selector(registerView.handleDatePicker), for: UIControlEvents.valueChanged)
    }
    
    func handleDatePicker(sender:UIDatePicker) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        ageText.text = dateFormatter.string(from: sender.date)
    }
    
}
