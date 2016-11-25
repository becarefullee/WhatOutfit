//
//  Utility.swift
//  UserProfilePage
//
//  Created by Becarefullee on 16/10/25.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import Foundation
import UIKit
import Parse

public let greenColor: UIColor = UIColor(red: 71/255, green: 216/255, blue: 14/255, alpha: 1)
public let defaultBlue: UIColor = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1)


public let likeImage = UIImage(named:"praised")
public let unlikeImage = UIImage(named:"praise")


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


func setBtnStyleToColor(sender: UIButton, color: UIColor, borderColor: UIColor) {
    sender.setBackgroundImage(imageWithColorToButton(color), for: UIControlState.normal)
    sender.setBackgroundImage(imageWithColorToButton(color), for: UIControlState.highlighted)
    sender.layer.borderColor = borderColor.cgColor
    sender.layer.borderWidth = 1.0
    sender.layer.cornerRadius = 3
    sender.layer.masksToBounds = true
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

//func updateLikeRelation(operation: operation, cell: PostContentCell) {
//  switch operation {
//  case .add:
//    //Add a like relation
//    let object = PFObject(className: "Like")
//    object["uid"] = PFUser.current()?.objectId!
//    object["pid"] = cell.pid!
//    object.saveInBackground { (success, error) in
//      if success {
//        cell.likeBtn.setImage(likeImage, for: .normal)
//        cell.likes = cell.likes! + 1
//        cell.numberOfLikes.text = "\(cell.converLikesToString(numberOfLikes: cell.likes!)) likes"
//        cell.isLiked = !cell.isLiked!
//        
//        print("Update Sucess")
//        
//        //CurrentUser's Likes plus one
//        PFUser.current()?.incrementKey("likes")
//        PFUser.current()?.saveInBackground(block: { (success, error) in
//          if success {
//            print("User likes update")
//          }
//        })
//        //Post's like plus one
//        let query = PFQuery(className: "Post")
//        query.getObjectInBackground(withId: cell.pid!, block: { (object, error) in
//          object?.incrementKey("likes")
//          object?.saveInBackground(block: { (success, error) in
//            if success {
//              print("Likes updated")
//            }else {
//              print(error!.localizedDescription)
//            }
//          })
//        })
//        
//      }else {
//        print(error!.localizedDescription)
//      }
//    }
//    
//  case .delete:
//    //Delete a like relation
//    let query = PFQuery(className: "Like")
//    query.whereKey("pid", equalTo: cell.pid)
//    query.whereKey("uid", equalTo: PFUser.current()?.objectId!)
//    query.findObjectsInBackground { (objects, error) in
//      if (objects?.count)! > 0 {
//        objects?.first?.deleteInBackground(block: { (success, error) in
//          if success {
//            cell.likeBtn.setImage(unlikeImage, for: .normal)
//            cell.likes = cell.likes! - 1
//            cell.numberOfLikes.text = "\(cell.converLikesToString(numberOfLikes: cell.likes!)) likes"
//            cell.isLiked = !cell.isLiked!
//            print("Delete Success")
//            
//            //CurrentUser's Likes minus one
//            PFUser.current()?.incrementKey("likes", byAmount: -1)
//            PFUser.current()?.saveInBackground(block: { (success, error) in
//              if success {
//                print("User likes update")
//              }
//            })
//            //Post's like minus one
//            let query = PFQuery(className: "Post")
//            query.getObjectInBackground(withId: cell.pid!, block: { (object, error) in
//              object?.incrementKey("likes", byAmount: -1)
//              object?.saveInBackground(block: { (success, error) in
//                if success {
//                  print("Likes updated")
//                }else {
//                  print(error!.localizedDescription)
//                }
//              })
//            })
//          }else {
//            print(error!.localizedDescription)
//          }
//        })
//      }
//    }
//  }
//}
