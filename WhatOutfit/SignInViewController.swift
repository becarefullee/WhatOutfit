//
//  signInViewController.swift
//  WhatOutfit
//
//  Created by Qinyuan Li on 16/10/26.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse


class SignInViewController: UIViewController {
    
    // textfield
    @IBOutlet weak var label: UILabel!
  
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    // buttons
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var forgotBtn: UIButton!
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pacifico font of label
        label.font = UIFont(name: "Pacifico", size: 25)
        
        // alignment
        label.frame = CGRect(x: 10, y: 80, width: self.view.frame.size.width - 20, height: 50)
        usernameTxt.frame = CGRect(x: 10, y: label.frame.origin.y + 70, width: self.view.frame.size.width - 20, height: 30)
        passwordTxt.frame = CGRect(x: 10, y: usernameTxt.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        forgotBtn.frame = CGRect(x: 10, y: passwordTxt.frame.origin.y + 30, width: self.view.frame.size.width - 20, height: 30)
        
        signInBtn.frame = CGRect(x: 20, y: forgotBtn.frame.origin.y + 40, width: self.view.frame.size.width / 4, height: 30)
        signInBtn.layer.cornerRadius = signInBtn.frame.size.width / 20
        
        signUpBtn.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signInBtn.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        signUpBtn.layer.cornerRadius = signUpBtn.frame.size.width / 20
        
        // tap to hide keyboard
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    
    // hide keyboard func
    func hideKeyboard(_ recognizer : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

  @IBAction func signUpBtn_click(_ sender: UIButton) {
    print("sign up pressed")
    
    // dismiss keyboard
    self.view.endEditing(true)
    
    // if fields are empty
    if (usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty) {
      
      // alert message
      let alert = UIAlertController(title: "", message: "Please fill all fields", preferredStyle: UIAlertControllerStyle.alert)
      let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
      alert.addAction(ok)
      self.present(alert, animated: true, completion: nil)
      
      return
    }
    
    LilithProgressHUD.show()

    // send data to server to related collumns
    let user = PFUser()
    user.username = usernameTxt.text?.lowercased()
    user.password = passwordTxt.text
    user["likes"] = 0
    user["posts"] = 0
    user["nickname"] = usernameTxt.text?.lowercased()
    user["bio"] = "bio"
    
    let imageData = UIImageJPEGRepresentation(UIImage(named: "ava")!, 0.5)
    let imageFile = PFFile(name: "ava", data: imageData!)
    user["ava"] = imageFile
    
    // save data in server
    user.signUpInBackground { (success, error) in
      if success {
        print("registered")
        print(PFUser.current()?.objectId as Any)
        let userInfo = PFObject(className: "UserInfo")
        userInfo["uid"] = PFUser.current()?.objectId!
        userInfo["followings"] = 1
        userInfo["followers"] = 0
        userInfo.saveInBackground()
        
        let follow = PFObject(className: "Follow")
        follow["follower"] = PFUser.current()?.objectId!
        follow["following"] = "KXrDGusn5N"
        follow.saveInBackground()
        
        let query = PFQuery(className: "UserInfo")
        query.getObjectInBackground(withId: "uTd66kWyVC", block: { (object, error) in
          object?.incrementKey("followers")
          object?.saveInBackground()
        })
        
        //add follow message
        let message = PFObject(className: "Message")
        message["to"] = "KXrDGusn5N"
        message["from"] = PFUser.current()?.objectId
        message["ava"] = imageFile
        message["type"] = "follow"
        message.saveInBackground(block: { (success, error) in
          if success {
            print("add new message suceess")
          }
        })
        
        // remember looged user
        UserDefaults.standard.set(user.username, forKey: "username")
        UserDefaults.standard.synchronize()
        
        LilithProgressHUD.hide()
        // call login func from AppDelegate.swift class
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.login()
        
      } else {
        
        // show alert message
        let alert = UIAlertController(title: "", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
      }
    }

  }
  
    // clicked sign in button
    @IBAction func signInBtn_click(_ sender: AnyObject) {
        print("sign in pressed")
      
        // hide keyboard
        self.view.endEditing(true)
      
        // if textfields are empty
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
          
            // show alert message
            let alert = UIAlertController(title: "", message: "Please fill in fields", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
        // login functions
        PFUser.logInWithUsername(inBackground: usernameTxt.text!.lowercased(), password: passwordTxt.text!) { (user:PFUser?, error) -> Void in
            if error == nil {
                
                // remember user or save in App Memeory did the user login or not
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                // call login function from AppDelegate.swift class
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            
            } else {
                
                // show alert message
                let alert = UIAlertController(title: "", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                LilithProgressHUD.hide()
            }
        }
        
    }
    
}
