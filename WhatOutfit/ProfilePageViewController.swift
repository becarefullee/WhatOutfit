//
//  ProfilePageViewController.swift
//  UserProfilePage
//
//  Created by Becarefullee on 16/10/25.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ProfilePageViewController: UICollectionViewController {
  
  
  fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
  fileprivate var outfits: [UIImage] = []
  fileprivate var likes: [UIImage] = []
  fileprivate var likesSelected: Bool = false
  fileprivate var header: HeaderCollectionReusableView?
  fileprivate let greyColor: UIColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
  fileprivate let defaultBlue: UIColor = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 1)
  fileprivate var cellWidth: CGFloat {
    return (screenWidth - 12) / 3
  }
  
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
  
  
  func setUpForNavigationBar() {
    if let navigationController = navigationController {
      navigationController.navigationBar.barTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
      navigationController.navigationBar.isTranslucent = false
    }
  }

  
  func refresh(_ sender: AnyObject?) {
    let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      if #available(iOS 10.0, *) {
        self.collectionView?.refreshControl?.endRefreshing()
      } else {
        // Fallback on earlier versions
      }
    }
  }
  
  func setUpDataSource() {
    for i in 0...20 {
      let j = i % 8
      if i > 7 && i < 13 {
        let likesImage = UIImage(named: "IMG_\(i)")
        likes.append(likesImage!)
      }
      let outfitImage = UIImage(named: "IMG_\(j)")
      outfits.append(outfitImage!)
    }
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
      return likes.count
    }
    return outfits.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
    if likesSelected {
        cell.imageView.image = likes[indexPath.row]
    }else {
        cell.imageView.image = outfits[indexPath.row]
    }
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    switch kind {
    case UICollectionElementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath) as! HeaderCollectionReusableView
      header = headerView
      headerView.profilePicture.image = UIImage(named: "IMG")
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




