//
//  CaptionViewController.swift
//  ModelApp
//
//  Created by Chan* on 2016/12/01.
//  Copyright © 2016年 chancp3. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import CoreLocation


class CaptionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var EvaluationControl: UISegmentedControl!
    @IBOutlet weak var PlaceTextField: UITextField!
    @IBOutlet weak var AboutTextView: UITextView!
    @IBOutlet weak var HowTextView: UITextView!
    @IBOutlet weak var DegreeControl: UISegmentedControl!
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var NameLabel: UILabel!
    
    //@IBOutlet weak var latitude: UILabel!
    weak var image:UIImage!
    //@IBOutlet weak var longitude: UILabel!
    
    
    // ロケーションマネージャを作る
    var locationManager = CLLocationManager()
    // NSUserDefaults のインスタンス
    let defaults = UserDefaults.standard
    
    var Lati = ""
    var Longi = ""
    
    
    //realm
    let realm = try! Realm()
    //
    var selectedPath:Int!
    
    var caption = Comment()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //枠線の追加
        AboutTextView.layer.borderWidth = 1;
        AboutTextView.layer.borderColor = UIColor.blue.cgColor
        HowTextView.layer.borderWidth = 1;
        HowTextView.layer.borderColor = UIColor.blue.cgColor
        
        // ラベルの初期化
        //disabledLocationLabel()
        // アプリ利用中の位置情報の利用許可を得る
        locationManager.requestWhenInUseAuthorization()
        
        // ロケーションマネージャのdelegeteになる
        locationManager.delegate = self
        // ロケーション機能の設定
        setupLocationService()
        
        //latitude.text = "取得できました"
        //longitude.text = "取得できました"
        NameLabel.text = defaults.object(forKey: "userID") as? String
        
        //編集の場合
        if let selectedPath = selectedPath {
            let comment = realm.objects(Comment.self)[selectedPath]
            navigationItem.title = "Detail"
            imageView.image = comment.picture
            TimeLabel.text = comment.Time
            EvaluationControl.selectedSegmentIndex = comment.Evaluation
            PlaceTextField.text = comment.Place
            AboutTextView.text = comment.About
            HowTextView.text = comment.How
            DegreeControl.selectedSegmentIndex = comment.Degree
            //latitude.text = comment.latitude
            //longitude.text = comment.longitude
        }
        
        //キーボードをしまう
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CaptionViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        /* Doneボタンの設置 */
        
        // 仮のサイズでツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(CaptionViewController.commitButtonTapped))
        
        kbToolBar.items = [spacer, commitButton]
        
        PlaceTextField.inputAccessoryView = kbToolBar
        AboutTextView.inputAccessoryView = kbToolBar
        HowTextView.inputAccessoryView = kbToolBar
        
        /* Doneボタンの設置_End */
        
    }
    
    //キーボードをしまう
    func DismissKeyboard(){
        view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Doneボタンの動作 */
    func commitButtonTapped (){
        self.view.endEditing(true)
    }
    /* Doneボタンの動作_End */
    
    
    //キャンセル
    @IBAction func Cancel(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        print("編集のキャンセル成功")
    }
    
    //save
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender as AnyObject? === saveButton {
            let comment = Comment.create()
            let now = Date()
            let formatter = DateFormatter()
            //写真
            comment.picture = image
            //時間
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            comment.Time = formatter.string(from: now)
            //場所の保存
            let place = PlaceTextField.text
            comment.Place = place!
            //評価　○　✕
            let evaluation = EvaluationControl.selectedSegmentIndex
            comment.Evaluation = evaluation
            //すごく　まあまま　なんとなく
            let degree = DegreeControl.selectedSegmentIndex
            comment.Degree = degree
            //ということについて about
            let about = AboutTextView.text
            comment.About = about!
            //ということについて how
            let how = HowTextView.text
            comment.How = how!
            //位置情報
            comment.latitude = Lati
            comment.longitude = Longi
            
            //name
            comment.Name = defaults.object(forKey: "userID") as! String
            
            //imageName
            let rand0 = arc4random()
            comment.imageName = String(rand0)
            
            //save
            //comment.save()
            print("キャプションをデータベースに保存しました。")
            caption = comment
            
        }
    }
    
    
    @IBAction func dispAlert(_ sender: UIButton) {
        
        // ① UIAlertControllerクラスのインスタンスを生成
        // タイトル, メッセージ, Alertのスタイルを指定する
        // 第3引数のpreferredStyleでアラートの表示スタイルを指定する
        let alert: UIAlertController = UIAlertController(title: "アラート", message: "選択してください", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        // ② Actionの設定
        // Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        // 第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        
        // Defaultボタン
        let defaultAction_1: UIAlertAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.launchCamera()
            print("Camera")
        })
        let defaultAction_2: UIAlertAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.launchCameraRoll()
            print("Photo Library")
        })
        
        // Cancelボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })
        
        // 下記内容のボタンで画像削除とか出来るようになればいいかも
        /*
         // Destructiveボタン
         let destructiveAction_1: UIAlertAction = UIAlertAction(title: "destructive_1", style: UIAlertActionStyle.Destructive, handler:{
         (action: UIAlertAction!) -> Void in
         print("destructiveAction_1")
         })
         */
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(defaultAction_1)
        alert.addAction(defaultAction_2)
        alert.addAction(cancelAction)
        
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //カメラ
    func launchCamera() {
        //( .camera )の場合カメラで撮影して画像を取得する。
        //( .PhotoLibrary)の場合写真アルバムから取得する。写真アルバムの画面が表示される。
        //( .SaveePhotosAlbum)の場合写真アルバム内のカメラロールから取得する。
        let camera = UIImagePickerControllerSourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(camera) {
            let picker = UIImagePickerController()
            picker.sourceType = camera
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func launchCameraRoll() {
        //( .camera )の場合カメラで撮影して画像を取得する。
        //( .PhotoLibrary)の場合写真アルバムから取得する。写真アルバムの画面が表示される。
        //( .SaveePhotosAlbum)の場合写真アルバム内のカメラロールから取得する。
        let cameraroll = UIImagePickerControllerSourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(cameraroll) {
            let picker = UIImagePickerController()
            picker.sourceType = cameraroll
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //引数は「UIImagePickerControllerOriginalImage」の場合オリジナルの画像を取得するという意味
        image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //viewにimageを表示させる。
        self.imageView.image = image
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        //画像を写真アルバムに保存
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.dismiss(animated: true, completion: nil)
        
        //時間を入力
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        TimeLabel.text = formatter.string(from: now)
        //再撮影用にボタンを変更
        myButton.setTitle("再撮影", for: UIControlState())
    }
    
    // ロケーション機能の設定
    func setupLocationService() {
        // ロケーションの精度を設定する（ベスト）
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 更新距離（メートル）
        locationManager.distanceFilter = 1
    }
    
    //　ロケーションサービスの利用不可メッセージ
    /*func disabledLocationLabel() {
     let msg = "位置情報の利用が許可されてない。"
     //latitude.text = msg
     //longitude.text = msg
     }*/
    
    // 位置情報利用許可のステータスが変わった
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse :
            // ロケーションの更新を開始する
            locationManager.startUpdatingLocation()
        case .notDetermined:
            // ロケーションの更新を停止する
            locationManager.stopUpdatingLocation()
        //disabledLocationLabel()
        default:
            // ロケーションの更新を停止する
            locationManager.stopUpdatingLocation()
            //disabledLocationLabel()
        }
    }
    
    // 位置を移動した
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locationsの最後の値を取り出す
        let locationData = locations.last
        // 緯度
        if var ido = locationData?.coordinate.latitude {
            ido = round(ido*1000000)/1000000
            Lati = String(ido)
        }
        // 経度
        if var keido = locationData?.coordinate.longitude {
            keido = round(keido*1000000)/1000000
            Longi = String(keido)
        }
    }
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error){
        print("位置情報の取得に失敗しました")
    }
    
}
