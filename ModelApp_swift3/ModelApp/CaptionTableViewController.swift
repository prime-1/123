//
//  CaptionTableViewController.swift
//  ModelApp
//
//  Created by Chan* on 2016/12/01.
//  Copyright © 2016年 chancp3. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift


class CaptionTableViewController: UITableViewController {
    
    //realm
    let realm = try! Realm()
    
    // Azureクライアントを作成
    let client = MSClient(applicationURLString: "http://modelapp-azureapp.azurewebsites.net")
    
    // AzureStrage接続用Key
    var connectionString = "SharedAccessSignature=sv=2015-12-11&ss=bfqt&srt=sco&sp=rwdlacup&se=2199-12-31T15%3A00%3A00Z&sig=zwdGmI%2B0nlB08KPKnHUz1Gum97EmRy8Tk3dz%2FaArtnY%3D;BlobEndpoint=https://resultgpsdb.blob.core.windows.net;FileEndpoint=https://resultgpsdb.file.core.windows.net;QueueEndpoint=https://resultgpsdb.queue.core.windows.net;TableEndpoint=https://resultgpsdb.table.core.windows.net"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //editボタン
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        print("Caption_Main")
        
        //初回起動判定
        let ud = UserDefaults.standard
        if ud.bool(forKey: "firstLaunch") {
            print("初めての起動です。")
            // 初回起動時の処理
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "start") as! startView
            self.present(nextView, animated: true, completion: nil)
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            //ud.setBool(false, forKey: "firstLaunch")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //セルの個数を指定
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = realm.objects(Comment.self).count
        return count
    }
    
    // セルに値を設定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "CaptionTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CaptionTableViewCell
        
        // captinを呼び出す
        //値を入れる
        let comment = realm.objects(Comment.self)[indexPath.row]
        cell.TimeLabel.text = comment.Time
        cell.captionView.image = comment.picture
        cell.PlaceLabel.text = comment.Place
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let com = realm.objects(Comment.self)[indexPath.row]
            _ = try? realm.write {
                //SQLデータベースからコメントを削除
                let table = client.table(withName: "CaptionItem")
                table.delete(withId: com.imageName) { (itemId, error) in
                    if let err = error {
                        print("ERROR ", err)
                    } else {
                        print("Deleted Item: ", itemId)
                    }
                }
                //realmからコメントを削除
                realm.delete(com)
                
                
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            print("ShowDetail")
            let captionDetailViewController = segue.destination as! CaptionViewController
            
            // Get the cell that generated this segue.
            if let selectedCaptionCell = sender as? CaptionTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCaptionCell)!
                let selectedPath = indexPath.row
                captionDetailViewController.selectedPath = selectedPath
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new meal.")
        }
    }
    
    @IBAction func unwindToMealList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CaptionViewController,let caption:Comment = sourceViewController.caption {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                print("編集開始")
                // Update an existing meal.
                let new = realm.objects(Comment.self)[selectedIndexPath.row]
                try! realm.write{
                    //raelm更新
                    new.About = caption.About
                    new.Degree = caption.Degree
                    new.Evaluation = caption.Evaluation
                    new.How = caption.How
                    new.picture = caption.picture
                    new.Place = caption.Place
                    //SQLデータベース更新
                    let table = client.table(withName: "CaptionItem")
                    print(selectedIndexPath.row)
                    print(new.imageName)
                    table.update(["id": new.imageName, "Evaluation": caption.Evaluation, "Place":caption.Place, "About": caption.About, "How": caption.How, "Degree": caption.Degree]) { (result, error) in
                        if let err = error {
                            print("ERROR ", err)
                        } else if let item = result {
                            print("updated Item: ", item)
                        }
                    }
                    //AzureStrageに画像送信
                    if caption.picture != nil{
                        let account : AZSCloudStorageAccount;
                        try! account = AZSCloudStorageAccount(fromConnectionString: connectionString)
                        let blobClient: AZSCloudBlobClient = account.getBlobClient()
                        let imgName = new.imageName + ".jpg"
                        //let container = caption.Name
                        let blobContainer: AZSCloudBlobContainer = blobClient.containerReference(fromName: "caption")
                        blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil) { (NSError, Bool) -> Void in
                            if ((NSError) != nil){
                                NSLog("Error in creating container.")
                            }
                            else {
                                //let blob: AZSCloudBlockBlob = blobContainer.blockBlobReferenceFromName(".jpg" as String)
                                let blob: AZSCloudBlockBlob = blobContainer.blockBlobReference(fromName: imgName)
                                //let img = UIImage(named: "sakura")
                                //let imageData = UIImagePNGRepresentation(img!)
                                //let imageData = UIImagePNGRepresentation(caption.picture!)
                                let imageData = UIImageJPEGRepresentation(caption.picture!, 0.5)
                                
                                blob.upload(from: imageData!, completionHandler: {(NSError) -> Void in
                                    print("Ok, uploaded !")
                                })
                            }
                        }
                    }
                    
                }
                //テーブルを再読み込みする。
                tableView.reloadData()
                print("編集終了")
            } else {
                //SQLデータベースに送信
                print("SQLデータベースに送信を開始します。")
                //テーブルの参照
                let table = client.table(withName: "CaptionItem")
                //データをクエリする
                table.read { (result, error) in
                    if let err = error {
                        print("ERROR ", err)
                    } else if let items = result?.items {
                        for item in items {
                            //print("Todo Item: ", item)
                        }
                    }
                }
                let newItem = ["id": caption.imageName, "Name": caption.Name, "Time": caption.Time,"Evaluation": caption.Evaluation, "Place":caption.Place, "About": caption.About, "How": caption.How, "Degree": caption.Degree, "latitude": caption.latitude, "longitude": caption.longitude] as [String : Any]
                
                table.insert(newItem as [AnyHashable: Any]) { (result, error) in
                    if let err = error {
                        print("ERROR ", err)
                    } else if let item = result {
                        print("Insert Item: ", item)
                    }
                }
                
                //AzureStrageに画像送信
                if caption.picture != nil{
                    let account : AZSCloudStorageAccount;
                    try! account = AZSCloudStorageAccount(fromConnectionString: connectionString)
                    let blobClient: AZSCloudBlobClient = account.getBlobClient()
                    let imgName = caption.imageName + ".jpg"
                    //let container = caption.Name
                    let blobContainer: AZSCloudBlobContainer = blobClient.containerReference(fromName: "captionimg")
                    blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil) { (NSError, Bool) -> Void in
                        if ((NSError) != nil){
                            NSLog("Error in creating container.")
                        }
                        else {
                            //let blob: AZSCloudBlockBlob = blobContainer.blockBlobReferenceFromName(".jpg" as String)
                            let blob: AZSCloudBlockBlob = blobContainer.blockBlobReference(fromName: imgName)
                            //let img = UIImage(named: "sakura")
                            //let imageData = UIImagePNGRepresentation(img!)
                            //let imageData = UIImagePNGRepresentation(caption.picture!)
                            let imageData = UIImageJPEGRepresentation(caption.picture!, 0.5)
                            
                            blob.upload(from: imageData!, completionHandler: {(NSError) -> Void in
                                print("Ok, uploaded !")
                            })
                        }
                    }
                }
                
                caption.save()
                //データベースはアップデート済み
                //meals.append(meal)
                print("テーブルのアップデート開始")
                //テーブルを再読み込みする。
                tableView.reloadData()
                print("テーブルのアップデート完了")
            }
        }
    }
}
