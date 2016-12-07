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
  
  var distant: CGFloat = 0
  var username: String?
  var password: String?
  var emailAdress: String?
  
  enum Mode {
    case None
    case SignIn
    case SignUp
  }
  
  
  enum Step {
    case Zero
    case One
    case Two
    case Three
    mutating func next() {
      switch self {
      case .Zero:
        self = .One
      case .One:
        self = .Two
      case .Two:
        self = .Three
      case .Three:
        print("Done")
      }
    }
    mutating func last() {
      switch self {
      case .Zero:
        print("error")
      case .One:
        self = .Zero
      case .Two:
        self = .One
      case .Three:
        self = .Two
      }
    }
  }
  
  
  var textViewWidth: CGFloat?
  var step: Step = .One
  var mode: Mode = .None
  
  
  @IBOutlet weak var bg: UIView!
  @IBOutlet weak var ava: UIImageView!
  @IBOutlet weak var pass: UIImageView!
  @IBOutlet weak var email: UIImageView!
  @IBOutlet weak var backBg: UIView!
  @IBOutlet weak var bgCenterY: NSLayoutConstraint!
  @IBOutlet weak var back: UIButton!
  @IBOutlet weak var signin: UIButton!
  @IBOutlet weak var signinBg: UIView!
  @IBOutlet weak var welcome: UILabel!
  @IBOutlet weak var textfield: UITextField!
  @IBOutlet weak var nextTrailing: NSLayoutConstraint!
  @IBOutlet weak var nextBtn: UIButton!
  @IBOutlet weak var signup: UIButton!
  @IBOutlet weak var avaLeading: NSLayoutConstraint!
  @IBOutlet weak var emailLeading: NSLayoutConstraint!
  @IBOutlet weak var passLeading: NSLayoutConstraint!
  @IBOutlet weak var textview: UITextView!
  @IBOutlet weak var label: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    makeViewToRoundCorner(view: bg)
    makeViewToRoundCorner(view: pass)
    makeViewToRoundCorner(view: email)
    makeViewToRoundCorner(view: ava)
    makeViewToRoundCorner(view: backBg)
    makeViewToRoundCorner(view: signinBg)
    textview.delegate = self
    textfield.delegate = self
    ava.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
    email.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
    pass.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
    welcome.alpha = 0
    label.alpha = 0
    textfield.alpha = 0
    textview.alpha = 0
    backBg.alpha = 0
    back.alpha = 0
    UIView.animate(withDuration: 1.2, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
      self.bg.transform = CGAffineTransform(scaleX: 0.7 , y: 1.0)
      self.bg.transform = CGAffineTransform.identity
    }, completion: nil)
    UIView.animate(withDuration: 1.2, delay: 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: [], animations: {
            self.signinBg.transform = CGAffineTransform(scaleX: 0.7 , y: 1.0)
      self.signinBg.transform = CGAffineTransform.identity

    }, completion: nil)

  }
  
  
  func makeViewToRoundCorner(view: UIView) {
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.cornerRadius = bg.bounds.size.height/2
    view.clipsToBounds = true
  }
  
  @IBAction func signinBtnPressed(_ sender: UIButton) {
    textview.becomeFirstResponder()
    mode = .SignIn
    signinBg.alpha = 0
    signup.alpha = 0
    backBg.alpha = 1
    self.distant = signinBg.center.y - bg.center.y
    bgCenterY.constant = self.distant
    self.view.layoutIfNeeded()
    initialAnimation()
    UIView.animate(withDuration: 0.5, animations: {
      self.back.alpha = 1
    }, completion: { Void in
    })
  }
  
  @IBAction func signupBtnPressed(_ sender: UIButton) {
    textview.becomeFirstResponder()
    mode = .SignUp
    UIView.animate(withDuration: 0.1, animations: {
      self.signinBg.alpha = 0
    })
    UIView.animate(withDuration: 0.5, animations: {
      self.back.alpha = 1
      self.backBg.alpha = 1
      self.distant = self.signinBg.center.y - self.bg.center.y
      self.bgCenterY.constant = self.distant
      self.view.layoutIfNeeded()
    }, completion: { Void in
      
    })
    initialAnimation()
  }
  
  
  @IBAction func backBtnPressed(_ sender: UIButton) {
    switch step {
    case .Zero:
      print("error")
    case .One:
      mode = .None
      textview.resignFirstResponder()
      textview.text = ""
      bg.alpha = 0
      back.alpha = 0
      backBg.alpha = 0
      signup.alpha = 1
      label.alpha = 0
      textview.alpha = 0
      avaLeading.constant = -100
      emailLeading.constant = -100
      passLeading.constant = -100
      nextTrailing.constant = -100
      ava.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
      email.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
      pass.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
      
      
      
      if mode == .SignIn {
        bgCenterY.constant = -distant
      }else{
        bgCenterY.constant = 0
      }
      self.view.layoutIfNeeded()
      
      UIView.animate(withDuration: 0.5, animations: {
        self.signin.alpha = 1
        self.signinBg.alpha = 1
        self.bg.alpha = 1
      })
    case .Two:
      step.last()
      label.text = "Username"
      textfield.text = ""
      textfield.alpha = 0
      textview.text = ""
      textview.alpha = 1
      UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
        self.avaLeading.constant = 0
        self.view.layoutIfNeeded()
      }, completion: { Void in
        self.textview.becomeFirstResponder()
      })
      UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
        self.ava.transform = CGAffineTransform(rotationAngle: CGFloat.pi/6)
        self.ava.transform = CGAffineTransform.identity
      }, completion: nil)
    case .Three:
      if mode == .SignUp {
        step.last()
        label.text = "Password"
        textview.text = ""
        textview.alpha = 0
        textfield.alpha = 1
        textfield.text = ""
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
          self.passLeading.constant = 0
          self.view.layoutIfNeeded()
        }, completion: { Void in
          self.textfield.becomeFirstResponder()
        })
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
          self.pass.transform = CGAffineTransform(rotationAngle: CGFloat.pi/6)
          self.pass.transform = CGAffineTransform.identity
        }, completion: nil)
      }
    }
  }
  
  @IBAction func next(_ sender: Any) {
    returnBtnPressed()
  }
  
  
  @IBAction func didChanged(_ sender: UITextField) {
    textfield.sizeToFit()
    textview.text = textfield.text
    print(textview.text)
    self.view.layoutIfNeeded()
  }
  
  func returnBtnPressed() {
    if textview.text == "" {
      shakeAnimation(view: bg)
      return
    }
    switch step {
    case .Zero:
      print("error")
    case .One:
      username = textview.text
      textfield.becomeFirstResponder()
      animate(view: ava, withLabel: "Password", withLeading: avaLeading, step: step)
    case .Two:
      password = textfield.text
      if mode == .SignIn {
        textfield.resignFirstResponder()
        signIn()
      }else{
        textview.becomeFirstResponder()
        animate(view: pass, withLabel: "Email", withLeading: passLeading, step: step)
      }
    case .Three:
      emailAdress = textview.text
      if mode == .SignUp {
        textview.resignFirstResponder()
        signUp()
      }
    }
  }
}
//MARK: Signin Signup

