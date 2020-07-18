//
//  main.swift
//  ModelApp
//
//  Created by Hiroaki Ohigashi on 2016/09/10.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import Foundation
import UIKit

class mmain : UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初回起動判定
        let ud = NSUserDefaults.standardUserDefaults()
        if ud.boolForKey("firstLaunch") {
            print("初めての起動です。")
            // 初回起動時の処理
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewControllerWithIdentifier("startView") as! startView
            self.presentViewController(nextView, animated: true, completion: nil)
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            ud.setBool(false, forKey: "firstLaunch")
        }
    }
}