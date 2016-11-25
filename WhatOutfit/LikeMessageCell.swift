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
  @IBOutlet weak var thumbnail: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var ava: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
