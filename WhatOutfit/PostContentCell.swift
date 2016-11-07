//
//  PostContent.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse

class PostContentCell: UITableViewCell {

  var index: Int!
  var post: Post?
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
  
  func configure(post: Post, index: Int) {
    
  //  contentImage.image = post.contentImage
    post.contentImage.getDataInBackground { (data, error) in
      self.contentImage.image = UIImage(data: data!)
    }
    numberOfLikes.text = "\(converLikesToString(numberOfLikes: post.numberOfLikes)) likes"
    self.index = index
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
    print(self.center)
    likeAnimation(center: self.contentImage.center)
//    let cell = sender.view?.superview?.superview as! PostContentCell
//    let id: Int = cell.index
//    dataSource[id].likedByCurrentUser = !dataSource[id].likedByCurrentUser
//    if dataSource[id].likedByCurrentUser {
//      likeAnimation(center: cell.center)
//      cell.likeBtn.setImage(likeImage, for: .normal)
//      dataSource[id].numberOfLikes += 1
//    }else {
//      cell.likeBtn.setImage(unlikeImage, for: .normal)
//      dataSource[id].numberOfLikes -= 1
//    }
//    let index = [IndexPath(item: 0, section: id)]
//    tableView.reloadRows(at: index, with: .none)
//    print("Double Tapped")
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

  
  
  
}




