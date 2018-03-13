//
//  MeetupMembersViewController.swift
//  Rendezvous
//
//  Created by Admin on 7/24/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class MeetupMembersViewController: UIViewController, UITableViewDataSource {
  
  @IBOutlet var addFriends: UIButton!
  @IBOutlet var contactsSelector: UIButton!
  @IBOutlet var groupsSelector: UIButton!
  @IBOutlet var tableView: UITableView!
  var buttonBorder: UIView!
  
  var meetup: Meetup!
  
  var realm = try! Realm()
  
  var groupMembers = [Group]()
  var contactMembers = [Contact]()
  
  var currentContact: Contact!
  var currentContactIndex: Int!
  var currentGroup: Group!
  var currentGroupIndex: Int!
  
  var chatView: MeetupChatViewController!
  
  var alert: MembersAlertView!
  var shadow: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    buttonBorder = UIView(frame: CGRect(x: contactsSelector.frame.maxX,y: contactsSelector.frame.minY,width: 1,height: contactsSelector.frame.size.height))
    buttonBorder.backgroundColor = UIColor.lightGray
    self.view.addSubview(buttonBorder)
    
    groupMembers = Array(meetup.groups)
    contactMembers = Array(meetup.contacts)
    
    contactMembers = contactMembers.sorted {
      $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending
    }
    groupMembers = groupMembers.sorted {
      $0.groupName.localizedCaseInsensitiveCompare($1.groupName) == .orderedAscending
    }
    
    contactsSelector.isEnabled = false
    contactsSelector.showsTouchWhenHighlighted = false
    contactsSelector.setTitleColor(UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1), for: .disabled)
    groupsSelector.showsTouchWhenHighlighted = false
    groupsSelector.setTitleColor(UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1), for: .disabled)
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    tableView.register(GroupCell.self, forCellReuseIdentifier: "GroupCell")
    
    addFriends.backgroundColor = UIColor(red: 51/255, green: 151/255, blue: 219/255, alpha: 1)
    addFriends.layer.cornerRadius = 5
    addFriends.clipsToBounds = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    buttonBorder.frame = CGRect(x: contactsSelector.frame.maxX,y: contactsSelector.frame.minY,width: 1,height: contactsSelector.frame.size.height)
  }
  
  @IBAction func contactsSelected(_ sender: AnyObject) {
    contactsSelector.isEnabled = false
    groupsSelector.isEnabled = true
    tableView.reloadData()
  }
  
  @IBAction func groupsSelected(_ sender: AnyObject) {
    contactsSelector.isEnabled = true
    groupsSelector.isEnabled = false
    tableView.reloadData()
  }
  
  func request(_ sender: UIButton) {
    if sender.tag == 4 {
      requestFriend(currentContact)
    }
    else{
      requestInvitation(currentGroup)
    }
  }
  
  func requestFriend(_ contact: Contact) {
    UIView.animate(withDuration: 0.25, animations: {
      self.alert.alpha = 0
      self.shadow.alpha = 0
    })
    alert.removeFromSuperview()
    shadow.removeFromSuperview()
  }
  
  func requestInvitation(_ group: Group) {
    
  }
  
  func remove(_ fromMeetup: UIButton) {
    print(fromMeetup.tag)
    if fromMeetup.tag == 4 {
      realm.beginWrite()
      meetup.contacts.remove(objectAtIndex: currentContactIndex)
      try! realm.commitWrite()
      contactMembers.remove(at: currentContactIndex)
    }
    else {
      realm.beginWrite()
      meetup.groups.remove(objectAtIndex: currentGroupIndex)
      try! realm.commitWrite()
      groupMembers.remove(at: currentGroupIndex)
    }
    dismissAlert(self)
    tableView.reloadData()
  }
  
  func dismissAlert(_ sender: AnyObject) {
    UIView.animate(withDuration: 0.25, animations: {
      self.alert.alpha = 0
      self.shadow.alpha = 0
    })
    alert.removeFromSuperview()
    shadow.removeFromSuperview()
  }
  
  @IBAction func addFriends(_ sender: AnyObject) {
    let storyboard = UIStoryboard(name: "Meetup", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "AddFriends") as! MeetupContactSelectionViewController
    viewController.previousContacts = Set(meetup.contacts)
    viewController.previousGroups = Set(meetup.groups)
    viewController.meetup = meetup
    viewController.fromExistingMeetup = true
    viewController.chatView = chatView
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  @IBAction func done(_ sender: Any) {
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

extension MeetupMembersViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contactsSelector.isEnabled ? groupMembers.count : contactMembers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if !contactsSelector.isEnabled {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
      let item: Contact
      item = contactMembers[(indexPath as NSIndexPath).row]
      cell.label.text = item.fullName
      if item.photo != nil {
        cell.photo.image = UIImage(data: item.photo! as Data)
      }
      return cell
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupCell
      let item = groupMembers[(indexPath as NSIndexPath).row]
      cell.label.text = item.groupName
      if item.groupIcon != nil {
        cell.photo.image = UIImage(data: item.groupIcon! as Data)
      }
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    shadow = UIView(frame: self.view.frame)
    shadow.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    shadow.alpha = 0
    shadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlert(_:))))
    self.view.addSubview(shadow)
    alert = MembersAlertView(frame: CGRect(x: self.view.bounds.width * 0.15,y: self.view.frame.midY - self.view.bounds.width * 0.4,width: self.view.bounds.width * 0.7, height: self.view.bounds.width * 0.6 + 130))
    alert.requestButton.addTarget(self, action: #selector(request(_:)), for: .touchUpInside)
    alert.deleteButton.setTitle("Remove From Meetup", for: UIControlState())
    alert.deleteButton.addTarget(self, action: #selector(remove(_:)), for: .touchUpInside)
    alert.alpha = 0
    alert.center = self.view.center
    self.view.addSubview(alert)
    
    if !contactsSelector.isEnabled {
      let item = contactMembers[(indexPath as NSIndexPath).row]
      currentContact = item
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
    }
    else {
      let item = groupMembers[(indexPath as NSIndexPath).row]
      currentGroup = item
      currentGroupIndex = (indexPath as NSIndexPath).row
      alert.requestButton.tag = 5
      alert.nameLabel.text = item.groupName
      if item.groupIcon == nil {
        alert.photo.image = UIImage(named: "defaultGroupIcon")
      }
      else {
        alert.photo.image = UIImage(data: item.groupIcon! as Data)
      }
      alert.requestButton.setTitle("Request Invitation", for: UIControlState())
      
    }
    UIView.animate(withDuration: 0.25, animations: {
      self.alert.alpha = 1
      self.shadow.alpha = 1
    })
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
