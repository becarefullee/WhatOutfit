//
//  HeaderCell.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse



protocol CellDelegate {
  
  func performSegue(identifier: String, guestId: String, guestName: String)
  
  
}



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
    
    if var delegate = delegate {
      delegate.performSegue(identifier: "showGuest", guestId: userId!, guestName: userName.text!)
    }
    print("Single Tapped")
  }
  
  
  
  func convertDateToString(date:Date) -> String {
    let currentTime = Date()
    let calendar = Calendar.current
    let components: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year]
    let result = calendar.dateComponents(components, from: date, to: currentTime)
    let year = result.year
    let month = result.month
    let day = result.day
    let hour = result.hour
    let min = result.minute
    if year != 0 {
      if year == 1 {
        return "1 YEAR AGO"
      }
      return "\(year!) YEARS AGO"
    }
    if month != 0 {
      if month == 1 {
        return "1 MONTH AGO"
      }
      return "\(month!) MONTHS AGO"
    }
    if day != 0 {
      if day == 1 {
        return "1 DAY AGO"
      }
      return "\(day!) DAYS AGO"
    }
    if hour != 0 {
      if hour == 1 {
        return "1 HOUR AGO"
      }
      return "\(hour!) HOURS AGO"
    }
    if min != 0 {
      if min == 1 {
        return "1 MININUTE AGO"
      }
      return "\(min!) MINUTES AGO"
    }
    return "1 MININUTE AGO"
  }
  
}

