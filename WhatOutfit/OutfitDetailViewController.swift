//
//  OutfitDetailViewController.swift
//  WhatOutfit
//
//  Created by Becarefullee on 16/11/8.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//


import UIKit
import Parse

class OutfitDetailViewController: UITableViewController {

  @IBOutlet var carousel: iCarousel!
  @IBOutlet weak var likesLabel: UILabel!
  @IBOutlet weak var likeBtn: UIButton!
  
  @IBOutlet weak var moreBtn: UIBarButtonItem!
  
  
  @IBAction func actions(_ sender: UIBarButtonItem) {
    let delete = FloatingAction(title: "Delete") { action in
      self.deleteOutfit()
    }
    if userNameArray.first == PFUser.current()?.username {
      delete.textColor = UIColor.white
      delete.tintColor = UIColor(red: 1, green: 0.41, blue: 0.38, alpha: 1)
      delete.font = UIFont(name: "Avenir-Light", size: 17)
      let cancel = FloatingAction(title: "Cancel") { action in
      }
      cancel.textColor = UIColor.black
      cancel.tintColor = UIColor.white
      cancel.font = UIFont(name: "Avenir-Light", size: 17)
      let group1 = FloatingActionGroup(action: delete, cancel)
      FloatingActionSheetController(actionGroup: group1,animationStyle: .slideUp)
        .present(in: self)
    } else {
      let cancel = FloatingAction(title: "Cancel") { action in
      }
      cancel.textColor = UIColor.black
      cancel.tintColor = UIColor.white
      cancel.font = UIFont(name: "Avenir-Light", size: 17)
      let group1 = FloatingActionGroup(action: cancel)
      FloatingActionSheetController(actionGroup: group1,animationStyle: .slideUp)
        .present(in: self)
    }
  }

  @IBAction func likeBtnPressed(_ sender: UIButton) {
    if isLiked! {
      updateLikeRelation(operation: .delete)
      if let index = index {
        delegate?.updateLikeBtn(index: index, isliked: false, needReload: true)
      }
    }else{
      updateLikeRelation(operation: .add)
      if let index = index {
        delegate?.updateLikeBtn(index: index, isliked: true, needReload: true)
      }
    }
  }
  
    var delegate: UpdateLike?
  
  
    var index: Int?
    var count: Int = 0
    var contentImageSet: [UIImage?] = []
    var ava :UIImage?
    var likes: Int?
    var postId: [String] = []
    var isLiked: Bool?
    var userNameArray: [String] = []
    var uid: [String] = []
    var date: Date?

    fileprivate var followGuest: String?
    fileprivate var toGuest: String?
    fileprivate var guestName: String?

    fileprivate var screenWidth: CGFloat = UIScreen.main.bounds.width
    fileprivate let contentCellHeight: CGFloat = UIScreen.main.bounds.width + 44

    override func viewDidLoad() {
        super.viewDidLoad()
        likesLabel.text = "\(self.converLikesToString(numberOfLikes: self.likes!)) likes"
        if isLiked! {
          likeBtn.setImage(likeImage, for: .normal)
        }else{
          likeBtn.setImage(unlikeImage, for: .normal)
        }
        loadDetails()
        carousel.type = .rotary
        carousel.bounceDistance = 0.2
        carousel.decelerationRate = 0.8
        carousel.isPagingEnabled = true
        carousel.isScrollEnabled = false
        carousel.clipsToBounds = true
    }
}



//MARK: TableView Datasource and delegate
extension OutfitDetailViewController {
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let headerCell = view as! HeaderCell
    headerCell.userId = uid[0]
    headerCell.profileImage.image = ava!
    headerCell.postTime.text =  headerCell.convertDateToString(date: self.date!)
    headerCell.userName.text = userNameArray[0]
    headerCell.backgroundColor = UIColor.white
    headerCell.alpha = 1.0
  }
  
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
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


//:MARK CellDelegate

extension OutfitDetailViewController: CellDelegate {
  func performSegue(identifier: String, guestId: String, guestName: String) {
    
    // Query follow realtion
    if PFUser.current()?.objectId != guestId {
      let query = PFQuery(className: "Follow")
      query.whereKey("follower", equalTo: PFUser.current()?.objectId!)
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




//:MARK Segue

extension OutfitDetailViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showGuest" {
      let dvc = segue.destination as! GuestViewController
      dvc.guestId = toGuest
      dvc.userName = guestName
      dvc.follow = followGuest
    }
  }
}


//:MARK LoadDetail

extension OutfitDetailViewController {
  func loadDetails() {
  contentImageSet.removeAll(keepingCapacity: false)
    contentImageSet =  Array(repeating: UIImage(named: "pbg"), count: 4)
  let query = PFQuery(className: "Post")
  query.getObjectInBackground(withId: postId.first!) { (object, error) in
    let pfFileArray = object?["outfits"] as! NSArray
    self.count = pfFileArray.count
    if self.count > 1 {
      self.carousel.isScrollEnabled = true
    }
    for i in 0...pfFileArray.count-1 {
      let image = pfFileArray[i] as! PFFile
      image.getDataInBackground(block: { (data, error) in
        self.contentImageSet[i] = (UIImage(data: data!))
        self.carousel.reloadData()
        })
      }
    }
  }
}

//:MARK iCarouselDataSource, iCarouselDelegate

extension OutfitDetailViewController: iCarouselDataSource, iCarouselDelegate {
  
