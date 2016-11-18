//
//  SearchViewController.swift
//  WhatOutfit
//
//  Created by Qinyuan Li on 16/11/9.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import Parse
import UIKit

class SearchViewController: UITableViewController {
  
  
  fileprivate var usernameArray = [String]()
  fileprivate var avaArray = [PFFile]()
  fileprivate var followArray = [String]()
  fileprivate var objectId = [String]()
  fileprivate var nickName = [String]()
  fileprivate var follow = [String]()


  fileprivate let searchController = UISearchController(searchResultsController: nil)
  var searchTypingTimer: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.searchBar.delegate = self
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.barTintColor = UIColor.white
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
    tableView.tableFooterView = UIView()
  }
}



extension SearchViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard searchController.isActive else { return }
    guard let searchText = searchController.searchBar.text else { return }
    guard !searchText.characters.isEmpty else { return }
    searchTypingTimer?.invalidate()
    searchTypingTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.startNewSearchFromTimer(_:)),userInfo: ["searchText": searchText], repeats: false)
  }
  
  
  func startNewSearchFromTimer(_ timer: Timer) {
    let userInfo = timer.userInfo as! Dictionary<String, Any>
    let searchText = userInfo["searchText"] as! String
    startNewSearchWithSearchText(searchText: searchText)
  }
  
  func startNewSearchWithSearchText(searchText: String) {
    findUserBy(username: searchText)
  }
}


extension SearchViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    usernameArray.removeAll(keepingCapacity: false)
    avaArray.removeAll(keepingCapacity: false)
    objectId.removeAll(keepingCapacity: false)
    nickName.removeAll(keepingCapacity: false)
    follow.removeAll(keepingCapacity: false)
    tableView.reloadData()
  }
  
  
  
}
// MARK: - Table view data source


extension SearchViewController {
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
    query.whereKey("follower", equalTo: PFUser.current()?.objectId! as Any)
    query.whereKey("following", equalTo: objectId[indexPath.row])
    
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

  
}


//MARK: Query user
extension SearchViewController {
  
  func findUserBy(username: String) {
    
    // find by username
    let usernameQuery = PFUser.query()
    usernameQuery?.whereKey("username", matchesRegex: "(?i)" + username.lowercased())
    usernameQuery?.findObjectsInBackground (block: { (objects:[PFObject]?, error) -> Void in
      if error == nil {
        
        // clean up
        self.usernameArray.removeAll(keepingCapacity: false)
        self.avaArray.removeAll(keepingCapacity: false)
        self.objectId.removeAll(keepingCapacity: false)
        self.nickName.removeAll(keepingCapacity: false)

        
        // if no objects are found according to entered text in usernaem colomn, find by fullname
        if objects!.isEmpty {
          
          let fullnameQuery = PFUser.query()
          fullnameQuery?.whereKey("nickname", matchesRegex: "(?i)" + username)
          fullnameQuery?.findObjectsInBackground(block: { (objects:[PFObject]?, error) -> Void in
            if error == nil {
              
              
              // found related objects
              for object in objects! {
                self.usernameArray.append(object.object(forKey: "username") as! String)
                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                self.objectId.append(object.objectId!)
                self.nickName.append(object.object(forKey: "nickname") as! String)
              }
              self.tableView.reloadData()

            }
          })
        }
        
  
        
        // found related objects
        for object in objects! {
          self.usernameArray.append(object.object(forKey: "username") as! String)
          self.avaArray.append(object.object(forKey: "ava") as! PFFile)
          self.objectId.append(object.objectId!)
          self.nickName.append(object.object(forKey: "nickname") as! String)
        }
        
        // reload
        self.tableView.reloadData()
        
      }
    })
  }
}

//MARK: Handle btn event
extension SearchViewController {
  @IBAction func followBtnPressed(_ sender: UIButton) {
    
    let cell = sender.superview?.superview as! FollowCell
    let title = cell.followBtn.title(for: UIControlState())
    
    // to follow
    if title == "FOLLOW" {
      let object = PFObject(className: "Follow")
      object["follower"] = PFUser.current()?.objectId!
      
      //Based on wheter use filter
     
        object["following"] = objectId[cell.index!]
      
      
      object.saveInBackground(block: { (success:Bool, error) -> Void in
        if success {
          
          print("\(PFUser.current()?.username) follow \(self.usernameArray[cell.index!])")
          
          cell.followBtn.tintColor = UIColor.white
          cell.followBtn.setTitle("✔︎FOLLOWING", for: UIControlState())
          setBtnStyleToColor(sender: cell.followBtn, color: greenColor, borderColor: greenColor)
          
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
      query.whereKey("follower", equalTo: PFUser.current()?.objectId! as Any)
      query.whereKey("following", equalTo: objectId[cell.index!])
      
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



//MARK: Segue

extension SearchViewController {
  
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
