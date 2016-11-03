//
//  FollowCell.swift
//  WhatOutfit
//
//  Created by Becarefullee on 16/11/2.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse


class FollowCell: UITableViewCell {

  var index: Int?
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var avaImageView: UIImageView!
  @IBOutlet weak var nickNameLabel: UILabel!
  @IBOutlet weak var followBtn: UIButton!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    avaImageView.layer.cornerRadius = avaImageView.bounds.width/2
    avaImageView.clipsToBounds = true
  }
}
