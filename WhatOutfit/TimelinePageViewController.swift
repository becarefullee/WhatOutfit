//
//  TimelinePageViewController.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse

fileprivate let reuseIdentifier = "Cell"
fileprivate let likeImage = UIImage(named:"praised")
fileprivate let unlikeImage = UIImage(named:"praise")


class TimelinePageViewController: UITableViewController {
  
  
  var contentImageSet: [UIImage?] = []
  var avaImageSet: [UIImage?] = []
  
  fileprivate var followGuest: String?
  fileprivate var toGuest: String?
  fileprivate var guestName: String?
  
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate var dataSource = [Post]()
  fileprivate let contentCellHeight: CGFloat = UIScreen.main.bounds.width + 44
  
  fileprivate var likeBtn: [Bool?] = []
  fileprivate var userNameArray: [String] = []
  fileprivate var avaArray: [PFFile] = []
  fileprivate var postId: [String] = []
  fileprivate var uid: [String] = []
  fileprivate var followArray: [String] = []
  fileprivate var dateArray: [Date] = []
  fileprivate var picArray: [PFFile] = []
  fileprivate var likes: [Int] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpForNavigationBar()
    setUpRefreshControl()
    loadPosts()
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let statusView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 20))
    statusView.backgroundColor = UIColor.white
    UIApplication.shared.keyWindow?.addSubview(statusView)
  }
  
  
  
  func refresh(_ sender: AnyObject?) {
    loadPosts()
    if #available(iOS 10.0, *) {
      self.tableView.refreshControl?.endRefreshing()
    } else {
      // Fallback on earlier versions
    }
  }
  
  
  @IBAction func likeBtnPressed(_ sender: UIButton) {
    let id: Int = Int(sender.title(for: .normal)!)!
    dataSource[id].likedByCurrentUser = !dataSource[id].likedByCurrentUser
    if dataSource[id].likedByCurrentUser {
      sender.setImage(likeImage, for: .normal)
      dataSource[id].numberOfLikes += 1
    }else {
      sender.setImage(unlikeImage, for: .normal)
      dataSource[id].numberOfLikes -= 1
    }
    tableView.reloadData()
  }
  
  
}

//:MARK Initialization
extension TimelinePageViewController {
  func setUpForNavigationBar() {
    if let navigationController = navigationController {
      navigationController.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
      navigationController.navigationBar.isTranslucent = false
    }
  }
  
  func setUpRefreshControl() {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    if #available(iOS 10.0, *) {
      self.tableView.refreshControl = refreshControl
    } else {
      // Fallback on earlier versions
    }
  }
}


//:MARK CellDelegate

extension TimelinePageViewController: CellDelegate {
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


extension TimelinePageViewController: postCellDelegate {
  func updateLikeBtn(index: Int, isliked: Bool) {
    likeBtn[index] = isliked
    print(likeBtn[index])
  }
}


//:MARK Segue

extension TimelinePageViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showGuest" {
      let dvc = segue.destination as! GuestViewController
      dvc.guestId = toGuest
      dvc.userName = guestName
      dvc.follow = followGuest
    }
  }
  
}


//MARK: TableView Datasource and delegate
extension TimelinePageViewController {
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let cell = cell as! PostContentCell
    cell.numberOfLikes.text =  "\(cell.converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
    cell.contentImage.image = contentImageSet[indexPath.section]
    cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
    cell.likeBtn.setImage(unlikeImage, for: .normal)
    cell.selectionStyle = .none
    
    cell.delegate = self
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
    return contentImageSet.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostContentCell
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



//:MARK Network services

extension TimelinePageViewController {
  
  
  
  // load posts
  func loadPosts() {
    
    let followQuery = PFQuery(className: "Follow")
    followQuery.whereKey("follower", equalTo: PFUser.current()?.objectId!)
    followQuery.findObjectsInBackground { (objects, error) in
      if error == nil {
        
        self.followArray.removeAll(keepingCapacity: false)
        
        for object in objects! {
          self.followArray.append(object.object(forKey: "following") as! String)
        }
        
        self.followArray.append(PFUser.current()!.objectId!)
        
        let query = PFQuery(className: "Post")
        query.whereKey("uid", containedIn: self.followArray)
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground(block: { (objects, error) in
          if error == nil {
            
            self.userNameArray.removeAll(keepingCapacity: false)
            self.avaArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.picArray.removeAll(keepingCapacity: false)
            self.postId.removeAll(keepingCapacity: false)
            self.likes.removeAll(keepingCapacity: false)
            self.uid.removeAll(keepingCapacity: false)
            
            
            //            for object in objects! {
            ////              self.userNameArray.append(object.object(forKey: "username") as! String)
            ////              self.avaArray.append(object.object(forKey: "ava") as! PFFile)
            ////              self.dateArray.append((object.createdAt)! as Date)
            ////              self.picArray.append(object.object(forKey: "pic") as! PFFile)
            ////              self.postId.append(object.objectId! as String)
            ////              self.likes.append(object.object(forKey: "likes") as! Int)
            //
            //                let post = Post(userName: object.object(forKey: "username") as! String, postTime: object.createdAt! as Date, numberOfLikes: object.object(forKey: "likes") as! Int, profileImage: object.object(forKey: "ava") as! PFFile, contentImage: object.object(forKey: "pic") as! PFFile)
            //                self.dataSource.append(post)
            //            }
            //
            //              self.tableView.reloadData()
            
            
            let count = objects?.count
            
            self.avaImageSet = Array(repeating: nil, count: count!)
            self.contentImageSet = Array(repeating: nil, count: count!)
            self.likeBtn = Array(repeating: nil, count: count!)
            
            for i in 0...count! {
              
              
              //Query whether current user has liked a item
              let query = PFQuery(className: "Like")
              query.whereKey("uid", equalTo: PFUser.current()?.objectId!)
              query.whereKey("pid", equalTo: objects?[i].objectId!)
              query.findObjectsInBackground(block: { (objects, error) in
                guard error == nil else {
                  print(error)
                  return
                }
                if objects?.count == 0 {
                  self.likeBtn[i] = false
                }else if (objects?.count)! > 0 {
                  self.likeBtn[i] = true
                }
              })
              
              
              let pic = objects?[i].object(forKey: "pic") as! PFFile
              pic.getDataInBackground(block: { (data, error) in
                self.contentImageSet[i] = (UIImage(data: data!))
              })
              
              
              let ava = objects?[i].object(forKey: "ava") as! PFFile
              ava.getDataInBackground(block: { (data, error) in
                self.avaImageSet[i] = (UIImage(data: data!))
                DispatchQueue.main.async {
                  self.tableView.reloadData()
                }
              })
              self.uid.append(objects?[i].object(forKey: "uid") as! String)
              self.dateArray.append((objects?[i].createdAt)! as Date)
              self.userNameArray.append(objects?[i].object(forKey: "username") as! String)
              self.postId.append((objects?[i].objectId!)! as String)
              self.likes.append(objects?[i].object(forKey: "likes") as! Int)
            }
          } else {
            print(error!.localizedDescription)
          }
        })
      } else {
        print(error!.localizedDescription)
      }
    }
  }
}


//extension TimelinePageViewController {
//  override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//    if velocity.y > 0 {
//            self.navigationController?.setNavigationBarHidden(true, animated: false)
//    
//    }else {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
//  }
//  }