extension SignInViewController {
  func signIn() {
    LilithProgressHUD.show()
    PFUser.logInWithUsername(inBackground: username!.lowercased(), password: password!) { (user:PFUser?, error) -> Void in
      if error == nil {
        
        // remember user or save in App Memeory did the user login or not
        UserDefaults.standard.set(user!.username, forKey: "username")
        UserDefaults.standard.synchronize()
        
        LilithProgressHUD.hide()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
        self.welcomeAnimation()
        
      } else {
        self.shakeAnimation(view: self.bg)
        // show alert message
        let alert = UIAlertController(title: "", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        LilithProgressHUD.hide()
      }
    }
  }
  
  func signUp() {
    LilithProgressHUD.show()
    // send data to server to related collumns
    let user = PFUser()
    user.username = username?.lowercased()
    user.password = password
    user.email = emailAdress
    user["likes"] = 0
    user["posts"] = 0
    user["nickname"] = username?.lowercased()
    user["bio"] = "bio"
    
    let imageData = UIImageJPEGRepresentation(UIImage(named: "ava")!, 0.5)
    let imageFile = PFFile(name: "ava", data: imageData!)
    user["ava"] = imageFile
    
    // save data in server
    user.signUpInBackground { (success, error) in
      guard error == nil else{
        LilithProgressHUD.hide()
        self.shakeAnimation(view: self.bg)
        // show alert message
        let alert = UIAlertController(title: "", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        return
      }
      
      
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
            LilithProgressHUD.hide()
            self.welcomeAnimation()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
            UserDefaults.standard.set(user.username, forKey: "username")
            UserDefaults.standard.synchronize()
            print("add new message suceess")
            
          }
        })
    }
  }
}

