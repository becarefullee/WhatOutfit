//
//  PostContent.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit

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
    }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    }
  
  func configure(post: Post, index: Int) {
  //  contentImage.image = post.contentImage
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
}




