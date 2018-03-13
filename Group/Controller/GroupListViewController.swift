//
//  GroupListViewController.swift
//  Rendezvous
//
//  Created by Admin on 4/15/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class GroupListViewController: UIViewController, UIViewControllerTransitioningDelegate, UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource  {
  
  
  @IBOutlet weak var tabToolbar: UIToolbar!
  @IBOutlet var tableView: UITableView!
  
  var realm = try! Realm()
  lazy var groups: Results<Group> = { self.realm.objects(Group.self)}()
  var group: Group!
  lazy var newGroup = true
  
  var groupListArray: [Group] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    if group == nil {
      group = Group()
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  func tableView(_ myTableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 60
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groups.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! MeetupCellTableViewCell
    let item = groups[(indexPath as NSIndexPath).row]
    cell.groupListLabel?.text = item.groupName
    if item.groupIcon != nil {
      cell.groupIcon.image = UIImage(data: item.groupIcon!)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    group = groups[(indexPath as NSIndexPath).row]
    newGroup = false
    self.performSegue(withIdentifier: "GroupListToChat", sender: self)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      realm.beginWrite()
      realm.delete(groups[(indexPath as NSIndexPath).row])
      try! realm.commitWrite()
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "unwindToGroupList" {
      let viewController = segue.destination as! GroupDetailViewController
      viewController.group = group
    }
    else if segue.identifier == "GroupListToChat" {
      let viewController = segue.destination as! GroupChatViewController
      viewController.group = group
    }
  }
  
  @IBAction func unwindToGroupList(_ sender: Any?) {
  }
}
