//
//  Post.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import Foundation
import UIKit
import Parse

struct Post {
  
  
  var profileImage: PFFile
  var userName: String
  var postTime: Date
  var contentImage: PFFile
  var numberOfLikes: Int
  var likedByCurrentUser: Bool
  var outfit: [UIImage]
  
  init(userName: String, postTime: Date, numberOfLikes: Int, profileImage: PFFile, contentImage: PFFile, likedByCurrentUser: Bool = false, outfit: [UIImage] = []) {
    self.userName = userName
    self.postTime = postTime
    self.numberOfLikes = numberOfLikes
    self.profileImage = profileImage
    self.contentImage = contentImage
    self.likedByCurrentUser = likedByCurrentUser
    self.outfit = outfit
  }
  
}
