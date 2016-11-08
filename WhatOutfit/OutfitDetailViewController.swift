//
//  OutfitDetailViewController.swift
//  WhatOutfit
//
//  Created by Becarefullee on 16/11/8.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//


// 1.Show the collection of the outfit
// 2.Be able to like the post
// 3.If the post belongs to current user, there should be a edit btn on the navigation bar
// 4.

import UIKit
import Parse



class OutfitDetailViewController: UITableViewController {

  
    var contentImageSet: [UIImage?] = []
    var avaImageSet: [UIImage?] = []
    var likes: [Int] = []
    var postId: [String] = []
    var likeBtn: [Bool?] = []
    var userNameArray: [String] = []
    var uid: [String] = []
    var dateArray: [Date] = []

    fileprivate var followGuest: String?
    fileprivate var toGuest: String?
    fileprivate var guestName: String?

    fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
    fileprivate let contentCellHeight: CGFloat = UIScreen.main.bounds.width + 44

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}



//MARK: TableView Datasource and delegate
extension OutfitDetailViewController {
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let cell = cell as! PostContentCell
    cell.numberOfLikes.text =  "\(cell.converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
    cell.contentImage.image = contentImageSet[indexPath.section]
    cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
    cell.likeBtn.setImage(unlikeImage, for: .normal)
    cell.selectionStyle = .none
    
    cell.delegate = self
    cell.likes = likes[indexPath.section]
    cell.index = indexPath.section
    cell.pid = postId[indexPath.section]
    if let isLiked = likeBtn[indexPath.section] {
      cell.isLiked = isLiked
      if isLiked {
        cell.likeBtn.setImage(likeImage, for: .normal)
      }else {
        cell.likeBtn.setImage(unlikeImage, for: .normal)
      }
    }
  }
  
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let headerCell = view as! HeaderCell
    headerCell.userId = uid[section]
    headerCell.profileImage.image = avaImageSet[section]
    headerCell.postTime.text =  headerCell.convertDateToString(date: self.dateArray[section])
    headerCell.userName.text = userNameArray[section]
    headerCell.backgroundColor = UIColor.white
    headerCell.alpha = 1.0
  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PostContentCell
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerCell = tableView.dequeueReusableCell(withIdentifier: "Header") as! HeaderCell
    headerCell.delegate = self
    return headerCell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return contentCellHeight
  }
}


//:MARK CellDelegate

extension OutfitDetailViewController: CellDelegate {
  func performSegue(identifier: String, guestId: String, guestName: String) {
    
    // Query follow realtion
    if PFUser.current()?.objectId != guestId {
      let query = PFQuery(className: "Follow")
      query.whereKey("follower", equalTo: PFUser.current()?.objectId!)
      query.whereKey("following", equalTo: guestId)
      query.countObjectsInBackground (block: { (count:Int32, error) -> Void in
        if error == nil {
          if count == 0 {
            self.followGuest = "FOLLOW"
          } else {
            self.followGuest = "FOLLOWING"
          }
        }
      })
    }
    toGuest = guestId
    self.guestName = guestName
    performSegue(withIdentifier: identifier, sender: self)
    print("Pass success!")
  }
}


extension OutfitDetailViewController: postCellDelegate {
  func updateLikeBtn(index: Int, isliked: Bool) {
    likeBtn[index] = isliked
    if isliked {
      likes[index] += 1
    }else {
      likes[index] -= 1
    }
  }
  func performSegue(identifier: String, index: Int) {
  }
}



//:MARK Segue

extension OutfitDetailViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showGuest" {
      let dvc = segue.destination as! GuestViewController
      dvc.guestId = toGuest
      dvc.userName = guestName
      dvc.follow = followGuest
    }
  }
}