//MARK: Textview Textfield Delegates
extension SignInViewController: UITextFieldDelegate, UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    textViewWidth = textView.contentSize.width
    print(textView.text)
    
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      returnBtnPressed()
      return false
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    returnBtnPressed()
    return false
  }
}



//MARK: Animation
extension SignInViewController {
  func animate(view: UIImageView, withLabel: String, withLeading: NSLayoutConstraint, step: Step) {
    UIView.animate(withDuration: 0.3, animations: {
      self.textview.alpha = 0
      self.label.alpha = 0
      view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/12)
    })
    
    UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
      if step == .One {
        self.textfield.alpha = 1
        self.textview.alpha = 0
      }else if step == .Two{
        self.textfield.alpha = 0
        self.textview.alpha = 1
      }else{
        self.textview.alpha = 0
      }
      self.label.alpha = 1
      self.label.text = withLabel
      self.textview.text = ""
      self.textfield.text = ""
    }, completion: nil)
    
    UIView.animate(withDuration: 1.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.curveEaseIn], animations: {
      self.view.bringSubview(toFront: view)
      withLeading.constant = self.textViewWidth! + 150
      self.view.layoutIfNeeded()
    }, completion: { Void in
      self.step.next()
      withLeading.constant = -100
      view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
    })
  }
  
  
  func shakeAnimation(view: UIView) {
    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.9, options: [], animations: {
      view.transform = CGAffineTransform.identity
      view.transform = CGAffineTransform(translationX: 3, y: 0)
    }, completion: { Void in
      UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.9, options: [], animations: {
        view.transform = CGAffineTransform.identity
        view.transform = CGAffineTransform(translationX: -3, y: 0)
      }, completion: nil)
    })
  }
  
  func initialAnimation() {
    UIView.animate(withDuration: 0.05, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.1, options: [], animations: {
      self.bg.transform = CGAffineTransform(scaleX: 0.8 , y: 0.9)
    }, completion: { Void in
      UIView.animate(withDuration: 0.1, animations: {
        self.signup.alpha = 0
      })
      
      UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.1, options: [], animations: {
        self.email.transform = CGAffineTransform(rotationAngle: CGFloat.pi/6)
        self.email.transform = CGAffineTransform.identity
      }, completion: nil)
      UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.1, options: [], animations: {
        self.pass.transform = CGAffineTransform(rotationAngle: CGFloat.pi/6)
        self.pass.transform = CGAffineTransform.identity
      }, completion: nil)
      
      UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.1, options: [], animations: {
        self.ava.transform = CGAffineTransform(rotationAngle: CGFloat.pi/6)
        self.ava.transform = CGAffineTransform.identity
      }, completion: nil)
      
      UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: [], animations: {
        self.bg.transform = CGAffineTransform.identity
        self.label.alpha = 1
        self.textview.alpha = 1
        self.emailLeading.constant = 0
        self.nextTrailing.constant = 0
        self.view.layoutIfNeeded()
      }, completion: { Void in
      })
      UIView.animate(withDuration: 1.0, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
        self.passLeading.constant = 0
        self.view.layoutIfNeeded()
      }, completion: { Void in
      })
      
      UIView.animate(withDuration: 1.0, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: [], animations: {
        self.avaLeading.constant = 0
        self.view.layoutIfNeeded()
      }, completion: { Void in
      })
    })
    
  }
  
  func welcomeAnimation() {
    UIView.animate(withDuration: 2.0, animations: {
      self.ava.alpha = 0
      self.bg.alpha = 0
      self.textfield.alpha = 0
      self.textview.alpha = 0
      self.email.alpha = 0
      self.pass.alpha = 0
      self.nextBtn.alpha = 0
      self.back.alpha = 0
      self.backBg.alpha = 0
      self.welcome.alpha = 1
      self.welcome.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }, completion: { Void in
      let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.login()
    })
  }
}




