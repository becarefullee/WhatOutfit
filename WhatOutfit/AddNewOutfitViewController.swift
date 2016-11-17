//
//  AddNewOutfit.swift
//  WhatOutfit
//
//  Created by Qinyuan Li on 16/10/30.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse

class AddNewOutfitViewController: UIViewController {

  fileprivate var outfit: [PFFile] = []
  fileprivate var ableToAddMore: Bool = true
  fileprivate let plusBtn: UIImage = UIImage(named: "plus")!
  fileprivate var post: Post?
  fileprivate var imageSet: [UIImage] = []
  fileprivate var imagePicker : UIImagePickerController!
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate var cellWidth: CGFloat {
    return (screenWidth - 50) / 2
  }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSet.append(plusBtn)
        outfitCollectionView.dataSource = self
        outfitCollectionView.delegate = self
        if let navigationController = navigationController {
        navigationController.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController.navigationBar.isTranslucent = false
      }


    }
  @IBOutlet weak var outfitCollectionView: UICollectionView!


  @IBAction func cancel(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
    ableToAddMore = true
    print("cancel")

  }
  
  @IBAction func done(_ sender: UIBarButtonItem) {
    guard imageSet.count > 1 else {
      let alert = UIAlertController(title: "PLEASE", message: "upload at least one item", preferredStyle: UIAlertControllerStyle.alert)
      let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
      alert.addAction(ok)
      self.present(alert, animated: true, completion: nil)
      return
    }
  ableToAddMore = true
  print("done")
  
  // Update posts
  let user = PFUser.current()
  var posts = user?["posts"] as! Int
  posts = posts + 1
  user?["posts"] = posts
  user?.saveInBackground()
  
  //Upload post
  let object = PFObject(className: "Post")
  object["uid"] = PFUser.current()?.objectId!
  object["username"] = PFUser.current()?.username!
  object["ava"] = PFUser.current()?.value(forKey: "ava") as? PFFile
  object["likes"] = 0
    for i in 0..<imageSet.count-1 {
      let imageData = UIImageJPEGRepresentation(imageSet[i], 0.5)
      let imageFile = PFFile(name: "post.jpg", data: imageData!)
      outfit.append(imageFile!)
    }
  object["pic"] = outfit.first
  object["outfits"] = outfit as? NSArray
  object.saveInBackground (block: { (success:Bool, error) -> Void in
    if error == nil {
      print("Saved successfully!")
      self.dismiss(animated: true, completion: nil)
      }
    })
  }
}

extension AddNewOutfitViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
      imageSet.insert(image, at: imageSet.count-1)
     
    } else{
      print("Something went wrong")
    }
    imagePicker.dismiss(animated: true, completion: { _ in
      if self.imageSet.count == 5 {
//        self.imageSet.removeLast()
        self.ableToAddMore = false
      }
      
      
      self.outfitCollectionView.reloadData()
    })
  }
}


extension AddNewOutfitViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if imageSet.count > 4 {
      return 4
    } else {
      return imageSet.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = outfitCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCell
    print(indexPath.row)
    cell.imageView.image = imageSet[indexPath.row]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("select\(indexPath.row)")
    if indexPath.row != imageSet.count - 1{
      print("Image")
    }else{
      if ableToAddMore {
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
    }
  }
}


extension AddNewOutfitViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: cellWidth, height: cellWidth)
  }
  
}