  func numberOfItems(in carousel: iCarousel) -> Int {
    return count
  }
  
  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    var itemView: UIImageView
    
    //reuse view if available, otherwise create a new view
    if let view = view as? UIImageView {
      itemView = view
    } else {
      itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
      itemView.image = contentImageSet[index]
      itemView.layer.cornerRadius = 8
      itemView.layer.masksToBounds = true
      itemView.contentMode = .scaleAspectFill
    }
    return itemView
  }
  
  func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
    if (option == .spacing) {
      return value * 1.1
    }
    if (option == .fadeMinAlpha) {
      return value + 1.0
    }
    return value
  }
}


//:MARK Helper method

extension OutfitDetailViewController {
  
  func converLikesToString(numberOfLikes: Int) -> String{
    var number:String = String(numberOfLikes)
    switch numberOfLikes {
    case 0..<1000:
      return number
    case 1000..<1000000:
      let index = number.index(number.endIndex, offsetBy: -3)
      number.insert(",", at: index)
      return number
    case 1000000..<1000000000:
      var index = number.index(number.endIndex, offsetBy: -3)
      number.insert(",", at: index)
      index = number.index(number.endIndex, offsetBy: -7)
      number.insert(",", at: index)
      return number
    default:
      return number
      
    }
  }


  func updateLikeRelation(operation: operation) {
    switch operation {
    case .add:
      //Add a like relation
      let object = PFObject(className: "Like")
      object["uid"] = PFUser.current()?.objectId!
      object["pid"] = self.postId.first
      object.saveInBackground { (success, error) in
        if success {
          self.likeBtn.setImage(likeImage, for: .normal)
          self.likes = self.likes! + 1
          self.likesLabel.text = "\(self.converLikesToString(numberOfLikes: self.likes!)) likes"
          self.isLiked = !self.isLiked!
          
          print("Update Sucess")
          
          //CurrentUser's Likes plus one
          PFUser.current()?.incrementKey("likes")
          PFUser.current()?.saveInBackground(block: { (success, error) in
            if success {
              print("User likes update")
            }
          })
          //Post's like plus one
          let query = PFQuery(className: "Post")
          query.getObjectInBackground(withId: self.postId.first!, block: { (object, error) in
            object?.incrementKey("likes")
            object?.saveInBackground(block: { (success, error) in
              if success {
                print("Likes updated")
              }else {
                print(error!.localizedDescription)
              }
            })
          })
          
        }else {
          print(error!.localizedDescription)
        }
      }
      
    case .delete:
      //Delete a like relation
      let query = PFQuery(className: "Like")
      query.whereKey("pid", equalTo: postId.first)
      query.whereKey("uid", equalTo: PFUser.current()?.objectId!)
      query.findObjectsInBackground { (objects, error) in
        if (objects?.count)! > 0 {
          objects?.first?.deleteInBackground(block: { (success, error) in
            if success {
              self.likeBtn.setImage(unlikeImage, for: .normal)
              self.likes = self.likes! - 1
              self.likesLabel.text = "\(self.converLikesToString(numberOfLikes: self.likes!)) likes"
              self.isLiked = !self.isLiked!
              print("Delete Success")
              
              //CurrentUser's Likes minus one
              PFUser.current()?.incrementKey("likes", byAmount: -1)
              PFUser.current()?.saveInBackground(block: { (success, error) in
                if success {
                  print("User likes update")
                }
              })
              //Post's like minus one
              let query = PFQuery(className: "Post")
              query.getObjectInBackground(withId: self.postId.first!, block: { (object, error) in
                object?.incrementKey("likes", byAmount: -1)
                object?.saveInBackground(block: { (success, error) in
                  if success {
                    print("Likes updated")
                  }else {
                    print(error!.localizedDescription)
                  }
                })
              })
            }else {
              print(error!.localizedDescription)
            }
          })
        }
      }
    }
  }
  
  func deleteOutfit() {
    let query = PFQuery(className: "Post")
    query.getObjectInBackground(withId: postId.first!) { (object, error) in
      let imageData = UIImageJPEGRepresentation(UIImage(named: "unknown")!, 0.5)
      let file = PFFile(name: "unknown", data: imageData!)
      object?["uid"] = ""
      object?["username"] = "Unknown"
      object?["ava"] = file
      object?.saveInBackground(block: { (success, error) in
        print("ChangeSuccess")
        PFUser.current()?.incrementKey("posts", byAmount: -1)
        PFUser.current()?.saveInBackground()
        self.navigationController?.popViewController(animated: true)
      })
      
   /*   object?.deleteInBackground(block: { (success, error) in
        if success {
          PFUser.current()?.incrementKey("posts", byAmount: -1)
          PFUser.current()?.saveInBackground()
          
          let query = PFQuery(className: "Like")
          query.whereKey("pid", equalTo: self.postId.first!)
          query.findObjectsInBackground(block: { (objects, error) in
      
            var relatedUser: [String] = []
            for object in objects! {
              relatedUser.append(object["uid"] as! String)
              object["uid"] = ""
              object.saveInBackground()
            }
//            let query = PFQuery(className: "UserInfo")
//            query.whereKey("uid", containedIn: relatedUser)
//            query.findObjectsInBackground(block: { (objects, error) in
//              for object in objects! {
//                object.incrementKey("like", byAmount: -1)
//                object.saveInBackground()
//              }
//            })
            
          })       
         }
       })    */
    }
  }
  
}








