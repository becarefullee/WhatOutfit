//
//  TimelinePageViewController.swift
//  WhatOutfitTimelinePage
//
//  Created by Qinyuan Li on 16/10/26.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse

fileprivate let reuseIdentifier = "Cell"

class TimelinePageViewController: UITableViewController {
  
  

  var contentImageSet: [[UIImage?]?] = []
  var avaImageSet: [UIImage?] = []
  
  fileprivate var detailPageUserName: String?
  fileprivate var detailPageAva: UIImage?
  fileprivate var detailPageDate: Date?
  fileprivate var detailPageIsLiked: Bool?
  fileprivate var detailPageLikes: Int?
  fileprivate var detailPagePic: UIImage?
  fileprivate var detailPagePid: String?
  fileprivate var detailPageUid: String?
  fileprivate var detailPageIndex: Int?
  
  fileprivate var followGuest: String?
  fileprivate var toGuest: String?
  fileprivate var guestName: String?
  
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate let contentCellHeight: CGFloat = UIScreen.main.bounds.width + 44
  
  fileprivate var likes: [Int] = []
  fileprivate var likeBtn: [Bool?] = []
  fileprivate var userNameArray: [String] = []
  fileprivate var dateArray: [Date] = []
  
  fileprivate var postId: [String] = []
  fileprivate var uid: [String] = []
  fileprivate var followArray: [String] = []
  fileprivate var picArray: [PFFile] = []
  fileprivate var avaArray: [PFFile] = []

  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpForNavigationBar()
    setUpRefreshControl()
    loadPosts(from: "Local")
    NotificationCenter.default.addObserver(self, selector: #selector(self.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.deleted(_:)), name: NSNotification.Name(rawValue: "deleted"), object: nil)
    
//    let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//    DispatchQueue.global().asyncAfter(deadline: delayTime) {
//        self.loadPosts(from: "Network")
//    }
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //loadPosts(from: "Network")
//    let statusView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 20))
//    statusView.backgroundColor = UIColor.white
//    UIApplication.shared.keyWindow?.addSubview(statusView)
  }
  
  
  
