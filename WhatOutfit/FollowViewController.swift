//
//  FollowViewController.swift
//  WhatOutfit
//
//  Created by Qinyuan Li on 16/11/2.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse


var to = String()

class FollowViewController: UITableViewController {

  var source: String?
  var userId: String?
  var userName: String?
  
  fileprivate var usernameArray = [String]()
  fileprivate var avaArray = [PFFile]()
  fileprivate var followArray = [String]()
  fileprivate var objectId = [String]()
  fileprivate var nickName = [String]()
  fileprivate var follow = [String]()
  

  fileprivate let greenColor: UIColor = UIColor(red: 71/255, green: 216/255, blue: 14/255, alpha: 1)
  fileprivate let defaultBlue: UIColor = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1)

  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = to
        source = to
        if to == "Followers" {
          loadFollowers()
        } else {
          loadFollowings()
        }
        tableView.tableFooterView = UIView()
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if source == "Followers" {
      loadFollowers()
    } else {
      loadFollowings()
    }
   // tableView.reloadData()
  }
  
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowCell
      cell.index = indexPath.row
      cell.selectionStyle = .none
      cell.nickNameLabel.text = nickName[indexPath.row]
      cell.userNameLabel.text = usernameArray[indexPath.row]
      avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data:Data?, error) -> Void in
        if error == nil {
          cell.avaImageView.image = UIImage(data: data!)
        } else {
          print(error!.localizedDescription)
        }
      }
      
      self.follow = Array.init(repeating: "", count: usernameArray.count)

      
      let query = PFQuery(className: "Follow")
      query.whereKey("follower", equalTo: PFUser.current()?.objectId!)
      query.whereKey("following", equalTo: objectId[indexPath.row])
      query.countObjectsInBackground (block: { (count:Int32, error) -> Void in
        if error == nil {
          if count == 0 {
            cell.followBtn.tintColor = self.defaultBlue
            cell.followBtn.setTitle("FOLLOW", for: UIControlState())
            self.follow[indexPath.row] = "FOLLOW"
            setBtnStyleToColor(sender: cell.followBtn, color: UIColor.white, borderColor: self.defaultBlue)
          } else {
            cell.followBtn.tintColor = UIColor.white
            cell.followBtn.setTitle("✔︎FOLLOWING", for: UIControlState())
            self.follow[indexPath.row] = "FOLLOWING"
            setBtnStyleToColor(sender: cell.followBtn, color: self.greenColor, borderColor: self.greenColor)
          }
        }
      })
      
      
      if cell.userNameLabel.text == PFUser.current()?.username! {
        cell.followBtn.isHidden = true
      }
      
      return cell
    }
 

}


extension FollowViewController {
  
  
  func loadFollowers() {
    
    let followQuery = PFQuery(className: "Follow")
    followQuery.whereKey("following", equalTo:userId)
    followQuery.findObjectsInBackground (block: { (objects:[PFObject]?, error) -> Void in
      if error == nil {
        
        
        // clean up
        self.followArray.removeAll(keepingCapacity: false)
        
        // find related objects depending on query settings
        for object in objects! {
          self.followArray.append(object.value(forKey: "follower") as! String)
        }
        
        // find users following user
        let query = PFUser.query()
        query?.whereKey("objectId", containedIn: self.followArray)
        query?.addDescendingOrder("createdAt")
        query?.findObjectsInBackground(block: { (objects:[PFObject]?, error) -> Void in
          if error == nil {

//            self.follow.removeAll(keepingCapacity: false)
            self.usernameArray.removeAll(keepingCapacity: false)
            self.avaArray.removeAll(keepingCapacity: false)
            self.objectId.removeAll(keepingCapacity: false)
            self.nickName.removeAll(keepingCapacity: false)
            
            // find related objects in User class of Parse
            for object in objects! {
              self.usernameArray.append(object.object(forKey: "username") as! String)
              self.avaArray.append(object.object(forKey: "ava") as! PFFile)
              self.objectId.append(object.objectId!)
              self.nickName.append(object.object(forKey: "nickname") as! String)
            }
            self.tableView.reloadData()

          } else {
            print(error!.localizedDescription)
          }
        })
        
      } else {
        print(error!.localizedDescription)
      }
    })
    
  }
  
  
  func loadFollowings() {
    
    let followQuery = PFQuery(className: "Follow")
    followQuery.whereKey("follower", equalTo: userId!)
    followQuery.findObjectsInBackground (block: { (objects:[PFObject]?, error) -> Void in
      if error == nil {
        
        self.followArray.removeAll(keepingCapacity: false)
        
        // find related objects in "follow" class of Parse
        for object in objects! {
          self.followArray.append(object.value(forKey: "following") as! String)
        }
        
        // find users followeb by user
        let query = PFUser.query()
        query?.whereKey("objectId", containedIn: self.followArray)
        query?.addDescendingOrder("createdAt")
        query?.findObjectsInBackground(block: { (objects:[PFObject]?, error) -> Void in
          if error == nil {
            
            self.usernameArray.removeAll(keepingCapacity: false)
            self.avaArray.removeAll(keepingCapacity: false)
            self.objectId.removeAll(keepingCapacity: false)
            self.nickName.removeAll(keepingCapacity: false)
            
            for object in objects! {
              self.usernameArray.append(object.object(forKey: "username") as! String)
              self.avaArray.append(object.object(forKey: "ava") as! PFFile)
              self.objectId.append(object.objectId!)
              self.nickName.append(object.object(forKey: "nickname") as! String)

            }
            self.tableView.reloadData()
          } else {
            print(error!.localizedDescription)
          }
        })
        
      } else {
        print(error!.localizedDescription)
      }
    })
    
  }
  
}


