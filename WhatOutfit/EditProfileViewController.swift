//
//  EditProfileViewController.swift
//  WhatOutfit
//
//  Created by becarefullee on 2016/11/19.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UITableViewController, UITextFieldDelegate {
  
  fileprivate var isAvaChange: Bool = false
  fileprivate var username: String?
  fileprivate var imagePicker : UIImagePickerController!
  fileprivate var avaFile: PFFile?
  
  @IBOutlet weak var ava: UIImageView!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var nicknameTextField: UITextField!
  @IBOutlet weak var bioTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var mobileTextField: UITextField!
  

  @IBAction func avaTapped(_ sender: UITapGestureRecognizer) {
    print("tapped")
    let camera = FloatingAction(title: "Take a picture") { action in
      
      self.initWithImagePickView(type: "Camera")
    }
    camera.textColor = UIColor.black
    camera.tintColor = UIColor.white
    camera.font = UIFont(name: "Avenir-Light", size: 17)
    let ablum = FloatingAction(title: "Choose from album") { action in
      self.initWithImagePickView(type: "Album")
    }
    ablum.textColor = UIColor.black
    ablum.tintColor = UIColor.white
    ablum.font = UIFont(name: "Avenir-Light", size: 17)
    let group1 = FloatingActionGroup(action:camera,ablum)
    FloatingActionSheetController(actionGroup: group1,animationStyle:.slideRight)
      .present(in: self)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ava.layer.cornerRadius = 64
    ava.layer.masksToBounds = true
    tableView.keyboardDismissMode = .onDrag
    loadUserInfo()
  }
  
  @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
    self.view.endEditing(true)
    self.dismiss(animated: true, completion: nil)
  }
  @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
    self.view.endEditing(true)
    saveUserInfo()
  }
}



extension EditProfileViewController {
  func loadUserInfo() {
    let image = PFUser.current()?.object(forKey: "ava") as! PFFile
    image.getDataInBackground { (data, error) in
      self.ava.image = UIImage(data: data!)
    }
    usernameTextField.text = PFUser.current()?.username
    nicknameTextField.text = PFUser.current()?.object(forKey: "nickname") as! String?
    bioTextField.text = PFUser.current()?.object(forKey: "bio") as! String?
    emailTextField.text = PFUser.current()?.object(forKey: "email") as! String?
    mobileTextField.text = PFUser.current()?.object(forKey: "mobile") as! String?
  }
  
  func saveUserInfo() {
    username = PFUser.current()?.username
    let imageData = UIImageJPEGRepresentation(ava.image!, 0.1)
    avaFile = PFFile(name: "ava.jpg", data: imageData!)
    let user = PFUser.current()!
    user["username"] = usernameTextField.text
    user["nickname"] = nicknameTextField.text
    user["bio"] = bioTextField.text
    user["email"] = emailTextField.text
    user["mobile"] = mobileTextField.text
    user["ava"] = avaFile
    user.saveInBackground(block: { (success, error) in
      if success {
        self.view.endEditing(true)
        print("update success")
        if self.username != self.usernameTextField.text || self.isAvaChange {
          self.updatePost()
        }else{
          self.dismiss(animated: true, completion: nil)
        }
      }
      else{
        print(error!.localizedDescription)
      }
    })
  }
  
  func updatePost() {
    let query = PFQuery(className: "Post")
    query.whereKey("username", equalTo: username as Any)
    query.findObjectsInBackground { (objects, error) in
      if error == nil {
        for object in objects! {
          if self.username != self.usernameTextField.text {
            object["username"] = self.usernameTextField.text
          }
          if self.isAvaChange {
            object["ava"] = self.avaFile
          }
        }
        PFObject.saveAll(inBackground: objects, block: { (success, error) in
          if success {
            print("update name in post")
            self.isAvaChange = false
            self.dismiss(animated: true, completion: nil)
          }
        })
      }else{
        print(error!.localizedDescription)
      }
    }
  }
}


extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func initWithImagePickView(type:String){
    self.imagePicker = UIImagePickerController()
    self.imagePicker.delegate = self
    self.imagePicker.allowsEditing = true
    
    switch type{
    case "Camera":
      self.imagePicker.sourceType = .camera
    case "Album":
      self.imagePicker.sourceType = .photoLibrary
    default:
      print("error")
    }
    present(self.imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      ava.image = image
      isAvaChange = true
    } else{
      print("Something went wrong")
    }
    imagePicker.dismiss(animated: true, completion: { _ in
    })
  }
}


extension EditProfileViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 2 && indexPath.row == 1 {
      PFUser.logOutInBackground { (error) -> Void in
        if error == nil {
          UserDefaults.standard.removeObject(forKey: "username")
          UserDefaults.standard.synchronize()
          
          self.view.endEditing(true)
          let signin = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
          let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
          appDelegate.window?.rootViewController = signin
          
        }
      }

    }
  }
}

