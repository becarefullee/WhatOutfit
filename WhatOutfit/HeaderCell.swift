//
//  HeaderCell.swift
//  WhatOutfitTimelinePage
//
//  Created by Qinyuan Li on 16/10/26.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse

class HeaderCell: UITableViewCell {

  var userId: String?
  var headerInfo: Post?
  var delegate: CellDelegate?
  var guestName: String?
  
  
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var postTime: UILabel!
  @IBOutlet weak var userName: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 16
        profileImage.clipsToBounds = true
        let singleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTapRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapRecognizer)
    }

  
  func handleSingleTap(_ sender: UITapGestureRecognizer) {
    
    if let delegate = delegate {
      delegate.performSegue(identifier: "showGuest", guestId: userId!, guestName: userName.text!)
    }
    print("Single Tapped")
  }  
}

