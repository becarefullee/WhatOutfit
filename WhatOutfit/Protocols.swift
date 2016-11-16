//
//  Protocols.swift
//  WhatOutfit
//
//  Created by Becarefullee on 16/11/15.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import Foundation


protocol UpdateLike {
  func updateLikeBtn(index: Int, isliked: Bool, needReload: Bool)
  func performSegue(identifier: String, index: Int)
}

protocol CellDelegate {
  func performSegue(identifier: String, guestId: String, guestName: String)
}
