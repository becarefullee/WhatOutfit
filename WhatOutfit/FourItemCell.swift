//
//  FourItemCell.swift
//  WhatOutfit
//
//  Created by becarefullee on 2016/11/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit

import UIKit
import Parse

class FourItemCell: UITableViewCell {
  
  @IBOutlet weak var firstImage: UIImageView!
  @IBOutlet weak var secondImage: UIImageView!
  @IBOutlet weak var thirdImage: UIImageView!
  @IBOutlet weak var fourthImage: UIImageView!
  @IBOutlet weak var likeBtn: UIButton!
  @IBOutlet weak var numberOfLikes: UILabel!
  @IBOutlet weak var collage: UIStackView!
  var delegate: UpdateLike?
  var pid: String?
  var index: Int!
  var isLiked: Bool?
  var likes: Int?
  var postOwnerId: String?
  
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let singleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
    let doubleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
    singleTapRecognizer.numberOfTapsRequired = 1
    doubleTapRecognizer.numberOfTapsRequired = 2
    singleTapRecognizer.require(toFail: doubleTapRecognizer)
    collage.addGestureRecognizer(singleTapRecognizer)
    collage.addGestureRecognizer(doubleTapRecognizer)
  }
  
  func handleSingleTap(_ sender: UITapGestureRecognizer) {
    delegate?.performSegue(identifier: "showDetail", index: index)
    print("Single Tapped")
  }
  
  func handleDoubleTap(_ sender: UITapGestureRecognizer) {
    if let isLiked = isLiked {
      print(isLiked)
      if isLiked {
        updateLikeRelation(operation: operation.delete)
        delegate?.updateLikeBtn(index: index, isliked: false, needReload: false)
      }else {
        likeAnimation(center: self.collage.center)
        updateLikeRelation(operation: operation.add)
        delegate?.updateLikeBtn(index: index, isliked: true, needReload: false)
      }
    }
  }
  
  func likeAnimation(center: CGPoint) {
    let newView = UIImageView(image:UIImage(named: "praised_1"))
    newView.center = center
    newView.alpha = 0
    collage.addSubview(newView)
    self.bringSubview(toFront: newView)
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.3, options: [], animations: {
      newView.alpha = 1
      newView.transform = CGAffineTransform(scaleX: 2.3, y: 2.3)
      
    }) { (finished) in
      UIView.animate(withDuration: 0.3, animations: {
        newView.alpha = 0
        newView.transform = CGAffineTransform.identity
        newView.transform = CGAffineTransform(scaleX: 1/2.3, y: 1/2.3)
      }, completion: { (finished) in
        newView.removeFromSuperview()
      })
    }
  }
  
  func updateLikeRelation(operation: operation) {
    switch operation {
    case .add:
      //Add a like relation
      let object = PFObject(className: "Like")
      object["uid"] = PFUser.current()?.objectId!
      object["pid"] = self.pid!
      object.saveInBackground { (success, error) in
        if success {
          self.likeBtn.setImage(likeImage, for: .normal)
          self.likes = self.likes! + 1
          self.numberOfLikes.text = "\(converLikesToString(numberOfLikes: self.likes!)) likes"
          self.isLiked = !self.isLiked!
          self.addLikeMessage()
          print("Update Sucess")
          
          //CurrentUser's Likes plus one
          PFUser.current()?.incrementKey("likes")
          PFUser.current()?.saveInBackground(block: { (success, error) in
            if success {
              print("User likes update")
            }
          })
          //Post's like plus one
          let query = PFQuery(className: "Post")
          query.getObjectInBackground(withId: self.pid!, block: { (object, error) in
            object?.incrementKey("likes")
            object?.saveInBackground(block: { (success, error) in
              if success {
                print("Likes updated")
              }else {
                print(error!.localizedDescription)
              }
            })
          })
          
        }else {
          print(error!.localizedDescription)
        }
      }
      
    case .delete:
      //Delete a like relation
      let query = PFQuery(className: "Like")
      query.whereKey("pid", equalTo: self.pid as Any)
      query.whereKey("uid", equalTo: PFUser.current()?.objectId! as Any)
      query.findObjectsInBackground { (objects, error) in
        if (objects?.count)! > 0 {
          objects?.first?.deleteInBackground(block: { (success, error) in
            if success {
              self.likeBtn.setImage(unlikeImage, for: .normal)
              self.likes = self.likes! - 1
              self.numberOfLikes.text = "\(converLikesToString(numberOfLikes: self.likes!)) likes"
              self.isLiked = !self.isLiked!
              self.deleteLikeMessage()
              print("Delete Success")
              
              //CurrentUser's Likes minus one
              PFUser.current()?.incrementKey("likes", byAmount: -1)
              PFUser.current()?.saveInBackground(block: { (success, error) in
                if success {
                  print("User likes update")
                }
              })
              //Post's like minus one
              let query = PFQuery(className: "Post")
              query.getObjectInBackground(withId: self.pid!, block: { (object, error) in
                object?.incrementKey("likes", byAmount: -1)
                object?.saveInBackground(block: { (success, error) in
                  if success {
                    print("Likes updated")
                  }else {
                    print(error!.localizedDescription)
                  }
                })
              })
            }else {
              print(error!.localizedDescription)
            }
          })
        }
      }
    }
  }
  
  func addLikeMessage() {
    if PFUser.current()?.objectId != postOwnerId {
      let data = UIImageJPEGRepresentation(firstImage.image!, 0.5)
      let file = PFFile(data: data!)
      let message = PFObject(className: "Message")
      message["from"] = PFUser.current()?.objectId
      message["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
      message["to"] = postOwnerId! as String
      message["pid"] = pid! as String
      message["pic"] = file! as PFFile
      message["type"] = "like"
      message.saveInBackground(block: { (success, error) in
        if success {
          print("add new message suceess")
        }
      })
    }
  }
  
  func deleteLikeMessage() {
    let query = PFQuery(className: "Message")
    query.whereKey("from", equalTo: PFUser.current()?.objectId as Any)
    query.whereKey("pid", equalTo: pid as Any)
    query.findObjectsInBackground { (objects, error) in
      if error == nil {
        for object in objects! {
          object.deleteInBackground(block: { (success, error) in
            if success {
              print("delete message success")
            }
          })
        }
      }else{
        print(error!.localizedDescription)
      }
    }
  }
  
}

