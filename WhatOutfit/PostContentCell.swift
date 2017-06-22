//
//  PostContent.swift
//  WhatOutfitTimelinePage
//
//  Created by Qinyuan Li on 16/10/26.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse


enum operation {
  case delete
  case add
}

class PostContentCell: UITableViewCell {
  
  var delegate: UpdateLike?
  var pid: String?
  var index: Int!
  var isLiked: Bool?
  var likes: Int?
  var postOwnerId: String?
  
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  
  @IBOutlet weak var contentImage: UIImageView!
  @IBOutlet weak var likeBtn: UIButton!
  @IBOutlet weak var numberOfLikes: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    contentImage.bounds.size.width = screenWidth
    contentImage.bounds.size.height = screenWidth
    contentImage.isUserInteractionEnabled = true

    let singleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
    let doubleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
    singleTapRecognizer.numberOfTapsRequired = 1
    doubleTapRecognizer.numberOfTapsRequired = 2
    singleTapRecognizer.require(toFail: doubleTapRecognizer)
    contentImage.addGestureRecognizer(singleTapRecognizer)
    contentImage.addGestureRecognizer(doubleTapRecognizer)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
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
        likeAnimation(center: self.contentImage.center)
        updateLikeRelation(operation: operation.add)
        delegate?.updateLikeBtn(index: index, isliked: true, needReload: false)
      }
    }
  }
  
  
  func likeAnimation(center: CGPoint) {
    let newView = UIImageView(image:UIImage(named: "praised_1"))
    newView.center = center
    newView.alpha = 0
    contentImage.addSubview(newView)
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
      let query = PFQuery(className: "Like")
      query.whereKey("uid", equalTo: PFUser.current()?.objectId as Any)
      query.whereKey("pid", equalTo: self.pid as Any)
      query.findObjectsInBackground(block: { (objects, error) in
        guard objects?.count == 0 else {
          print("Like relation already exist!")
          return
        }
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
      })

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
      let data = UIImageJPEGRepresentation(contentImage.image!, 0.5)
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
          
          PFCloud.callFunction(inBackground: "pushLikeNotification", withParameters: ["name": PFUser.current()?.username, "target": self.postOwnerId!], block: { (object, error) in
            guard error == nil else {
              print(error?.localizedDescription)
              return
            }
            print("Push success!")
          })
          
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




