//
//  EditProfileViewController.swift
//  WhatOutfit
//
//  Created by becarefullee on 2016/11/19.
//  Copyright © 2016年 Becarefullee. All rights reserved.
//

import UIKit

class EditProfileViewController: UITableViewController {
    
    @IBOutlet weak var ava: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
