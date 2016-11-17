//
//  GuestViewController.swift
//  WhatOutfit
//
//  Created by Qinyuan Li on 16/11/3.
//  Copyright © 2016年 Qinyuan Li. All rights reserved.
//

import UIKit
import Parse


private let reuseIdentifier = "Cell"

class GuestViewController: UICollectionViewController {

  var guestId: String?
  var userName: String?
  var follow: String?
    
  
  fileprivate var outfitsImageSet: [UIImage?] = []
  fileprivate var likesImageSet: [UIImage?] = []
  fileprivate var likesId: [String?] = []
  fileprivate var outfitId: [String?] = []
  
  fileprivate var likesLikes: [Int] = []
  fileprivate var likesLikeBtn: [Bool?] = []
  fileprivate var likesDateArray: [Date] = []
  fileprivate var likesAva: [UIImage?] = []
  fileprivate var likesUsername: [String] = []
  fileprivate var likesUid: [String] = []
  
  fileprivate var outfitLikes: [Int] = []
  fileprivate var outfitLikeBtn: [Bool?] = []
  fileprivate var outfitDateArray: [Date] = []
  fileprivate var ava: UIImage?
  
  fileprivate let network: String = "Network"
  fileprivate let local: String = "Local"
  fileprivate var numberOfPosts: Int = 0
  fileprivate var page : Int = 9
  fileprivate var likesSelected: Bool = false
  fileprivate var header: HeaderCollectionReusableView?
  fileprivate let greyColor: UIColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
  fileprivate let lightGreyColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
  fileprivate let defaultBlue: UIColor = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1)
  fileprivate let greenColor: UIColor = UIColor(red: 71/255, green: 216/255, blue: 14/255, alpha: 1)

  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate var cellWidth: CGFloat {
    return (screenWidth - 12) / 3
  }
  fileprivate let anchor: CGPoint = CGPoint(x: 0, y: 240)

  override func viewDidLoad() {
    super.viewDidLoad()
    if guestId != "" {
      loadLikes(from: network)
      loadPosts(from: network)
    }
    setUpForNavigationBar()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    if #available(iOS 10.0, *) {
      collectionView?.refreshControl = refreshControl
    } else {
      // Fallback on earlier versions
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    collectionView?.reloadData()
    if guestId != "" {
      loadPosts(from: network)
    }
  }
  
  func setUpForNavigationBar() {
    self.navigationItem.title = userName
    if let navigationController = navigationController {
      navigationController.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
      navigationController.navigationBar.isTranslucent = false
    }
  }
  
  
  func refresh(_ sender: AnyObject?) {
    loadPosts(from: network)
    loadLikes(from: network)
    if #available(iOS 10.0, *) {
      self.collectionView?.refreshControl?.endRefreshing()
    } else {
      // Fallback on earlier versions
    }
  }
}


//:MARK Change Section

extension GuestViewController {
  @IBAction func outfitsBtnPressed(_ sender: UIButton) {
    header?.likesBtn.setTitleColor(greyColor, for: .normal)
    header?.outfitsBtn.setTitleColor(defaultBlue, for: .normal)
    likesSelected = false
    collectionView?.reloadData()
  }
  
  @IBAction func likesBtnPressed(_ sender: UIButton) {
    header?.likesBtn.setTitleColor(defaultBlue, for: .normal)
    header?.outfitsBtn.setTitleColor(greyColor, for: .normal)
    likesSelected = true
    collectionView?.reloadData()
  }
}


//:MARK CollectionView Datasource