extension FollowViewController {
  @IBAction func followBtnPressed(_ sender: UIButton) {
    
    let cell = sender.superview?.superview as! FollowCell
    let title = cell.followBtn.title(for: UIControlState())
    
    // to follow
    if title == "FOLLOW" {
      let object = PFObject(className: "Follow")
      object["follower"] = PFUser.current()?.objectId!
      object["following"] = objectId[cell.index!]
      object.saveInBackground(block: { (success:Bool, error) -> Void in
        if success {
          
          print("\(PFUser.current()?.username) follow \(self.usernameArray[cell.index!])")
          
          cell.followBtn.tintColor = UIColor.white
          cell.followBtn.setTitle("✔︎FOLLOWING", for: UIControlState())
          setBtnStyleToColor(sender: cell.followBtn, color: self.greenColor, borderColor: self.greenColor)
          
          
          self.follow[cell.index!] = "FOLLOWING"
          // Change the followers of the people you follow
          let query = PFQuery(className: "UserInfo")
          query.whereKey("uid", equalTo: self.objectId[cell.index!])
          query.getFirstObjectInBackground(block: { (object, error) in
            let followers = (object?["followers"] as! Int) + 1
            object?["followers"] = followers
            object?.saveInBackground()
          })
          
          //Change current user's followings
          let current = PFQuery(className: "UserInfo")
          current.whereKey("uid", equalTo: (PFUser.current()!.objectId)!)
          current.getFirstObjectInBackground(block: { (object, error) in
            object?["followings"] = (object?["followings"] as! Int) + 1
            object?.saveInBackground()
          })
        } else {
          print(error!.localizedDescription)
        }
      })
      
      // unfollow
    } else {
      
      let query = PFQuery(className: "Follow")
      query.whereKey("follower", equalTo: PFUser.current()?.objectId!)
      query.whereKey("following", equalTo: objectId[cell.index!])
      query.findObjectsInBackground(block: { (objects:[PFObject]?, error) -> Void in
        if error == nil {
          
          for object in objects! {
            object.deleteInBackground(block: { (success:Bool, error) -> Void in
              if success {
                
                print("\(PFUser.current()?.username) unfollow \(self.usernameArray[cell.index!])")

                cell.followBtn.tintColor = self.defaultBlue
                cell.followBtn.setTitle("FOLLOW", for: UIControlState())
                setBtnStyleToColor(sender: cell.followBtn, color: UIColor.white, borderColor: self.defaultBlue)
                
                self.follow[cell.index!] = "FOLLOW"
                // Change the followers of the people you follow
                let unfollow = PFQuery(className: "UserInfo")
                unfollow.whereKey("uid", equalTo: self.objectId[cell.index!])
                unfollow.getFirstObjectInBackground(block: { (object, error) in
                  let followers = (object?["followers"] as! Int) - 1
                  object?["followers"] = followers
                  object?.saveInBackground()
                })
                
                //Change current user's followings
                let current = PFQuery(className: "UserInfo")
                current.whereKey("uid", equalTo: (PFUser.current()!.objectId)!)
                current.getFirstObjectInBackground(block: { (object, error) in
                  object?["followings"] = (object?["followings"] as! Int) - 1
                  object?.saveInBackground()
                })
              } else {
                print(error!.localizedDescription)
              }
            })
          }
          
        } else {
          print(error!.localizedDescription)
        }
      })
      
    }
  }
}



extension FollowViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showGuest" {
      print("********************************")
      print(follow)
      let dvc = segue.destination as! GuestViewController
      dvc.guestId = objectId[(tableView.indexPathForSelectedRow?.row)!]
      dvc.userName = usernameArray[(tableView.indexPathForSelectedRow?.row)!]
      dvc.follow = follow[(tableView.indexPathForSelectedRow?.row)!]
    }
  }
  
}
