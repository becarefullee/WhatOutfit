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
  
  var delay: TimeInterval = -0.1
  var animateCell: Bool = true
  
  fileprivate var filterUserNameArray = [String]()
  fileprivate var filterAvaArray = [PFFile]()
  fileprivate var filterNickName = [String]()
  fileprivate var filterObjectId = [String]()

  fileprivate var usernameArray = [String]()
  fileprivate var avaArray = [PFFile]()
  fileprivate var followArray = [String]()
  fileprivate var objectId = [String]()
  fileprivate var nickName = [String]()
  fileprivate var follow = [String]()
  

  
  
  let searchController = UISearchController(searchResultsController: nil)
 
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
        setUpSearchBar()
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
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    animateCell = false
  }
  
  func setUpSearchBar() {
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.barTintColor = UIColor.white
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
  }
  
  
  func filter(serchText: String) {
    filterAvaArray.removeAll(keepingCapacity: false)
    filterUserNameArray.removeAll(keepingCapacity: false)
    filterNickName.removeAll(keepingCapacity: false)
    filterObjectId.removeAll(keepingCapacity: false)
    guard usernameArray.count > 0 else {
      return
    }
    for i in 0...usernameArray.count-1 {
      if usernameArray[i].lowercased().contains(serchText) {
        filterAvaArray.append(avaArray[i])
        filterNickName.append(nickName[i])
        filterObjectId.append(objectId[i])
        filterUserNameArray.append(usernameArray[i])
      }
    }
    tableView.reloadData()
  }
}

// MARK: - Table view data source and delegate


extension FollowViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive && searchController.searchBar.text != "" {
      return filterUserNameArray.count
    }
    return usernameArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowCell
    cell.index = indexPath.row
    cell.selectionStyle = .none
    
    if searchController.isActive && searchController.searchBar.text != "" {
      cell.nickNameLabel.text = filterNickName[indexPath.row]
      cell.userNameLabel.text = filterUserNameArray[indexPath.row]
      filterAvaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data:Data?, error) -> Void in
        if error == nil {
          cell.avaImageView.image = UIImage(data: data!)
        } else {
          print(error!.localizedDescription)
        }
      }
    }else{
      cell.nickNameLabel.text = nickName[indexPath.row]
      cell.userNameLabel.text = usernameArray[indexPath.row]
      avaArray[(indexPath as NSIndexPath).row].getDataInBackground { (data:Data?, error) -> Void in
        if error == nil {
          cell.avaImageView.image = UIImage(data: data!)
        } else {
          print(error!.localizedDescription)
        }
      }
    }
    
    self.follow = Array.init(repeating: "", count: usernameArray.count)
    
    let query = PFQuery(className: "Follow")
    query.whereKey("follower", equalTo: PFUser.current()?.objectId!)
    
    if searchController.isActive && searchController.searchBar.text != "" {
      query.whereKey("following", equalTo: filterObjectId[indexPath.row])
    }else{
      query.whereKey("following", equalTo: objectId[indexPath.row])
    }
    
    
    query.findObjectsInBackground { (objects, error) in
      if (objects?.count)! > 0 {
        cell.followBtn.tintColor = UIColor.white
        cell.followBtn.setTitle("✔︎FOLLOWING", for: UIControlState())
        self.follow[indexPath.row] = "FOLLOWING"
        setBtnStyleToColor(sender: cell.followBtn, color: greenColor, borderColor: greenColor)
      }else if objects?.count == 0{
        cell.followBtn.tintColor = defaultBlue
        cell.followBtn.setTitle("FOLLOW", for: UIControlState())
        self.follow[indexPath.row] = "FOLLOW"
        setBtnStyleToColor(sender: cell.followBtn, color: UIColor.white, borderColor: defaultBlue)
      }
    }
    
    if cell.userNameLabel.text == PFUser.current()?.username! {
      cell.followBtn.isHidden = true
    }
    
    return cell
  }
  
