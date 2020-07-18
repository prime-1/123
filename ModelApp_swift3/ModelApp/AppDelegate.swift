//
//  AppDelegate.swift
//  ModelApp
//
//  Created by Chan* on 2016/09/05.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CAAnimationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print("Starting")
        // NSUserDefaults のインスタンス取得
        let ud = UserDefaults.standard
        // デフォルト値の設定
        let dic = ["firstLaunch": true]
        ud.register(defaults: dic)
        
    
        // ▼ 1. windowの背景色にLaunchScreen.xibのviewの背景色と同じ色を設定
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor(red: 250/255, green: 89/255, blue: 39/255, alpha: 1)
        self.window!.makeKeyAndVisible()
        
        // ▼ 2. rootViewControllerをStoryBoardから設定 (今回はUINavigationControllerとしているが、他のViewControllerでも可)
        var mainStoryboard: UIStoryboard = UIStoryboard(name: "WalkThrough", bundle: nil)
        var navigationController = mainStoryboard.instantiateViewController(withIdentifier: "pageView")
        
        if ud.bool(forKey: "firstLaunch"){
            print("firstlaunch = True")
        }
        else{
            mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            navigationController = mainStoryboard.instantiateViewController(withIdentifier: "main")
            print("firstlaunch = False")
        }
        self.window!.rootViewController = navigationController
        
        // ▼ 3. rootViewController.viewをロゴ画像の形にマスクし、LaunchScreen.xibのロゴ画像と同サイズ・同位置に配置
        navigationController.view.layer.mask = CALayer()
        navigationController.view.layer.mask!.contents = UIImage(named: "runningman_w.png")!.cgImage
        navigationController.view.layer.mask!.bounds = CGRect(x: 0, y: 0, width: 75, height: 71)
        navigationController.view.layer.mask!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        navigationController.view.layer.mask!.position = CGPoint(x: navigationController.view.frame.width / 2, y: navigationController.view.frame.height / 2)
        
        // ▼ 4. rootViewController.viewの最前面に(白い)viewを配置
        let maskBgView = UIView(frame: navigationController.view.frame)
        maskBgView.backgroundColor = UIColor.darkGray
        navigationController.view.addSubview(maskBgView)
        navigationController.view.bringSubview(toFront: maskBgView)
        
        // ▼ 5. rootViewController.viewのマスクを少し縮小してから、画面サイズよりも大きくなるよう拡大するアニメーション
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.delegate = self
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 1 // 開始タイミングを1秒遅らせる
        let initalBounds = NSValue(cgRect: navigationController.view.layer.mask!.bounds)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 2000, height: 2000))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.fillMode = kCAFillModeForwards
        navigationController.view.layer.mask!.add(transformAnimation, forKey: "maskAnimation")
        
        // ▼ 6. rootViewController.viewの最前面に配置した白いviewを透化するアニメーション (完了後に親viewから削除)
        UIView.animate(withDuration: 0.1,
                                   delay: 1.35,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: {
                                    maskBgView.alpha = 0.0
            },
                                   completion: { finished in
                                    maskBgView.removeFromSuperview()
        })
        
        // ▼ 7. rootViewController.viewを少し拡大して元に戻すアニメーション
        UIView.animate(withDuration: 0.25,
                                   delay: 1.3,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    self.window!.rootViewController!.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            },
                                   completion: { finished in
                                    UIView.animate(withDuration: 0.3,
                                        delay: 0.0,
                                        options: UIViewAnimationOptions(),
                                        animations: {
                                            self.window!.rootViewController!.view.transform = CGAffineTransform.identity
                                        },
                                        completion: nil
                                    )
        })
        return true
    }
    
    // ▼ 8. 「5.」のアニメーション完了時のdelegateメソッドを実装し、マスクを削除する
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // remove mask when animation completes
        self.window!.rootViewController!.view.layer.mask = nil
        
        
    let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.white
        pageController.currentPageIndicatorTintColor = UIColor.black
        //pageController.backgroundColor = UIColor.darkGray
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