  func refresh(_ sender: AnyObject?) {
    loadPosts(from: "Network")
    if #available(iOS 10.0, *) {
      self.tableView.refreshControl?.endRefreshing()
    } else {
      // Fallback on earlier versions
    }
  }
  
  
  @IBAction func likeBtnPressed(_ sender: UIButton) {
    let id: Int = Int(sender.title(for: .normal)!)!
//    let indexPath = IndexPath.init(row: 0, section: id)
    if contentImageSet[id]?.count == 1 {
      let cell = sender.superview?.superview?.superview as! PostContentCell
      if likeBtn[id]! {
        cell.updateLikeRelation(operation: .delete)
        likes[id] -= 1
      }else {
        cell.updateLikeRelation(operation: .add)
        likes[id] += 1
      }
      likeBtn[id] = !likeBtn[id]!
    }else if contentImageSet[id]?.count == 2 {
      let cell = sender.superview?.superview?.superview as! TwoItemCell
      if likeBtn[id]! {
        cell.updateLikeRelation(operation: .delete)
        likes[id] -= 1
      }else {
        cell.updateLikeRelation(operation: .add)
        likes[id] += 1
      }
      likeBtn[id] = !likeBtn[id]!

    }else if contentImageSet[id]?.count == 3 {
      let cell = sender.superview?.superview?.superview as! ThreeItemCell
      if likeBtn[id]! {
        cell.updateLikeRelation(operation: .delete)
        likes[id] -= 1
      }else {
        cell.updateLikeRelation(operation: .add)
        likes[id] += 1
      }
      likeBtn[id] = !likeBtn[id]!

    }else if contentImageSet[id]?.count == 4  {
      let cell = sender.superview?.superview?.superview as! FourItemCell
      if likeBtn[id]! {
        cell.updateLikeRelation(operation: .delete)
        likes[id] -= 1
      }else {
        cell.updateLikeRelation(operation: .add)
        likes[id] += 1
      }
      likeBtn[id] = !likeBtn[id]!

    }
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
      query.whereKey("follower", equalTo: PFUser.current()?.objectId! as Any)
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


extension TimelinePageViewController: UpdateLike {
  func updateLikeBtn(index: Int, isliked: Bool, needReload: Bool) {
    likeBtn[index] = isliked
    if isliked {
      likes[index] += 1
    }else {
      likes[index] -= 1
    }
    // reloaddata makes animation stop working
    if needReload {
      let indexPath = IndexPath.init(row: 0, section: index)
      tableView.reloadRows(at: [indexPath], with: .none)
    }
  }
  
  
  func performSegue(identifier: String, index: Int) {
//    detailPagePic = contentImageUISet[index]
    detailPageAva = avaImageSet[index]
    detailPageDate = dateArray[index]
    detailPageLikes = likes[index]
    detailPageUserName = userNameArray[index]
    detailPageIsLiked = likeBtn[index]
    detailPagePid = postId[index]
    detailPageUid = uid[index]
    detailPageIndex = index
    performSegue(withIdentifier: identifier, sender: self)
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
    else if segue.identifier == "showDetail" {
      let dvc = segue.destination as! OutfitDetailViewController
      dvc.likes = detailPageLikes
      dvc.date = detailPageDate
      dvc.isLiked = detailPageIsLiked
      dvc.index = detailPageIndex
      dvc.postId.append(detailPagePid!)
      dvc.userNameArray = detailPageUserName
      dvc.uid = detailPageUid
      dvc.ava = detailPageAva
      dvc.delegate = self
    }
  }
}


//MARK: TableView Datasource and delegate
extension TimelinePageViewController {
  
//  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//      let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostContentCell
//      cell.contentImage.image = contentImageSet[indexPath.section]?.first!
//      cell.numberOfLikes.text =  "\(cell.converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
//      cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
//      cell.likeBtn.setImage(unlikeImage, for: .normal)
//      cell.postOwnerId = uid[indexPath.section]
//      cell.selectionStyle = .none
//      cell.delegate = self
//      cell.likes = likes[indexPath.section]
//      cell.index = indexPath.section
//      cell.pid = postId[indexPath.section]
//      if let isLiked = likeBtn[indexPath.section] {
//        cell.isLiked = isLiked
//        if isLiked {
//          cell.likeBtn.setImage(likeImage, for: .normal)
//        }else {
//          cell.likeBtn.setImage(unlikeImage, for: .normal)
//        }
//      }
//  }
  
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let headerCell = view as! HeaderCell
    headerCell.userId = uid[section]
    headerCell.profileImage.image = avaImageSet[section]
    headerCell.postTime.text = convertDateToString(date: self.dateArray[section])
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
    if let count = contentImageSet[indexPath.section]?.count {
      switch count {
      case 1:
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostContentCell
        cell.contentImage.image = contentImageSet[indexPath.section]?.first!
        cell.numberOfLikes.text =  "\(converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
        cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
        cell.likeBtn.setImage(unlikeImage, for: .normal)
        cell.postOwnerId = uid[indexPath.section]
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
        return cell
      case 2:
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwoCell") as! TwoItemCell
        cell.firstImage.image = contentImageSet[indexPath.section]?[0]
        cell.secondImage.image = contentImageSet[indexPath.section]?[1]
        cell.numberOfLikes.text =  "\(converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
        cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
        cell.likeBtn.setImage(unlikeImage, for: .normal)
        cell.postOwnerId = uid[indexPath.section]
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
        return cell
      case 3:
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreeCell") as! ThreeItemCell
        cell.firstImage.image = contentImageSet[indexPath.section]?[0]
        cell.secondImage.image = contentImageSet[indexPath.section]?[1]
        cell.thirdImage.image = contentImageSet[indexPath.section]?[2]
        cell.numberOfLikes.text =  "\(converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
        cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
        cell.likeBtn.setImage(unlikeImage, for: .normal)
        cell.postOwnerId = uid[indexPath.section]
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
        return cell
      case 4:
        let cell = tableView.dequeueReusableCell(withIdentifier: "FourCell") as! FourItemCell
        cell.firstImage.image = contentImageSet[indexPath.section]?[0]
        cell.secondImage.image = contentImageSet[indexPath.section]?[1]
        cell.thirdImage.image = contentImageSet[indexPath.section]?[2]
        cell.fourthImage.image = contentImageSet[indexPath.section]?[3]
        cell.numberOfLikes.text =  "\(converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
        cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
        cell.likeBtn.setImage(unlikeImage, for: .normal)
        cell.postOwnerId = uid[indexPath.section]
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
        return cell

      default:
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostContentCell
        cell.contentImage.image = contentImageSet[indexPath.section]?.first!
        cell.numberOfLikes.text =  "\(converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
        cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
        cell.likeBtn.setImage(unlikeImage, for: .normal)
        cell.postOwnerId = uid[indexPath.section]
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
        return cell
      }
    }
    else{
      let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostContentCell
      cell.contentImage.image = contentImageSet[indexPath.section]?.first!
      cell.numberOfLikes.text =  "\(converLikesToString(numberOfLikes: likes[indexPath.section])) likes"
      cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
      cell.likeBtn.setImage(unlikeImage, for: .normal)
      cell.postOwnerId = uid[indexPath.section]
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
      return cell
    }
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
  func loadPosts(from: String) {
    let followQuery = PFQuery(className: "Follow")
    
    if from == "Local" {
      followQuery.fromLocalDatastore()
    }
    
    followQuery.whereKey("follower", equalTo: PFUser.current()?.objectId! as Any)
    followQuery.findObjectsInBackground { (objects, error) in
      if from == "Network" {
        PFObject.pinAll(inBackground: objects)
      }
      if error == nil {
        
        self.followArray.removeAll(keepingCapacity: false)
        
        for object in objects! {
          self.followArray.append(object.object(forKey: "following") as! String)
        }
        
        self.followArray.append(PFUser.current()!.objectId!)
        
        let query = PFQuery(className: "Post")
        if from == "Local" {
          query.fromLocalDatastore()
        }
        query.whereKey("uid", containedIn: self.followArray)
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground(block: { (objects, error) in
          if error == nil {
            
            self.likes.removeAll(keepingCapacity: false)
            self.userNameArray.removeAll(keepingCapacity: false)
            self.avaArray.removeAll(keepingCapacity: false)
            self.dateArray.removeAll(keepingCapacity: false)
            self.picArray.removeAll(keepingCapacity: false)
            self.postId.removeAll(keepingCapacity: false)
            self.uid.removeAll(keepingCapacity: false)
            
            
            let count = objects?.count
            self.avaImageSet = Array(repeating: nil, count: count!)
            self.contentImageSet = Array(repeating: nil, count: count!) as [[UIImage?]?]
            self.likeBtn = Array(repeating: nil, count: count!)
            
            if count! > 0 {
              for i in 0...count!-1 {
                // Local stroage
                if from == "Network" {
                  objects?[i].pinInBackground()
                }
                
                //Query whether current user has liked a item
                let query = PFQuery(className: "Like")
                if from == "Local" {
                  query.fromLocalDatastore()
                }

                query.whereKey("uid", equalTo: PFUser.current()?.objectId! as Any)
                query.whereKey("pid", equalTo: objects?[i].objectId! as Any)
                query.findObjectsInBackground(block: { (objects, error) in
                  if objects?.count == 0 {
                    self.likeBtn[i] = false
                    self.tableView.reloadData()
                  }else if (objects?.count)! > 0 {
                    self.likeBtn[i] = true
                    self.tableView.reloadData()
                  }

                  // Local stroage
                  if from == "Network" {
//                    PFObject.pinAll(inBackground: objects)
                    objects?[i].pinInBackground()
                  }
                })
                
                
//                let pic = objects?[i].object(forKey: "pic") as! PFFile
//                pic.getDataInBackground(block: { (data, error) in
//                  self.contentImageSet[i] = (UIImage(data: data!))
//                })
//                
                
                let outfits = objects?[i].object(forKey: "outfits") as! NSArray
                var imageSet: [UIImage?] = []
                imageSet = Array(repeating: nil, count: outfits.count) as [UIImage?]
                for j in 0...outfits.count-1 {
                  let file = outfits[j] as! PFFile
                  file.getDataInBackground(block: { (data, error) in
                    imageSet[j] = UIImage(data: data!)
//                    if j == outfits.count-1 {
                      self.contentImageSet[i] = imageSet
                      DispatchQueue.main.async {
                        self.tableView.reloadData()
//                      }
                    }
                  })
                }
            
                let ava = objects?[i].object(forKey: "ava") as! PFFile
                ava.getDataInBackground(block: { (data, error) in
                  self.avaImageSet[i] = (UIImage(data: data!))
                  DispatchQueue.main.async {
                    self.tableView.reloadData()
                  }
                })
                self.uid.append(objects?[i].object(forKey: "uid") as! String)
                self.userNameArray.append(objects?[i].object(forKey: "username") as! String)
                self.postId.append((objects?[i].objectId!)! as String)
                self.likes.append(objects?[i].object(forKey: "likes") as! Int)
                self.dateArray.append((objects?[i].createdAt)! as Date)
              }
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


//MARK: Notification
extension TimelinePageViewController {
  func uploaded(_ notification:Notification) {
    loadPosts(from: "Network")
    tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
  }
  func deleted(_ notification:Notification) {
    loadPosts(from: "Network")
    tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
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
