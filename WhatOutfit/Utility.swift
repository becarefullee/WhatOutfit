//
//  Utility.swift
//  UserProfilePage
//
//  Created by Becarefullee on 16/10/25.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import Foundation
import UIKit


func imageWithColorToButton(_ colorButton: UIColor) -> UIImage {
    let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context: CGContext = UIGraphicsGetCurrentContext()!
    context.setFillColor(colorButton.cgColor)
    context.fill(rect)
    let imageReturn: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return imageReturn
}


func setBtnStyleToGrayColor(sender: UIButton, color: UIColor) {
    sender.setBackgroundImage(imageWithColorToButton(color), for: UIControlState.normal)
    sender.setBackgroundImage(imageWithColorToButton(color), for: UIControlState.highlighted)
    sender.layer.borderColor = color.cgColor
    sender.layer.borderWidth = 1.0
    sender.layer.cornerRadius = 2
    sender.layer.masksToBounds = true
}

