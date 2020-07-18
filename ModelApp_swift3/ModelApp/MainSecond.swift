//
//  MainSecond.swift
//  ModelApp
//
//  Created by Chan* on 2016/09/14.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class MainSecond : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var idoLabel: UILabel!
    @IBOutlet weak var keidoLabel: UILabel!
    @IBOutlet weak var hyoukouLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    // ロケーションマネージャを作る
    var locationManager = CLLocationManager()
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // ラベルの初期化
        disabledLocationLabel()
        // ロケーションマネージャのデリゲートになる
        locationManager.delegate = self
        // ロケーションの精度を設定する（ベスト）
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 更新距離（メートル）
        locationManager.distanceFilter = 1
        // 位置情報の取得を開始する。
        locationManager.allowsBackgroundLocationUpdates = true
        // 位置情報取得の自動停止無効
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        print("MainSecond / 読み込み完了")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let username = defaults.object(forKey: "userID") as! String
        let Sex = defaults.object(forKey: "sex") as! String
        let Age = defaults.object(forKey: "ageYear") as! Int64
        userLabel.text = username
        sexLabel.text = Sex
        ageLabel.text = String(Age)
    }
    
    //　ロケーションサービスの利用不可メッセージ
    func disabledLocationLabel() {
        let msg = "N/A"
        idoLabel.text = msg
        keidoLabel.text = msg
        hyoukouLabel.text = msg
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // locationsの最後の値を取り出す
        let locationData = locations.last
        
        // 緯度
        if var ido = locationData?.coordinate.latitude {
            ido = round(ido*1000000)/1000000
            idoLabel.text = String(ido)
        }
        // 経度
        if var keido = locationData?.coordinate.longitude {
            keido = round(keido*1000000)/1000000
            keidoLabel.text = String(keido)
        }
        // 標高
        if var hyoukou = locationData?.altitude {
            hyoukou = round(hyoukou*100)/100
            hyoukouLabel.text = String(hyoukou) + " m"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
