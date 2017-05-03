//
//  TabBarController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/15.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        guard let selectedVC = viewController as? UINavigationController else {
            print("selectedVC cannot downcast to TaskViewController")
            return
        }
        selectedVC.popToRootViewController(animated: true)
        
        
        switch selectedVC.topViewController {
            
        case is TaskViewController:
            guard let topVC = selectedVC.topViewController as? TaskViewController else {
                print("topVC cannot downcast to TaskViewController because selectedVC.top: \(String(describing: selectedVC.topViewController))")
                return
            }
            topVC.loadTaskPin()
            
            
        case is HouseViewController:
            guard let topVC = selectedVC.topViewController as? HouseViewController else {
                print("topVC cannot downcast to HouseViewController because selectedVC.top: \(String(describing: selectedVC.topViewController))")
                return
            }
            topVC.loadPin()
        
            
        default:
            print("It is a default case because selectedVC.top: \(String(describing: selectedVC.topViewController))")
        }
    }
}