//  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    if animateCell {
//        cell.center.x -= 500
//        delay += 0.1
//        UIView.animate(withDuration: 0.3, delay: delay, options: [.curveEaseIn], animations: {
//          cell.center.x += 500
//        }, completion: nil)
//      }
//    }
}

//MARK: SearchControl Delegate

extension FollowViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    filter(serchText: (searchController.searchBar.text?.lowercased())!)
  }
}



//:MARK: Load followers/followings
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



//MARK: Handle btn event
extension FollowViewController {
  @IBAction func followBtnPressed(_ sender: UIButton) {
    
    let cell = sender.superview?.superview as! FollowCell
    let title = cell.followBtn.title(for: UIControlState())
    
    // to follow
    if title == "FOLLOW" {
      let object = PFObject(className: "Follow")
      object["follower"] = PFUser.current()?.objectId!

      //Based on wheter use filter
      if searchController.isActive && searchController.searchBar.text != "" {
        object["following"] = filterObjectId[cell.index!]
      } else {
        object["following"] = objectId[cell.index!]
      }
      
      object.saveInBackground(block: { (success:Bool, error) -> Void in
        if success {
          
          print("\(PFUser.current()?.username) follow \(self.usernameArray[cell.index!])")
          
          cell.followBtn.tintColor = UIColor.white
          cell.followBtn.setTitle("✔︎FOLLOWING", for: UIControlState())
          setBtnStyleToColor(sender: cell.followBtn, color: greenColor, borderColor: greenColor)
          
          self.follow[cell.index!] = "FOLLOWING"
          
          // Change the followers of the people you follow
          let query = PFQuery(className: "UserInfo")
          
          if self.searchController.isActive && self.searchController.searchBar.text != "" {
            query.whereKey("uid", equalTo: self.filterObjectId[cell.index!])
          }else{
            query.whereKey("uid", equalTo: self.objectId[cell.index!])

          }
          
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
      
      if searchController.isActive && searchController.searchBar.text != "" {
        query.whereKey("following", equalTo: filterObjectId[cell.index!])
      }else {
        query.whereKey("following", equalTo: objectId[cell.index!])
      }
      
      
      query.findObjectsInBackground(block: { (objects:[PFObject]?, error) -> Void in
        if error == nil {
          
          for object in objects! {
            object.deleteInBackground(block: { (success:Bool, error) -> Void in
              if success {
                
                print("\(PFUser.current()?.username) unfollow \(self.usernameArray[cell.index!])")

                cell.followBtn.tintColor = defaultBlue
                cell.followBtn.setTitle("FOLLOW", for: UIControlState())
                setBtnStyleToColor(sender: cell.followBtn, color: UIColor.white, borderColor: defaultBlue)
                
                  self.follow[cell.index!] = "FOLLOW"
                
                // Change the followers of the people you follow
                let unfollow = PFQuery(className: "UserInfo")
                
                if self.searchController.isActive && self.searchController.searchBar.text != "" {
                  unfollow.whereKey("uid", equalTo: self.filterObjectId[cell.index!])
                }else{
                  unfollow.whereKey("uid", equalTo: self.objectId[cell.index!])
                }
                
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

//MARK: Segue

extension FollowViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showGuest" {
      print("********************************")
      print(follow)
      let dvc = segue.destination as! GuestViewController
      if searchController.isActive && searchController.searchBar.text != "" {
        dvc.guestId = filterObjectId[(tableView.indexPathForSelectedRow?.row)!]
        dvc.userName = filterUserNameArray[(tableView.indexPathForSelectedRow?.row)!]
      }
      else {
        dvc.guestId = objectId[(tableView.indexPathForSelectedRow?.row)!]
        dvc.userName = usernameArray[(tableView.indexPathForSelectedRow?.row)!]
      }
      dvc.follow = follow[(tableView.indexPathForSelectedRow?.row)!]
    }
  }
}
