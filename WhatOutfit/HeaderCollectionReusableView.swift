//
//  HeaderCollectionReusableView.swift
//  UserProfilePage
//
//  Created by Qinyuan Li on 16/10/25.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
  
  
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var whatsupLabel: UILabel!
  
  @IBOutlet weak var numberOfPosts: UIButton!
  @IBOutlet weak var numberOfLikes: UIButton!
  @IBOutlet weak var numberOfFollowing: UIButton!
  @IBOutlet weak var numberOfFollowers: UIButton!
  
  @IBOutlet weak var editProfile: UIButton!
  @IBOutlet weak var outfitsBtn: UIButton!
  @IBOutlet weak var likesBtn: UIButton!

  
  override func awakeFromNib() {
      super.awakeFromNib()
      profilePicture.layer.cornerRadius = 8
      profilePicture.layer.borderWidth = 1
      profilePicture.layer.masksToBounds = true
    
    
    
  }
  
  
  func configureProfile(userInfo: User) {
    profilePicture.image = userInfo.profilePicture
    nameLabel.text = userInfo.nickName
    whatsupLabel.text = userInfo.whatsup
    numberOfFollowing.setTitle("\(userInfo.numberOfFollowing)", for: .normal)
    numberOfFollowers.setTitle("\(userInfo.numberOfFollowers)", for: .normal)
    numberOfPosts.setTitle("\(userInfo.numberOfPosts)", for: .normal)
    numberOfLikes.setTitle("\(userInfo.numberOfLikes)", for: .normal)
    
  }
  
  
}
