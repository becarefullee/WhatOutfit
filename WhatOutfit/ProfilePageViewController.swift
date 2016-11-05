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

  fileprivate var outfitsImageSet: [UIImage?] = []
  fileprivate var likesImageSet: [UIImage?] = []

  fileprivate let network: String = "Network"
  fileprivate let local: String = "Local"
  fileprivate var numberOfPosts: Int = 0
  fileprivate var likesId: [String] = []
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
    let hasUpload = UserDefaults.standard.bool(forKey: "hasUpload")
    if hasUpload {
      loadPosts(from: network)
      UserDefaults.standard.set(false, forKey: "hasUpload")
      UserDefaults.standard.synchronize()
    }
    collectionView?.reloadData()
    loadPosts(from: network)
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
    loadPosts(from: network)
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
      return likesImageSet.count
    }
      return outfitsImageSet.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
    if likesSelected {
      cell.imageView.image = likesImageSet[indexPath.row]
    }else {
      cell.imageView.image = outfitsImageSet[indexPath.row]
    }
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath) as! HeaderCollectionReusableView
      header = headerView
      
      let query = PFQuery(className: "UserInfo")
      query.whereKey("uid", equalTo: (PFUser.current()!.objectId)!)
      query.getFirstObjectInBackground(block: { (object, error) in
        //Followers
        let followers = object?["followers"] as! Int
        headerView.numberOfFollowers.setTitle("\(followers)", for: .normal)
        
        //Followings
        let followings = object?["followings"] as! Int
        headerView.numberOfFollowing.setTitle("\(followings)", for: .normal)
      })
      
      //Likes
      let likes = PFUser.current()!.object(forKey: "likes") as! Int
      headerView.numberOfLikes.setTitle("\(likes)", for: .normal)

      
      setBtnStyleToColor(sender: (header?.editProfile)!, color: lightGreyColor, borderColor: lightGreyColor)
      
      //Nickname
      headerView.nameLabel.text = PFUser.current()!.object(forKey: "nickname") as? String
      
      //What's up
       headerView.whatsupLabel.text = PFUser.current()!.object(forKey: "bio") as? String
      
      //Post
      let posts = PFUser.current()!.object(forKey: "posts") as! Int
      headerView.numberOfPosts.setTitle("\(posts)", for: .normal)
      
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
      
          let count = objects?.count
          print(count)
    
          guard count != 0 else {
          return
          }
          self.outfitId.removeAll(keepingCapacity: false)
          self.likesImageSet.removeAll(keepingCapacity: false)
          self.outfitsImageSet.removeAll(keepingCapacity: false)
          if error == nil {
            if self.likesSelected {
              self.likesImageSet = Array(repeating: UIImage(named: "pbg"), count: count!) as [UIImage?]
            }else{
              self.outfitsImageSet = Array(repeating: UIImage(named: "pbg"), count: count!) as [UIImage?]
            }
  
    
            for i in 0...count!-1{
              if from == self.network {
                objects?[i].pinInBackground(block: { (success, error) in
                })
              }
              let contentImage = objects?[i].value(forKey: "pic") as! PFFile
              contentImage.getDataInBackground(block: { (data, error) in
                if error == nil{
                  let image = UIImage(data:data!)
                    if self.likesSelected {
                      self.likesImageSet[i] = image!
                      self.likesId.append((objects?[i].objectId!)!)
                    }else{
                      self.outfitsImageSet[i] = image!
                      self.outfitId.append((objects?[i].objectId!)!)
                      print(i)
                    }
                  
                   let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                  if i == count!-1{
                    DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                      self.collectionView?.reloadData()
                    })
                  }
                }else{
                  print("Getdatafailed")
                }
              })
            }
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



