//
//  TabBarViewController.swift
//  WhatOutfit
//
//  Created by Qinyuan Li on 16/10/30.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit



class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tabBar.tintColor = UIColor.black
    self.delegate = self
  }
  
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if viewController.tabBarItem.tag == 1 {
      print(viewController.tabBarItem.tag)
      performSegue(withIdentifier: "showModally", sender: self)
      return false
    } else {
      return true
    }
  }
}
