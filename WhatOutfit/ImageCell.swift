//
//  ImageCell.swift
//  UserProfilePage
//
//  Created by Qinyuan Li on 16/10/25.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  
  override func prepareForReuse() {
    imageView.image = nil
  }
  
}
