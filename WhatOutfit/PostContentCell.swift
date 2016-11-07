//
//  PostContent.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse

protocol postCellDelegate {
  func updateLikeBtn(index: Int, isliked: Bool)
}


class PostContentCell: UITableViewCell {
  
  enum operation {
    case delete
    case add
  }
  
  var delegate: postCellDelegate?
  var pid: String?
  var index: Int!
  var isLiked: Bool?
  var likes: Int?
  
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate let likeImage = UIImage(named:"praised")
  fileprivate let unlikeImage = UIImage(named:"praise")
  
  
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
  
  func converLikesToString(numberOfLikes: Int) -> String{
    var number:String = String(numberOfLikes)
    switch numberOfLikes {
    case 0..<1000:
      return number
    case 1000..<1000000:
      let index = number.index(number.endIndex, offsetBy: -3)
      number.insert(",", at: index)
      return number
    case 1000000..<1000000000:
      var index = number.index(number.endIndex, offsetBy: -3)
      number.insert(",", at: index)
      index = number.index(number.endIndex, offsetBy: -7)
      number.insert(",", at: index)
      return number
    default:
      return number
      
    }
  }
  
  func handleSingleTap(_ sender: UITapGestureRecognizer) {
    //    performSegue(withIdentifier: "showDetail", sender: sender)
    print("Single Tapped")
  }
  func handleDoubleTap(_ sender: UITapGestureRecognizer) {
    if let isLiked = isLiked {
      if isLiked {
        updateLikeRelation(operation: operation.delete)
        delegate?.updateLikeBtn(index: index, isliked: false)
      }else {
        likeAnimation(center: self.contentImage.center)
        updateLikeRelation(operation: operation.add)
        delegate?.updateLikeBtn(index: index, isliked: true)
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
      //Add a like relation
      let object = PFObject(className: "Like")
      object["uid"] = PFUser.current()?.objectId!
      object["pid"] = pid!
      object.saveInBackground { (success, error) in
        if success {
          self.likeBtn.setImage(self.likeImage, for: .normal)
          self.likes = self.likes! + 1
          self.numberOfLikes.text = "\(self.converLikesToString(numberOfLikes: self.likes!)) likes"
          self.isLiked = !self.isLiked!
          
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
      query.whereKey("pid", equalTo: pid)
      query.whereKey("uid", equalTo: PFUser.current()?.objectId!)
      query.findObjectsInBackground { (objects, error) in
        if (objects?.count)! > 0 {
          objects?.first?.deleteInBackground(block: { (success, error) in
            if success {
              self.likeBtn.setImage(self.unlikeImage, for: .normal)
              self.likes = self.likes! - 1
              self.numberOfLikes.text = "\(self.converLikesToString(numberOfLikes: self.likes!)) likes"
              self.isLiked = !self.isLiked!
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
  
  
}




