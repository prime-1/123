//
//  MainPageViewController.swift
//  ModelApp
//
//  Created by Chan* on 2016/09/14.
//  Copyright © 2016年 SakuraiLabcchan3_dev. All rights reserved.
//

import Foundation
import UIKit

class MainPageViewController: UIPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setViewControllers([getFirst()], direction: .forward, animated: true, completion: nil)
        self.dataSource = self
        
    }
    
    func getFirst() -> MainFirst {
        return storyboard!.instantiateViewController(withIdentifier: "MainFirst") as! MainFirst
    }
    
    func getSecond() -> MainSecond {
        return storyboard!.instantiateViewController(withIdentifier: "MainSecond") as! MainSecond
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MainPageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: MainSecond.self) {
            // 2 -> 1
            return getFirst()
        } else {
            // 1 -> end of the road
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: MainFirst.self) {
            // 1 -> 2
            return getSecond()
        } else {
            // 2 -> 3
            return nil
        }
    }
}
