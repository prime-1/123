//
//  sessionView.swift
//  ModelApp
//
//  Created by Chan* on 2016/09/11.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import RealmSwift


class sessionView : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let ud = UserDefaults.standard   
    
    // Azureクライアントを作成
    let client = MSClient(applicationURLString: "http://modelapp-azureapp.azurewebsites.net")
    
    //realm
    let realm = try! Realm()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var trackingButton: UIBarButtonItem!
    @IBOutlet weak var startButton: UIBarButtonItem!
    
    let defaults = UserDefaults.standard
    
    // ロケーションマネージャを作る
    var locationManager = CLLocationManager()
    
    // Other
    var isUpdating = 0
    
    // clusterカウント
    var cluster = 0
    
    // pointカウント
    var point = 0
    
    // CLLocationの初回更新判定
    var syokaiUpdating : Int64 = 0
    
    // startpointの緯度/経度/時間
    var startlat : Double = 0
    var startlon : Double = 0
    var starttime : NSDate? = nil
    var starttimeStr : String = ""
    
    // startpointの緯度/経度/時間
    var endlat : Double = 0
    var endlon : Double = 0
    var endtime : NSDate? = nil
    var endtimeStr : String = ""
    
    // templocの初期化
    var temploc : [CLLocation] = []
    var templat : [Double] = []
    var templon : [Double] = []
    
    // spanの初期化
    var span : Double = 0
    
    // 更新距離の初期化
    var distance : Double = 0
    
    // 歩く速度(Speed per ...)
    var sps : Double = 0
    var sph : Double = 0
    
    // linecolorのdefaultを設定
    var linecolor = 0
    
    var username : String = ""
    var sex : String = ""
    var age : Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starttime = NSDate()
        
        // アプリ利用中の位置情報の利用許可を得る
        locationManager.requestAlwaysAuthorization()
        
        // デリゲートに設定
        locationManager.delegate = self
        mapView.delegate = self
        
        // スケールを表示する
        mapView.showsScale = true
        // ロケーションの精度を設定する（ベスト）
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 更新距離（メートル）
        locationManager.distanceFilter = 1
        // 位置情報の取得を開始する。
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userID = defaults.object(forKey: "userID") as! String
        let Sex = defaults.object(forKey: "sex") as! String
        let Age = defaults.object(forKey: "ageYear") as! Int64
        
        username = userID
        sex = Sex
        age = Age
        //print(sex)
        //print(age)
        
        if (ud.bool(forKey: "firstLaunch")){
            alertBtn("計測開始の準備が整いました", message: "画面下部のスタートボタンで計測を開始します")
            
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            ud.set(false, forKey: "firstLaunch")
        }
    }
    
    // 位置情報利用許可のステータスが変わった
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse : break
        default:
            // ロケーションの更新を停止する
            locationManager.stopUpdatingLocation()
            // トラッキングモードを.Noneにする
             mapView.setUserTrackingMode(.none, animated: true)
            //トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingNone")
            // トラッキングボタンを無効にする
            // trackingButton.enabled = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let startpoint = CLLocation(latitude: startlat, longitude: startlon)
        var endpoint = CLLocation(latitude: endlat, longitude: endlon)
        
        // locationsの最後の値を取り出す
        let locationData = locations.last
        
        // endpointの時間を今の時間にセットする
        endtime = NSDate()
        
        // NSDate型をString型に変換する時の表記設定
        let datetimeFormatter = DateFormatter()
        datetimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        endtimeStr = datetimeFormatter.string(from: endtime as! Date)
        
        // 「終了点 = 現在の座標」とする
        endpoint = CLLocation(latitude: (locationData?.coordinate.latitude)!, longitude: (locationData?.coordinate.longitude)!)
        endlat = endpoint.coordinate.latitude
        endlon = endpoint.coordinate.longitude
        
        
        let horizontalAccuracy = Int((locationData?.horizontalAccuracy)!)
        print(" ")
        print("----------------------------------------------------------------------")
        print("LocatinUpdate = ", syokaiUpdating, "回目")
        print("start", startpoint)
        print("end  ", endpoint)
        print("starttime : ", starttimeStr, "    endtime : ", endtimeStr)
        print(" ")
        print("連続Point : ", point)
        print("temploc配列内の個数 : ", temploc.count)
        print("templat & templon配列内の個数 : ", templat.count)
        
            //　初回処理
            if(syokaiUpdating == 0) {
                
            }
            else {
                
                ///////// 2回目以降は移動前と後の座標間に直線を引く。////////////////////////////////////
                
                // 始点と終了点の更新距離(Distance)を計算
                distance = endpoint.distance(from: startpoint)
                
                // 更新時間&距離
                span = endpoint.timestamp.timeIntervalSince(starttime as! Date)
                print("更新時間 : ", span)
                print("更新距離 : ", distance)
                
                // 時速計算
                sps = distance/span
                sph = (sps*60*60)/1000
                print("時速 = ", sph, " km/h")
                
                // GPS精度による条件分岐
                // 更新距離が5m以下の場合
                if(distance <= 5.0){
                    print("**** Distance : Under_5 ****")

                    
                    if(horizontalAccuracy > 0 || horizontalAccuracy < 48){
                        
                    // 時速10km以下のみ描写
                        if(sph <= 10){
                            linecolor = 0
                            print("**** Speed : Under_10 ****")
                            
                            // pointカウント
                            point += 1
                            
                            temploc.append(locationData!)
                            templat += [endpoint.coordinate.latitude]
                            templon += [endpoint.coordinate.longitude]
                            
                            // 何個連続の場合に描写するか
                            let num = 5
                            
                            if(point >= num){
                                
                                if(point == num){
                                    for i in 0 ..< num{
                                        // Realm内のALLFilterファイルに別途抽出
                                        ALLFilter_addCurrentLocation(temploc[i])
                                        
                                        if(i > 0){
                                            var lineLocation:[CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: templat[i-1], longitude: templon[i-1]),
                                                                                         CLLocationCoordinate2D(latitude: templat[i], longitude: templon[i])]
                                            
                                            //2点間に直線を描画する。
                                            let line = MKPolyline(coordinates: &lineLocation, count: lineLocation.count)
                                            mapView.add(line)
                                        }
                                        else{
                                            // iが0の場合は何もしない
                                        }
                                    }
                                    // temploc配列の初期化
                                    temploc.removeAll()
                                    templat.removeAll()
                                    templon.removeAll()
                                }
                                else{
                                     //始点と終点の座標をlineLocationに登録
                                    var lineLocation:[CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: startlat, longitude: startlon),
                                                                                 CLLocationCoordinate2D(latitude: endlat, longitude: endlon)]
                                    //2点間に直線を描画する。
                                    let line = MKPolyline(coordinates: &lineLocation, count: lineLocation.count)
                                    mapView.add(line)
                                    
                                    // Realm内のALLFilterファイルに別途抽出
                                    ALLFilter_addCurrentLocation(locationData!)
                                    
                                    // temploc配列の初期化
                                    temploc.removeAll()
                                    templat.removeAll()
                                    templon.removeAll()
                                }
                                
                                // Azure関連
                                let table = client.table(withName: "FilterGPS")
                                let newItem = ["nametag": username, "Sex": sex, "Age": age, "Latitude": endpoint.coordinate.latitude, "Longitude": endpoint.coordinate.longitude, "Altitude": endpoint.altitude, "HoriAcc": horizontalAccuracy, "Time": endtimeStr, "Distance": distance, "Span": span , "Speed": sph , "NSTime": endtime!] as [String : Any]
                                
                                table.insert(newItem as [AnyHashable: Any]) { (result, error) in
                                    if let err = error {
                                        print("ERROR ", err)
                                    }
                                    else if result != nil {
                                    }
                                }
                                
                            }
                            
                        }
                        else{
                            linecolor = 1
                            print("**** Speed : OVER_10 ****")
                            
                            // pointリセット
                            point = 0
                            // temploc配列の初期化
                            temploc.removeAll()
                            templat.removeAll()
                            templon.removeAll()
                        }
                    }
                    else{
                        linecolor = 2
                        print("**** Speed : No_Count ****")
                        
                        // pointリセット
                        point = 0
                        // temploc配列の初期化
                        temploc.removeAll()
                        templat.removeAll()
                        templon.removeAll()
                        
                    }
                    
                    // Realm内のHighAccファイルに別途抽出
                    HighAcc_addCurrentLocation(locationData!)
                    
                }
                
                // 更新距離が5m超過、30m以下の場合
                else if(distance > 5.0 && distance <= 30.0){
                    print("**** Distance : Under_30 ****")
                    print("**** Speed : No_Count ****")
                    
                    if(horizontalAccuracy > 0 || horizontalAccuracy < 48){
                        linecolor = 2
                    }
                    else{
                        linecolor = 2
                    }
                    
                    // pointリセット
                    point = 0
                    // temploc配列の初期化
                    temploc.removeAll()
                    templat.removeAll()
                    templon.removeAll()
            
                }
                    
                // 更新距離が30m超過の場合
                else{
                    print("**** Distance : Over_30 ****")
                    print("**** Speed : No_Count ****")
                    
                    if(horizontalAccuracy > 0 || horizontalAccuracy < 48){
                        linecolor = 2
                    }
                    else{
                        linecolor = 2
                    }
                    
                    // pointリセット
                    point = 0
                    // temploc配列の初期化
                    temploc.removeAll()
                    templat.removeAll()
                    templon.removeAll()
                }
                
                
                
            }
            
            addCurrentLocation(locationData!)
        
            print("Horizontal Accuracy : ", horizontalAccuracy)
        
        
            // Azure関連
            let table = client.table(withName: "GPSLog")
            let newItem = ["nametag": username, "Sex": sex, "Age": age, "Latitude": endpoint.coordinate.latitude, "Longitude": endpoint.coordinate.longitude, "Altitude": endpoint.altitude, "HoriAcc": horizontalAccuracy, "Time": endtimeStr, "Distance": distance, "Span": span , "Speed": sph , "NSTime": endtime!] as [String : Any]
            
            table.insert(newItem as [AnyHashable: Any]) { (result, error) in
                if let err = error {
                    print("ERROR ", err)
                }
                else if result != nil {
                }
            }
        
            startlat = endpoint.coordinate.latitude
            startlon = endpoint.coordinate.longitude
            starttime = endtime
            starttimeStr = endtimeStr
                
            syokaiUpdating += 1
        
    }
    
    
    @IBAction func tapTrackingButton(withSender sender: AnyObject) {
        switch mapView.userTrackingMode {
        case .none:
            // NoneからFollowへ
            mapView.setUserTrackingMode(.follow, animated: true)
            // トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingFollow")
        
        case .follow:
            // FollowからFollowWithHeadingへ
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            // トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingHeading")
        
        case .followWithHeading:
            // FollowWithHeadingからNoneへ
            mapView.setUserTrackingMode(.none, animated: true)
            // トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingNone")
 
        }
    }
    
    @IBAction func startButtonDidTap(withSender sender: AnyObject) {
        if isUpdating == 0 {
            isUpdating = 1
            locationManager.startUpdatingLocation()
            startButton.image = UIImage(named: "Stop")
            print("計測開始 -GPS_START~")
            alertBtn("計測開始します", message: "計測開始 - GPS_START")
        }
        else {
            isUpdating = 0
            locationManager.stopUpdatingLocation()
            startButton.image = UIImage(named: "Play")
            print("計測停止 -GPS_STOP-")
            alertBtn("計測停止します", message: "計測停止 - GPS_STOP")
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let testRender = MKPolylineRenderer(overlay: overlay)
            //直線の幅を設定する。
            testRender.lineWidth = 3
        
        if(linecolor == 0){
            testRender.strokeColor = UIColor.purple
        }
        else if (linecolor == 1){
            testRender.strokeColor = UIColor.green
        }
        else if (linecolor == 2){
            testRender.strokeColor = UIColor.clear
        }
        
        return testRender
    }
    
    
    // アラート表示
    func alertBtn(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    /* RealmSwift */
    
    //Realmから情報を取得
    
    fileprivate func loadSavedLocations() -> Results<AllGPS> {
        // Get the default Realm
        let realm = try! Realm()
        
        // Load recent location objects
        return realm.objects(AllGPS.self).sorted(byProperty: "createdAt", ascending: false)
    }
    
    fileprivate func makeLocation(_ rawLocation: CLLocation) -> AllGPS {
        let tester = AllGPS()
        let horiAcc = rawLocation.horizontalAccuracy
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let formattedDateString = dateFormatter.string(from: date)
        
        tester.name = username
        tester.sex = sex
        tester.age = age
        tester.latitude = rawLocation.coordinate.latitude
        tester.longitude = rawLocation.coordinate.longitude
        tester.altitude = rawLocation.altitude
        tester.horiacc = horiAcc
        tester.createdAt = formattedDateString
        tester.span = span
        tester.distance = distance
        tester.speed = sph
        return tester
    }
    
    fileprivate func HighAcc_makeLocation(_ rawLocation: CLLocation) -> HighAccGPS {
        let tester = HighAccGPS()
        let horiAcc = rawLocation.horizontalAccuracy
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let formattedDateString = dateFormatter.string(from: date)
        
        tester.name = username
        tester.sex = sex
        tester.age = age
        tester.latitude = rawLocation.coordinate.latitude
        tester.longitude = rawLocation.coordinate.longitude
        tester.altitude = rawLocation.altitude
        tester.horiacc = horiAcc
        tester.createdAt = formattedDateString
        tester.span = span
        tester.distance = distance
        tester.speed = sph
        return tester
    }
    
    fileprivate func ALLFilter_makeLocation(_ rawLocation: CLLocation) -> ALLFilterGPS {
        let tester = ALLFilterGPS()
        let horiAcc = rawLocation.horizontalAccuracy
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        let formattedDateString = dateFormatter.string(from: date)
        
        tester.name = username
        tester.sex = sex
        tester.age = age
        tester.latitude = rawLocation.coordinate.latitude
        tester.longitude = rawLocation.coordinate.longitude
        tester.altitude = rawLocation.altitude
        tester.horiacc = horiAcc
        tester.createdAt = formattedDateString
        tester.span = span
        tester.distance = distance
        tester.speed = sph
        return tester
    }
    
    fileprivate func addCurrentLocation(_ rowLocation: CLLocation) {
        let location = makeLocation(rowLocation)
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        queue.async {
            // Get the default Realm
            let realm = try! Realm()
            realm.beginWrite()
            // Create a Location object
            realm.add(location)
            try! realm.commitWrite()
        }
    }
    
    fileprivate func HighAcc_addCurrentLocation(_ rowLocation: CLLocation) {
        let location = HighAcc_makeLocation(rowLocation)
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        queue.async {
            // Get the default Realm
            let realm = try! Realm()
            realm.beginWrite()
            // Create a Location object
            realm.add(location)
            try! realm.commitWrite()
        }
    }
    
    fileprivate func ALLFilter_addCurrentLocation(_ rowLocation: CLLocation) {
        let location = ALLFilter_makeLocation(rowLocation)
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        queue.async {
            // Get the default Realm
            let realm = try! Realm()
            realm.beginWrite()
            // Create a Location object
            realm.add(location)
            try! realm.commitWrite()
        }
    }
    
    /* RealmSwift -End- */
}