extension GuestViewController {
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let cell = cell as! ImageCell
    if likesSelected {
      cell.imageView.image = likesImageSet[indexPath.row]
    }else {
      cell.imageView.image = outfitsImageSet[indexPath.row]
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if likesSelected {
      return likesImageSet.count
    }
      return outfitsImageSet.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath) as! HeaderCollectionReusableView
      header = headerView
      
      
      if userName == "Unknown" {
        // call alert
        let alert = UIAlertController(title: "Couldn't", message: "find user.", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
          self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        
        self.header?.editProfile.tintColor = self.defaultBlue
        self.header?.editProfile.setTitle("FOLLOW", for: UIControlState())
        setBtnStyleToColor(sender: (self.header?.editProfile)!, color: UIColor.white, borderColor: self.defaultBlue)
        
        headerView.numberOfFollowers.setTitle("0", for: .normal)
        headerView.numberOfFollowing.setTitle("0", for: .normal)

        //Nickname
        headerView.nameLabel.text = "Unknown"
        //Likes
        headerView.numberOfLikes.setTitle("0", for: .normal)
        
        //What's up
        headerView.whatsupLabel.text = ""
        
        //Post
        headerView.numberOfPosts.setTitle("0", for: .normal)
        
        headerView.profilePicture.image = UIImage(named: "unknown")
      } else {
        if PFUser.current()?.username == userName {
          self.header?.editProfile.setTitle("Edit Profile", for: .normal)
          self.header?.editProfile.tintColor = UIColor.black
          setBtnStyleToColor(sender: (header?.editProfile)!, color: lightGreyColor, borderColor: lightGreyColor)
        }else {
          if follow == "FOLLOW" {
            self.header?.editProfile.tintColor = self.defaultBlue
            self.header?.editProfile.setTitle("FOLLOW", for: UIControlState())
            setBtnStyleToColor(sender: (self.header?.editProfile)!, color: UIColor.white, borderColor: self.defaultBlue)
          }else{
            self.header?.editProfile.tintColor = UIColor.white
            self.header?.editProfile.setTitle("FOLLOWING", for: UIControlState())
            setBtnStyleToColor(sender: (self.header?.editProfile)!, color: self.greenColor, borderColor: self.greenColor)
          }
        }
        
        let query = PFUser.query()
        query?.getObjectInBackground(withId: guestId!, block: { (object, error) in
          
          let query = PFQuery(className: "UserInfo")
          query.whereKey("uid", equalTo: self.guestId)
          query.getFirstObjectInBackground(block: { (object, error) in
            //Followers
            let followers = object?["followers"] as! Int
            headerView.numberOfFollowers.setTitle("\(followers)", for: .normal)
            
            //Followings
            let followings = object?["followings"] as! Int
            headerView.numberOfFollowing.setTitle("\(followings)", for: .normal)
          })
          
          //Nickname
          headerView.nameLabel.text = object?["username"] as? String
          
          //Likes
          let likes = object?["likes"] as! Int
          headerView.numberOfLikes.setTitle("\(likes)", for: .normal)
          
          //What's up
          headerView.whatsupLabel.text = object?["bio"] as? String
          
          //Post
          let posts = object?["posts"] as! Int
          headerView.numberOfPosts.setTitle("\(posts)", for: .normal)
          
          //Ava
          let image = object?["ava"] as! PFFile
          image.getDataInBackground(block: { (data, error) in
            headerView.profilePicture.image = UIImage(data: data!)
            self.ava = UIImage(data: data!)
          })
        })

      }
    return headerView
    default:
      assert(false, "Unexpected element kind")
    }
  }
  
}


//:MARK Resize the CollectionvViewCell based on screen size


extension GuestViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: cellWidth, height: cellWidth)
  }
  
}


extension GuestViewController {
  
  @IBAction func likeBtnPressed(_ sender: UIButton) {
    header?.likesBtn.setTitleColor(defaultBlue, for: .normal)
    header?.outfitsBtn.setTitleColor(greyColor, for: .normal)
    likesSelected = true
    collectionView?.reloadData()
    scrollToCertainPoint(scrollView: collectionView!, point: anchor)
  }

  

  @IBAction func postBtnPressed(_ sender: UIButton) {
    header?.likesBtn.setTitleColor(greyColor, for: .normal)
    header?.outfitsBtn.setTitleColor(defaultBlue, for: .normal)
    likesSelected = false
    collectionView?.reloadData()
    scrollToCertainPoint(scrollView: collectionView!, point: anchor)
  }
  
  func scrollToCertainPoint(scrollView: UIScrollView, point: CGPoint) {
    scrollView.setContentOffset(CGPoint(x: point.x, y: point.y), animated: true)
  }
}





//:MARK Network

extension GuestViewController {
  
