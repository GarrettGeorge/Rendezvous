//
//  ContactSelectionViewController.swift
//  Rendezvous
//
//  Created by Admin on 5/31/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class MeetupContactSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate {
  
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var done: UIBarButtonItem!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var contactsButton: UIButton!
  @IBOutlet var groupsButton: UIButton!
  
  let searchController = UISearchController(searchResultsController: nil)
  var realm = try! Realm()
  lazy var contacts: Results<Contact> = { self.realm.objects(Contact.self).sorted(byProperty: "fullName")}()
  lazy var groups: Results<Group> = { self.realm.objects(Group.self).sorted(byProperty: "groupName")}()
  var meetupContacts = List<Contact>()
  var previousContacts = Set<Contact>()
  var contactsToView = [Contact]()
  var filteredContacts = [Contact]()
  var savedContacts = [Contact]()
  
  var meetupGroups = List<Group>()
  var previousGroups = Set<Group>()
  var groupsToView = [Group]()
  var filteredGroups = [Group]()
  var savedGroups = [Group]()
  
  var meetup: Meetup?
  
  var fromExistingMeetup = false
  var chatView: MeetupChatViewController!
  
  var meetupDict: [NSString: Dictionary<String,Any>] = [
    "strings": [
      "meetupName": "" as Any,
      "details": "" as Any,
      "locationName": "" as Any,
      "locationAddress": "" as Any,
      "timeOfMeetup": "" as Any,
      "uniqueID": "" as Any,
      "leader": "" as Any
    ],
    "location": [
      "latitude": 0.0,
      "longitude": 0.0
    ],
    "members": [
      "contactsArray": [[
        "contactID": ""
        ]],
      "groupsArray": [[
        "groupID", ""
        ]]
    ]
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //print(contacts)
    
    self.hidesBottomBarWhenPushed = true
    self.tabBarController?.tabBar.isHidden = true
    
    contactsButton.showsTouchWhenHighlighted = false
    contactsButton.isEnabled = false
    contactsButton.setTitleColor(UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1), for: .disabled)
    groupsButton.setTitleColor(UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1), for: .disabled)
    
    searchBar.delegate = self
    searchController.searchBar.delegate = searchBar.delegate
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    searchController.hidesNavigationBarDuringPresentation = false
    
    filteredContacts = Array(contactsToView)
    filteredGroups = Array(groupsToView)
    
    tableView.allowsMultipleSelection = true
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    tableView.register(GroupCell.self, forCellReuseIdentifier: "GroupCell")
    
    self.searchController.loadViewIfNeeded()
    
  }
  
  deinit {
    self.searchController.loadViewIfNeeded()
    let _ = self.searchController.view
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    dupeCheck()
    tableView.reloadData()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
  @IBAction func contactsSelected(_ sender: Any) {
    self.view.endEditing(true)
    groupsButton.isEnabled = true
    contactsButton.isEnabled = false
    tableView.reloadData()
  }
  
  @IBAction func groupsSelected(_ sender: Any) {
    self.view.endEditing(true)
    contactsButton.isEnabled = true
    groupsButton.isEnabled = false
    tableView.reloadData()
  }
  
  func dismissSearchBar(_ sender: Any) {
    self.searchBar.endEditing(true)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return !contactsButton.isEnabled ? "Added Contacts" : "Added Groups"
    case 1:
      return !contactsButton.isEnabled ? "All Contacts" : "All Groups"
    default:
      return ""
    }
    
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 45
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return !contactsButton.isEnabled ? savedContacts.count : savedGroups.count
    case 1:
      if searchBar.isFirstResponder && self.searchBar.text != "" {
        return contactsButton.isEnabled ? filteredGroups.count : filteredContacts.count
      }
      return contactsButton.isEnabled ? groupsToView.count : contactsToView.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //print(indexPath.section)
    //print(indexPath.row)
    if !contactsButton.isEnabled {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
      let item: Contact
      if (indexPath as NSIndexPath).section == 0 {
        item = savedContacts[(indexPath as NSIndexPath).row]
      }
      else {
        if searchBar.isFirstResponder && self.searchBar.text != "" {
          item = filteredContacts[(indexPath as NSIndexPath).row]
        }
        else {
          item = contactsToView[contactsToView.startIndex.advanced(by: (indexPath as NSIndexPath).row)]
        }
      }
      if item.photo != nil {
        cell.photo.image = UIImage(data: item.photo! as Data)
      }
      cell.label?.text = item.fullName
      cell.selectionStyle = .none
      cell.accessoryType = .none
      return cell
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
      let item: Group
      if (indexPath as NSIndexPath).section == 0 {
        item = savedGroups[(indexPath as NSIndexPath).row]
      }
      else {
        if searchBar.isFirstResponder && self.searchBar.text != "" {
          item = filteredGroups[(indexPath as NSIndexPath).row]
        }
        else {
          item = groupsToView[groupsToView.startIndex.advanced(by: (indexPath as NSIndexPath).row)]
        }
      }
      if item.groupIcon != nil {
        cell.photo.image = UIImage(data: item.groupIcon! as Data)
      }
      cell.label?.text = item.groupName
      cell.selectionStyle = .none
      cell.accessoryType = .none
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.searchBar.text == "" {
      if contactsButton.isEnabled {
        filteredGroups = Array(groupsToView)
      }
      else {
        filteredContacts = Array(contactsToView)
      }
    }
    
    if (indexPath as NSIndexPath).section == 0 {
      if !contactsButton.isEnabled {
        filteredContacts.append(savedContacts[(indexPath as NSIndexPath).row])
        savedContacts.remove(at: (indexPath as NSIndexPath).row)
        contactsToView = filteredContacts.sorted {
          $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending
        }
      }
      else {
        filteredGroups.append(savedGroups[(indexPath as NSIndexPath).row])
        savedGroups.remove(at: (indexPath as NSIndexPath).row)
        groupsToView = filteredGroups.sorted {
          $0.groupName.localizedCaseInsensitiveCompare($1.groupName) == .orderedAscending
        }
      }
    }
    else {
      if !contactsButton.isEnabled {
        savedContacts.append(filteredContacts[(indexPath as NSIndexPath).row])
        filteredContacts.remove(at: (indexPath as NSIndexPath).row)
        contactsToView = filteredContacts
      }
      else {
        savedGroups.append(filteredGroups[(indexPath as NSIndexPath).row])
        filteredGroups.remove(at: (indexPath as NSIndexPath).row)
        groupsToView = filteredGroups
      }
      
    }
    
    self.tableView.reloadData()
  }
  
  func dupeCheck() {
    var contactsToView = Set(contacts)
    contactsToView.formSymmetricDifference(previousContacts)
    self.contactsToView = contactsToView.sorted {
      $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending
    }
    var groupsToview = Set(groups)
    groupsToview.formSymmetricDifference(previousGroups)
    self.groupsToView = groupsToview.sorted {
      $0.groupName.localizedCaseInsensitiveCompare($1.groupName) == .orderedAscending
    }
  }
  
  func updateMeetupContacts(_ meetup: Meetup?) -> Meetup{
    if meetup != nil {
      meetupContacts.append(objectsIn: savedContacts)
      meetupGroups.append(objectsIn: savedGroups)
      return self.meetup!
    }
    else {
      return Meetup()
    }
  }
  
  //MARK: Search Functions
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if contactsButton.isEnabled {
      filteredGroups = groupsToView.filter { group in
        return group.groupName.lowercased().contains(self.searchBar.text!.lowercased())
      }
      filteredGroups = filteredGroups.sorted {
        $0.groupName.localizedCaseInsensitiveCompare($1.groupName) == .orderedAscending
      }
    }
    else {
      filteredContacts = contactsToView.filter { contact in
        return contact.fullName.lowercased().contains(self.searchBar.text!.lowercased())
      }
      filteredContacts = filteredContacts.sorted {
        $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending
      }
      
    }
    
    
    tableView.reloadData()
    
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "AddFriendsToChat" {
    //            let viewController = segue.destinationViewController as! MeetupChatViewController
    //            viewController.meetup = meetup
    //            realm.beginWrite()
    //            realm.add(meetup)
    //            try! realm.commitWrite()
    //
    //            if let returned = HTTPRequestManager.sharedInstance.makeHTTPCall(url: "garrettgeorge/meetups/\(meetup.meetupName)", method: "POST", data: meetupDict) {
    //                print(returned)
    //            }
    //            self.navigationController?.pushViewController(MeetupListViewController(), animated: false)
    //        }
  }
  
  @IBAction func toChat(_ sender: Any) {
    
    if !fromExistingMeetup {
      let meetup = updateMeetupContacts(self.meetup)
      try! realm.write {
        realm.add(meetup)
        meetup.contacts.append(objectsIn: meetupContacts)
        meetup.groups.append(objectsIn: meetupGroups)
      }
      if self.tabBarController?.selectedIndex == 0 {
        let storyboard = UIStoryboard(name: "Meetup", bundle: nil)
        let tabController = self.tabBarController
        let tabBarArray = tabController?.viewControllers
        let navController = tabBarArray![1] as! UINavigationController
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetupChat") as! MeetupChatViewController
        let listController = storyboard.instantiateViewController(withIdentifier: "MeetupList") as! MeetupListViewController
        viewController.meetup = meetup
        _ = self.navigationController?.popToRootViewController(animated: false)
        viewController.hidesBottomBarWhenPushed = true
        navController.pushViewController(listController, animated: false)
        navController.pushViewController(viewController, animated: true)
        tabController?.selectedIndex = 1
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "clearNewMeetup"), object: nil)
      }
      else {
        let storyboard = UIStoryboard(name: "Meetup", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MeetupChat") as! MeetupChatViewController
        viewController.meetup = meetup
        let navController = self.navigationController
        _ = self.navigationController?.popToRootViewController(animated: false)
        navController?.pushViewController(viewController, animated: true)
      }
    }
    else {
      realm.beginWrite()
      meetup?.contacts.append(objectsIn: savedContacts)
      meetup?.groups.append(objectsIn: savedGroups)
      try! realm.commitWrite()
      _ = self.navigationController?.popToViewController(chatView, animated: true)
    }
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
