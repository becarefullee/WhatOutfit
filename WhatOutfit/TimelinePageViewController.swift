//
//  TimelinePageViewController.swift
//  WhatOutfitTimelinePage
//
//  Created by Becarefullee on 16/10/26.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit


fileprivate let reuseIdentifier = "Cell"
fileprivate let likeImage = UIImage(named:"praised")
fileprivate let unlikeImage = UIImage(named:"praise")


class TimelinePageViewController: UITableViewController {


  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate var dataSource = [Post]()

  
  override func viewDidLoad() {
      super.viewDidLoad()
      setUpForNavigationBar()
      setupDataSouce()
      setUpRefreshControl()
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let statusView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 20))
    statusView.backgroundColor = UIColor.white
//      self.statusView = statusView
    UIApplication.shared.keyWindow?.addSubview(statusView)
  }


  
  func refresh(_ sender: AnyObject?) {
    let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      if #available(iOS 10.0, *) {
        self.tableView?.refreshControl?.endRefreshing()
       } else {
        // Fallback on earlier versions
      }
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
  
  func setupDataSouce() {
    for i in 0...5 {
      let dateFormatter = DateFormatter()
      let dateString1 = "27-10-2016 22:13"
      let dateString2 = "27-10-2016 12:59"
      dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
      let date1 = dateFormatter.date(from: dateString1)
      let date2 = dateFormatter.date(from: dateString2)

      if i % 2 == 0 {
        let post = Post(userName: "Eddie", postTime: date1!, numberOfLikes: 12, profileImage: "IMG", contentImage: "IMG-1")
        dataSource.append(post)
      }else {
        let post = Post(userName: "Jobs", postTime: date2!, numberOfLikes: 220, profileImage: "Jobs", contentImage: "IMG-0")
        dataSource.append(post)
      }
    }
  }
}

//:MARK TapRecognizerHandler

extension TimelinePageViewController {
  
  func likeAnimation(center: CGPoint) {
    let newView = UIImageView(image:UIImage(named: "praised_1"))
    newView.center = center
    newView.alpha = 0
    view.addSubview(newView)
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.3, options: [], animations: {
      newView.alpha = 1
      newView.transform = CGAffineTransform(scaleX: 2.3, y: 2.3)
      
    }) { (finished) in
      UIView.animate(withDuration: 0.3, animations: {
        newView.alpha = 0
        newView.transform = CGAffineTransform.identity
        newView.transform = CGAffineTransform(scaleX: 1/2.3, y: 1/2.3)
        }, completion: { (finished) in
          newView.removeFromSuperview()
      })
    }
  }
  
  
  func handleSingleTap(_ sender: UITapGestureRecognizer) {
    performSegue(withIdentifier: "showDetail", sender: sender)
    print("Single Tapped")
  }
  func handleDoubleTap(_ sender: UITapGestureRecognizer) {
    
    let cell = sender.view?.superview?.superview as! PostContentCell
    let id: Int = cell.index
    dataSource[id].likedByCurrentUser = !dataSource[id].likedByCurrentUser
    if dataSource[id].likedByCurrentUser {
      likeAnimation(center: cell.center)
      cell.likeBtn.setImage(likeImage, for: .normal)
      dataSource[id].numberOfLikes += 1
    }else {
      cell.likeBtn.setImage(unlikeImage, for: .normal)
      dataSource[id].numberOfLikes -= 1
    }
    tableView.reloadData()
    print("Double Tapped")
  }
}



//MARK: TableView Datasource and delegate
extension TimelinePageViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostContentCell
    let singleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
    let doubleTapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
    singleTapRecognizer.numberOfTapsRequired = 1
    doubleTapRecognizer.numberOfTapsRequired = 2
    singleTapRecognizer.require(toFail: doubleTapRecognizer)
    cell.contentImage.addGestureRecognizer(singleTapRecognizer)
    cell.contentImage.addGestureRecognizer(doubleTapRecognizer)
    cell.configure(post: dataSource[indexPath.section], index: indexPath.section)
    cell.selectionStyle = .none
    cell.likeBtn.setTitle("\(indexPath.section)", for: .normal)
    if dataSource[indexPath.section].likedByCurrentUser {
      cell.likeBtn.setImage(likeImage, for: .normal)
    }else {
      cell.likeBtn.setImage(unlikeImage, for: .normal)
    }
    return cell
  }
 
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerCell = tableView.dequeueReusableCell(withIdentifier: "Header") as! HeaderCell
    headerCell.configure(post: dataSource[section])
    headerCell.backgroundColor = UIColor.white
    headerCell.alpha = 1.0
    return headerCell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screenWidth + 44
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
