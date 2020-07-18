//
//  startView.swift
//  ModelApp
//
//  Created by Chan* on 2016/09/11.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import Foundation
import UIKit

class startView : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初回起動判定
        let ud = UserDefaults.standard
        let WTstoryboard: UIStoryboard = UIStoryboard(name: "WalkThrough", bundle: nil)
        let Mainstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if ud.bool(forKey: "firstLaunch"){
            print("初めての起動です。")
            // 初回起動時の処理
            let nextView = WTstoryboard.instantiateViewController(withIdentifier: "pageView")
            self.present(nextView, animated: true, completion: nil)
            
        }
        else{
            let nextView = Mainstoryboard.instantiateViewController(withIdentifier: "main")
            self.present(nextView, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
