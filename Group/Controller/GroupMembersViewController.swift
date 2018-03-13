//
//  GroupMembersViewController.swift
//  Rendezvous
//
//  Created by Admin on 8/16/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class GroupMembersViewController: UIViewController, UITableViewDataSource {
  
  
  @IBOutlet var addFriends: UIButton!
  @IBOutlet var tableView: UITableView!
  
  var realm = try! Realm()
  
  var group: Group!
  var groupMembers = [Contact]()
  var currentContactIndex: Int!
  
  var chatView: GroupChatViewController!
  
  var alert: MembersAlertView!
  var shadow: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    print(group.groupContacts)
    groupMembers = Array(group.groupContacts)
    
    addFriends.backgroundColor = UIColor(red: 51/255, green: 151/255, blue: 219/255, alpha: 1)
    addFriends.layer.cornerRadius = 5
    addFriends.clipsToBounds = true
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func requestFriend(_ contact: Contact) {
    UIView.animate(withDuration: 0.25, animations: {
      self.alert.alpha = 0
      self.shadow.alpha = 0
    })
    alert.removeFromSuperview()
    shadow.removeFromSuperview()
  }
  
  func remove(_ fromMeetup: UIButton) {
    HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "group/\(group.uuid)", data: ["remove_user": "\(groupMembers[currentContactIndex].uuid)"], completionHandler: {returnDict in
      if returnDict["serverCode"] as! Int == 200 {
        DispatchQueue.main.async(execute: {
          self.realm.beginWrite()
          self.group.groupContacts.remove(objectAtIndex: self.currentContactIndex)
          try! self.realm.commitWrite()
          self.groupMembers.remove(at: self.currentContactIndex)
          self.dismissAlert(self)
          self.tableView.reloadData()
        })
      }
      else if returnDict["serverCode"] as! Int == 404 {
        DispatchQueue.main.async(execute: {
          let alertController = UIAlertController(title: nil, message:
            "Failure to remove member from group. Try again.", preferredStyle: UIAlertControllerStyle.alert)
          alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
          
          self.present(alertController, animated: true, completion: nil)
        })
      }
    })
  }
  
  func dismissAlert(_ sender: Any?) {
    UIView.animate(withDuration: 0.25, animations: {
      self.alert.alpha = 0
      self.shadow.alpha = 0
    })
    alert.removeFromSuperview()
    shadow.removeFromSuperview()
  }
  
  @IBAction func addFriends(_ sender: Any?) {
    let storyboard = UIStoryboard(name: "Group", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "addFriends") as! GroupContactSelectionViewController
    viewController.chatView = chatView
    viewController.previousContacts = Set(group.groupContacts)
    viewController.fromExistingGroup = true
    viewController.group = group
    self.navigationController?.pushViewController(viewController, animated: true)
    
  }
  
  @IBAction func backToChat(_ sender: Any?) {
    _ = self.navigationController?.popToViewController(chatView, animated: true)
  }
  
  
}

extension GroupMembersViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return groupMembers.count
  }
  
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
    let item: Contact
    item = groupMembers[(indexPath as NSIndexPath).row]
    cell.label.text = item.fullName
    if item.photo != nil {
      cell.photo.image = UIImage(data: item.photo! as Data)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    shadow = UIView(frame: self.view.frame)
    shadow.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    shadow.alpha = 0
    shadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlert(_:))))
    self.view.addSubview(shadow)
    alert = MembersAlertView(frame: CGRect(x: self.view.bounds.width * 0.15,y: self.view.frame.midY - self.view.bounds.width * 0.4,width: self.view.bounds.width * 0.7, height: self.view.bounds.width * 0.6 + 130))
    alert.requestButton.addTarget(self, action: #selector(requestFriend(_:)), for: .touchUpInside)
    alert.deleteButton.setTitle("Remove From Group", for: UIControlState())
    alert.deleteButton.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
    alert.alpha = 0
    alert.center = self.view.center
    self.view.addSubview(alert)
    
    let item = groupMembers[(indexPath as NSIndexPath).row]
    currentContactIndex = (indexPath as NSIndexPath).row
    alert.requestButton.tag = 4
    alert.deleteButton.tag = 4
    alert.nameLabel.text = item.fullName
    if item.photo == nil {
      alert.photo.image = UIImage(named: "ContactsDefault")
    }
    else {
      alert.photo.image = UIImage(data: item.photo! as Data)
    }
    alert.requestButton.setTitle("Request Friend", for: UIControlState())
    
    UIView.animate(withDuration: 0.25, animations: {
      self.alert.alpha = 1
      self.shadow.alpha = 1
    })
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
