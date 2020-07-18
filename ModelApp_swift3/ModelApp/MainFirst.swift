//
//  MainFirst.swift
//  ModelApp
//
//  Created by Chan* on 2016/09/14.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class MainFirst : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var horizonAccuracy: UILabel!
    @IBOutlet weak var verticalAccuracy: UILabel!
    
    // ロケーションマネージャを作る
    var locationManager = CLLocationManager()
    
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
        print("MainFirst / 読み込み完了")
        
    }
    
    //　ロケーションサービスの利用不可メッセージ
    func disabledLocationLabel() {
        let msg = "N/A"
        horizonAccuracy.text = msg
        verticalAccuracy.text = msg
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let horiAcc = location.horizontalAccuracy
            let verAcc = location.verticalAccuracy

            horizonAccuracy.text = String(horiAcc)
            verticalAccuracy.text = String(verAcc)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
