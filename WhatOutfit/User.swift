//
//  User.swift
//  UserProfilePage
//
//  Created by Becarefullee on 16/10/25.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import Foundation
import  UIKit


struct User {
  
  var nickName: String
  var userName: String
  var whatsup: String
  var numberOfPosts: Int
  var numberOfFollowers: Int
  var numberOfFollowing: Int
  var numberOfLikes: Int
  
  init(nickName: String = "", userName: String, whatsup: String = "", numberOfPosts: Int = 0,  numberOfFollowers: Int = 0, numberOfFollowing: Int = 0, numberOfLikes: Int = 0) {
    self.nickName = nickName
    self.userName = userName
    self.whatsup = whatsup
    self.numberOfLikes = numberOfLikes
    self.numberOfPosts = numberOfPosts
    self.numberOfFollowers = numberOfFollowers
    self.numberOfFollowing = numberOfFollowing
  }
  
  var outfits: [UIImage] = []
  var likes: [UIImage] = []
  var profilePicture: UIImage?
  
  
}
