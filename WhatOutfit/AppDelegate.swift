//
//  AppDelegate.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//
import Parse
import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    Parse.enableLocalDatastore()
    
    let parseConfig = ParseClientConfiguration { (ParseMutableClientConfiguration) in
        ParseMutableClientConfiguration.applicationId = "com.Qinyuan-li.ParseTutorial"
        //ParseMutableClientConfiguration.clientKey = "WhatOutfit_Liqinyuan_Uiowa_19940722"
        ParseMutableClientConfiguration.server = "https://fierce-wildwood-43750.herokuapp.com/parse"
        ParseMutableClientConfiguration.isLocalDatastoreEnabled = true
    }
    
    Parse.initialize(with: parseConfig)
    
    //1
    let userNotificationCenter = UNUserNotificationCenter.current()
    userNotificationCenter.delegate = self
    
    //2
    userNotificationCenter.requestAuthorization(options: [.badge, .sound]) { accepted, error in
      guard accepted == true else {
        print("User declined remote notifications")
        return
      }
      //3
      application.registerForRemoteNotifications()
    }

    
    login()
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func login() {
    if let _ = UserDefaults.standard.string(forKey: "username") {
      let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
    }
  }
  
  // 1
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let installation = PFInstallation.current()
    installation?.setDeviceTokenFrom(deviceToken)
    installation?.saveInBackground()
  }
  // 2
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    if (error as NSError).code == 3010 {
      print("Push notifications are not supported in the iOS Simulator.")
    } else {
      print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
    }
  }
  
}


extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void) {
    PFPush.handle(notification.request.content.userInfo)
    completionHandler(.alert)
  }
}

