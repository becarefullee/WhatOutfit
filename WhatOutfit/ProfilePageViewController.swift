//
//  ProfilePageViewController.swift
//  UserProfilePage
//
//  Created by Becarefullee on 16/10/25.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"

class ProfilePageViewController: UICollectionViewController {

  
  fileprivate let network: String = "Network"
  fileprivate let local: String = "Local"
  fileprivate var numberOfPosts: Int = 0
  fileprivate var likesImage: [PFFile] = []
  fileprivate var likesId: [String] = []
  fileprivate var outfitImage: [PFFile] = []
  fileprivate var outfitId: [String] = []
  fileprivate var page : Int = 9
  fileprivate var likesSelected: Bool = false
  fileprivate var header: HeaderCollectionReusableView?
  fileprivate let greyColor: UIColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
  fileprivate let lightGreyColor: UIColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
  fileprivate let defaultBlue: UIColor = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1)
  
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate var cellWidth: CGFloat {
    return (screenWidth - 12) / 3
  }
  fileprivate let anchor: CGPoint = CGPoint(x:0, y:240)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDataSource()
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
  }
  
  
  func setUpForNavigationBar() {
    self.navigationItem.title = PFUser.current()?.username
    if let navigationController = navigationController {
      navigationController.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
      navigationController.navigationBar.isTranslucent = false
    }
  }

  
  func refresh(_ sender: AnyObject?) {
    loadPosts(from: network)
    if #available(iOS 10.0, *) {
      self.collectionView?.refreshControl?.endRefreshing()
    } else {
      // Fallback on earlier versions
    }
  }

  func setUpDataSource() {
    loadPosts(from: local)
  }
}

//:MARK Change Section

extension ProfilePageViewController {
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


extension ProfilePageViewController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if likesSelected {
      return likesImage.count
    }
    return outfitImage.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
    if likesSelected {
      _ = likesImage[indexPath.row].getDataInBackground(block: { (data, error) in
        guard error == nil else {
          print(error!.localizedDescription)
          return
        }
          cell.imageView.image = UIImage(data: data!)!
      })
    }else {
      let image = try? outfitImage[indexPath.row].getData()
      cell.imageView.image = UIImage(data: image!)
    }
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath) as! HeaderCollectionReusableView
      header = headerView
      setBtnStyleToColor(sender: (header?.editProfile)!, color: lightGreyColor, borderColor: lightGreyColor)

      //Nickname
      headerView.nameLabel.text = PFUser.current()!.object(forKey: "nickname") as? String
      
      //Likes
      let likes = PFUser.current()!.object(forKey: "likes") as! Int
      headerView.numberOfLikes.setTitle("\(likes)", for: .normal)
      
      //What's up
       headerView.whatsupLabel.text = PFUser.current()!.object(forKey: "bio") as? String
      
      //Post
      let posts = PFQuery(className: "Post")
      posts.whereKey("uid", equalTo: PFUser.current()!.objectId!)
      posts.countObjectsInBackground (block: { (count, error) -> Void in
        if error == nil {
          self.numberOfPosts = Int(count)
          headerView.numberOfPosts.setTitle("\(count)", for: .normal)
        }
      })
      
      
      //Followers
      let followers = PFQuery(className: "Follow")
      followers.whereKey("following", equalTo: PFUser.current()!.objectId!)
      followers.countObjectsInBackground (block: { (count:Int32, error) -> Void in
        if error == nil {
          headerView.numberOfFollowers.setTitle("\(count)", for: .normal)
        }
      })
      
      //Followings
      let followings = PFQuery(className: "Follow")
      followings.whereKey("follower", equalTo: PFUser.current()!.objectId!)
      followings.countObjectsInBackground (block: { (count:Int32, error) -> Void in
        if error == nil {
          headerView.numberOfFollowing.setTitle("\(count)", for: .normal)
        }
      })
      
      
      //Profile pic
      if let profilePciture = PFUser.current()!.object(forKey: "ava") as? PFFile {
        profilePciture.getDataInBackground(block: { (data, error) in
          headerView.profilePicture.image = UIImage(data: data!)
        })
      }
  
      return headerView
    default:
      assert(false, "Unexpected element kind")
    }
  }
}

//:MARK Resize the CollectionvViewCell based on screen size


extension ProfilePageViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: cellWidth, height: cellWidth)
  }
  
}


extension ProfilePageViewController {
//  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
//      loadMore()
//    }
//  }
  
  @IBAction func postBtnPressed(_ sender: UIButton) {
    scrollToCertainPoint(scrollView: collectionView!, point: anchor)
  }
  
  func scrollToCertainPoint(scrollView: UIScrollView, point: CGPoint) {
    scrollView.setContentOffset(CGPoint(x: point.x, y: point.y), animated: true)
  }
}




//:MARK Network

extension ProfilePageViewController {
  
  
//  func loadMore() {
//    
//    if page <= outfitImage.count {
//      
//      // increase page size
//      page = page + 9
//      loadPosts(from: network)
//      
//    }
//
//  }
  
  
  // Load Outfit
  func loadPosts(from: String) {
    var query = PFQuery(className: "Post")
    if likesSelected {
      query = PFQuery(className: "Like")
    }
    if from == local {
      query.fromLocalDatastore()
    }
//    if from == network {
//      query.limit = page
//    }
    query.whereKey("uid", equalTo: PFUser.current()!.objectId!)
    query.addDescendingOrder("createdAt")
    query.findObjectsInBackground (block: { (objects:[PFObject]?, error) -> Void in

          if error == nil {

            self.outfitImage.removeAll(keepingCapacity: false)
            self.likesImage.removeAll(keepingCapacity: false)
            
            for object in objects! {
              if from == self.network {
                object.pinInBackground(block: { (success, error) in
                })
              }
              let contentImage = object.value(forKey: "pic") as! PFFile
              if self.likesSelected {
                self.likesImage.append(contentImage)
                self.likesId.append(object.objectId!)
              }else {
                self.outfitImage.append(contentImage)
                self.outfitId.append(object.objectId!)
              }
        }
            self.collectionView?.reloadData()
      } else {
        print(error!.localizedDescription)
      }
    })
  }
}


//:MARK Segues


extension ProfilePageViewController {
  
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
      dvc.userId = PFUser.current()?.objectId!
      dvc.userName = PFUser.current()?.username!
    }
  }
}