  // Load Likes
  func loadLikes(from: String) {
    let query = PFQuery(className: "Like")
    if from == local {
      query.fromLocalDatastore()
    }
    query.whereKey("uid", equalTo: guestId!)
    query.addDescendingOrder("createdAt")
    query.findObjectsInBackground { (objects, error) in
      let count = objects?.count
      
      self.likesImageSet.removeAll(keepingCapacity: false)
      self.likesId.removeAll(keepingCapacity: false)
      self.likesLikes.removeAll(keepingCapacity: false)
      self.likesDateArray.removeAll(keepingCapacity: false)
      self.likesUsername.removeAll(keepingCapacity: false)
      self.likesUid.removeAll(keepingCapacity: false)
      
      self.likesAva = Array(repeating: nil, count: count!) as [UIImage?]
      self.likesImageSet = Array(repeating: nil, count: count!) as [UIImage?]
      self.likesId = Array(repeating: nil, count: count!) as [String?]
      self.likesLikeBtn = Array(repeating: false, count: count!)
    
      if count! > 0 {
        for i in 0...count!-1 {
          if from == self.network {
            objects?[i].pinInBackground(block: { (success, error) in
            })
          }
          
          let query = PFQuery(className: "Post")
          query.getObjectInBackground(withId: objects?[i].value(forKey: "pid") as! String, block: { (object, error) in
            guard object != nil else {
              return
            }
            
            
            //Query whether current user has liked a item
            let query = PFQuery(className: "Like")
            if from == "Local" {
              query.fromLocalDatastore()
            }
            query.whereKey("uid", equalTo: PFUser.current()?.objectId!)
            query.whereKey("pid", equalTo: objects?[i].value(forKey: "pid") as! String)
            query.findObjectsInBackground(block: { (likes, error) in
              if likes?.count == 0 {
                self.outfitLikeBtn[i] = false
              }else if (likes?.count)! > 0 {
                self.outfitLikeBtn[i] = true
              }
              
              // Local stroage
              if from == "Network" {
                objects?[i].pinInBackground()
              }
            })

            
            let contentImage = object?["pic"] as! PFFile
            contentImage.getDataInBackground(block: { (data, error) in
              if error == nil {
                let image = UIImage(data: data!)
                self.likesImageSet[i] = image!
                self.likesId[i] = (object?.objectId!)!
                self.collectionView?.reloadData()
              }
              else {
                print(error!.localizedDescription)
              }
            })
            
            let avaImage = object?["ava"] as! PFFile
            avaImage.getDataInBackground(block: { (data, error) in
              let image = UIImage(data: data!)
              self.likesAva[i] = image!
            })
            
            self.likesUsername.append(object?["username"] as! String)
            self.likesLikes.append(object?["likes"] as! Int)
            self.likesDateArray.append((object?.createdAt)! as Date)
            self.likesUid.append(object?["uid"] as! String)
          })
        }
      }
    }
  }
  
  // Load Outfit
  func loadPosts(from: String) {
    let query = PFQuery(className: "Post")
    if from == local {
      query.fromLocalDatastore()
    }

    query.whereKey("uid", equalTo: guestId)
    query.addDescendingOrder("createdAt")
    query.findObjectsInBackground (block: { (objects:[PFObject]?, error) -> Void in
      
      let count = objects?.count

      guard count != 0 else {
        return
      }
      
      self.outfitId.removeAll(keepingCapacity: false)
      self.outfitsImageSet.removeAll(keepingCapacity: false)
      self.outfitLikes.removeAll(keepingCapacity: false)
      self.outfitDateArray.removeAll(keepingCapacity: false)

      if error == nil {

        self.outfitsImageSet = Array(repeating: UIImage(named: "pbg"), count: count!) as [UIImage?]
        self.outfitId = Array(repeating: nil, count: count!) as [String?]
        self.outfitLikeBtn = Array(repeating: false, count: count!)

        
        for i in 0...count!-1 {
          
          //Query whether current user has liked a item
          let query = PFQuery(className: "Like")
          if from == "Local" {
            query.fromLocalDatastore()
          }
          query.whereKey("uid", equalTo: PFUser.current()?.objectId!)
          query.whereKey("pid", equalTo: objects?[i].objectId!)
          query.findObjectsInBackground(block: { (objects, error) in
            if objects?.count == 0 {
              self.outfitLikeBtn[i] = false
            }else if (objects?.count)! > 0 {
              self.outfitLikeBtn[i] = true
            }
            
            // Local stroage
            if from == "Network" {
              objects?[i].pinInBackground()
            }
          })


          let contentImage = objects?[i].value(forKey: "pic") as! PFFile
          contentImage.getDataInBackground(block: { (data, error) in
            if error == nil{
              let image = UIImage(data:data!)
                self.outfitsImageSet[i] = image!
                self.outfitId[i] = objects?[i].objectId!
              let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
              if i == count!-1{
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                  self.collectionView?.reloadData()
                })
              }
            }else{
              print("GetDataFailed")
            }
          })
          self.outfitLikes.append(objects?[i].object(forKey: "likes") as! Int)
          self.outfitDateArray.append((objects?[i].createdAt)! as Date)
        }
      } else {
        print(error!.localizedDescription)
      }
    })

  }
}


