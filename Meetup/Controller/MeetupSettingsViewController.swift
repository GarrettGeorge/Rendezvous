//
//  MeetupSettingsViewController.swift
//  Rendezvous
//
//  Created by Admin on 4/15/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class MeetupSettingsViewController: SettingsSuper {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.title = "Meeutp Settings"

    }

}
