//
//  LikeMessageCell.swift
//  WhatOutfit
//
//  Created by becarefullee on 2016/11/24.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit

class LikeMessageCell: UITableViewCell {

  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var ava: UIButton!

  @IBOutlet weak var thumbnail: UIButton!
  @IBOutlet weak var username: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    ava.layer.cornerRadius = ava.bounds.width/2
    ava.clipsToBounds = true
    thumbnail.imageView?.contentMode = .scaleAspectFill
  }
}
