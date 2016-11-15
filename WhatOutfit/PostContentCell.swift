//
//  PostContent.swift
//  WhatOutfitTimelinePage
//
//  Created by Qinyuan Li on 16/10/26.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse

protocol postCellDelegate {
  func updateLikeBtn(index: Int, isliked: Bool)
  func performSegue(identifier: String, index: Int)
}

enum operation {
  case delete
  case add
}

class PostContentCell: UITableViewCell {
  
  var delegate: postCellDelegate?
  var pid: String?
  var index: Int!
  var isLiked: Bool?
  var likes: Int?
  
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
    delegate?.performSegue(identifier: "showDetail", index: index)
    print("Single Tapped")
  }
  
  func handleDoubleTap(_ sender: UITapGestureRecognizer) {
    if let isLiked = isLiked {
      if isLiked {
        updateLikeRelation(operation: operation.delete, cell: self)
        delegate?.updateLikeBtn(index: index, isliked: false)
      }else {
        likeAnimation(center: self.contentImage.center)
        updateLikeRelation(operation: operation.add, cell: self)
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
}