//:MARK Segues


extension GuestViewController {
  
  @IBAction func following(_ sender: UIButton) {
    to = "Following"
    performSegue(withIdentifier: "showFollowers", sender: sender)
    
  }
  
  @IBAction func follower(_ sender: UIButton) {
    to = "Followers"
    performSegue(withIdentifier: "showFollowers", sender: sender)
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showFollowers" {
      let dvc = segue.destination as! FollowViewController
      dvc.userId = guestId
      dvc.userName = userName
    } else if segue.identifier == "showDetail" {
      let index = collectionView?.indexPathsForSelectedItems?.first?.row
      let dvc = segue.destination as! OutfitDetailViewController
      if likesSelected {
        dvc.postId.append(likesId[index!]!)
        dvc.likes = likesLikes[index!]
        dvc.date = likesDateArray[index!]
        dvc.userNameArray.append(likesUsername[index!])
        dvc.uid.append(likesUid[index!])
        dvc.isLiked = likesLikeBtn[index!]
        dvc.ava = likesAva[index!]
      }else {
        dvc.postId.append(outfitId[index!]!)
        dvc.likes = outfitLikes[index!]
        dvc.date = outfitDateArray[index!]
        dvc.isLiked = outfitLikeBtn[index!]
        dvc.userNameArray.append(userName!)
        dvc.uid.append(guestId!)
        dvc.ava = ava
      }
    }
  }

}



//:MARK Follow and unfollow

extension GuestViewController {
  
  @IBAction func followBtnTapped(_ sender: UIButton) {
    let title = header?.editProfile.title(for: UIControlState())
    
    // to follow
    if title == "FOLLOW" {
      let object = PFObject(className: "Follow")
      object["follower"] = PFUser.current()?.objectId!
      object["following"] = guestId
      object.saveInBackground(block: { (success:Bool, error) -> Void in
        if success {
          print("\(PFUser.current()?.username) follow \(self.userName)")
          self.header?.editProfile.tintColor = UIColor.white
          self.header?.editProfile.setTitle("FOLLOWING", for: UIControlState())
          setBtnStyleToColor(sender: (self.header?.editProfile)!, color: self.greenColor, borderColor: self.greenColor)
          
          self.follow = "FOLLOWING"
          // Change the followers of the people you follow
          let query = PFQuery(className: "UserInfo")
          query.whereKey("uid", equalTo: self.guestId!)
          query.getFirstObjectInBackground(block: { (object, error) in
            let followers = (object?["followers"] as! Int) + 1
            object?["followers"] = followers
            object?.saveInBackground(block: { (success, error) in
              if success {
                self.collectionView?.reloadData()
              }
            })
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
    }
    else {
    // unfollow
      follow = "FOLLOW"
      let query = PFQuery(className: "Follow")
      query.whereKey("follower", equalTo: PFUser.current()?.objectId!)
      query.whereKey("following", equalTo: guestId)
      query.findObjectsInBackground(block: { (objects:[PFObject]?, error) -> Void in
        if error == nil {
          for object in objects! {
            object.deleteInBackground(block: { (success:Bool, error) -> Void in
              if success {
                print("\(PFUser.current()?.username) unfollow \(self.userName)")
                self.header?.editProfile.tintColor = self.defaultBlue
                self.header?.editProfile.setTitle("FOLLOW", for: UIControlState())
                setBtnStyleToColor(sender: (self.header?.editProfile)!, color: UIColor.white, borderColor: self.defaultBlue)
                
                // Change the followers of the people you follow
                let unfollow = PFQuery(className: "UserInfo")
                unfollow.whereKey("uid", equalTo: self.guestId!)
                unfollow.getFirstObjectInBackground(block: { (object, error) in
                  let followers = (object?["followers"] as! Int) - 1
                  object?["followers"] = followers
                  object?.saveInBackground(block: { (success, error) in
                    if success {
                      self.collectionView?.reloadData()
                    }
                  })
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







