//
//  MessageController.swift
//  WhatOutfit
//
//  Created by becarefullee on 2016/11/22.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse

class MessageController: UITableViewController {
  
  fileprivate var username: [String?] = []
  fileprivate var ava: [UIImage?] = []
  fileprivate var date: [Date?] = []
  fileprivate var thumbnail: [UIImage?] = []
  fileprivate var type: [String?] = []
  fileprivate var pid: [String?] = []
  fileprivate var uid: [String?] = []
  
  fileprivate var toPid: String?
  fileprivate var toUid: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    loadMessage()
    tableView.tableFooterView = UIView()

  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return date.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if type[indexPath.row] == "follow" {
      let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowMessageCell
      cell.ava.setImage(ava[indexPath.row], for: .normal)
      cell.username.setTitle(username[indexPath.row], for: .normal)
      cell.date.text = convertDateToString(date: date[indexPath.row]!)
      cell.ava.tag = indexPath.row
      cell.username.tag = indexPath.row
      return cell
    }else{
      let cell = tableView.dequeueReusableCell(withIdentifier: "LikeCell") as! LikeMessageCell
      cell.ava.setImage(ava[indexPath.row], for: .normal)
      cell.username.setTitle(username[indexPath.row], for: .normal)
      cell.date.text = convertDateToString(date: date[indexPath.row]!)
      cell.thumbnail.setImage(thumbnail[indexPath.row], for: .normal)
      cell.ava.tag = indexPath.row
      cell.username.tag = indexPath.row
      cell.thumbnail.tag = indexPath.row
      return cell

    }
  }
  
  
}

extension MessageController {
  func loadMessage() {
    let query = PFQuery(className: "Message")
    query.whereKey("to", equalTo: PFUser.current()?.objectId as Any)
    query.addDescendingOrder("createdAt")
    query.findObjectsInBackground { (objects, error) in
      if error == nil {
        let count = objects?.count
        self.uid = Array(repeating: nil, count: count!) as [String?]
        self.pid = Array(repeating: nil, count: count!) as [String?]
        self.username = Array(repeating: nil, count: count!) as [String?]
        self.ava = Array(repeating: nil, count: count!) as [UIImage?]
        self.date = Array(repeating: nil, count: count!) as [Date?]
        self.thumbnail = Array(repeating: nil, count: count!) as [UIImage?]
        self.type = Array(repeating: nil, count: count!) as [String?]
        
        for i in 0...count! {
          let usernameQuery = PFUser.query()
          usernameQuery?.getObjectInBackground(withId: objects?[i].value(forKey: "from") as! String, block: { (object, error) in
            if error == nil {
              self.username[i] = object?["username"] as? String
              self.tableView.reloadData()
            }else{
              print(error!.localizedDescription)
            }
          })
          
          self.date[i] = (objects?[i].createdAt)!
          self.type[i] = objects?[i].object(forKey: "type") as? String
          self.pid[i] = objects?[i].object(forKey: "pid") as? String
          self.uid[i] = objects?[i].object(forKey: "from") as? String

          
          let avaPic = objects?[i].object(forKey: "ava") as! PFFile
          avaPic.getDataInBackground(block: { (data, error) in
            self.ava[i] = UIImage(data: data!)
            self.tableView.reloadData()
          })
         
          if let pic = objects?[i].object(forKey: "pic") as? PFFile {
            pic.getDataInBackground(block: { (data, error) in
              self.thumbnail[i] = UIImage(data: data!)
              self.tableView.reloadData()
            })
          }
        }
      }else{
        print(error!.localizedDescription)
      }
    }
  }
}

extension MessageController {
  @IBAction func toProfile(_ sender: UIButton) {
    print(sender.tag)
    toUid = uid[sender.tag]
    performSegue(withIdentifier: "showGuest", sender: self)
  }
  
  @IBAction func toDetail(_ sender: UIButton) {
    print(sender.tag)
    toPid = pid[sender.tag]
    performSegue(withIdentifier: "showDetail", sender: self)

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showGuest" {
      let dvc = segue.destination as! GuestViewController
      dvc.guestId = toUid
    }else if segue.identifier == "showDetail" {
      let dvc = segue.destination as! OutfitDetailViewController
      dvc.postId.append(toPid!)
    }
  }
  
}






