//
//  GroupContactSelectionViewController.swift
//  Rendezvous
//
//  Created by Admin on 6/2/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

protocol GroupContactSelectionViewControllerDelegate {
  func updateContacts(_ data: List<Contact>)
}
class GroupContactSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
  
  // MARK: Storyboard embedded variables
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var done: UIBarButtonItem!
  
  // MARK: General attributes for class
  
  var realm = try! Realm()
  lazy var contacts: Results<Contact> = { self.realm.objects(Contact.self).sorted(byProperty: "fullName") }()
  var group: Group!
  var groupContacts = List<Contact>()
  var previousContacts = Set<Contact>()
  var contactsToView = [Contact]()
  var filteredContacts = [Contact]()
  var savedContacts = [Contact]()
  
  var groupDict: [NSString: NSDictionary] = [
    "strings": [
      "groupName": "",
      "uniqueID": "",
      "leader": ""
    ],
    "members": [
      "membersArray": [[
        "uniqueID": ""
        ]]
    ]
  ]
  
  let searchController = UISearchController(searchResultsController: nil)
  
  var delegate: GroupContactSelectionViewControllerDelegate?
  
  var fromExistingGroup = false
  var chatView: GroupChatViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.hidesBottomBarWhenPushed = true
    self.tabBarController?.tabBar.isHidden = true
    
    
    searchController.searchBar.delegate = self
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    searchController.searchBar.placeholder = "Search by name"
    searchController.searchBar.searchBarStyle = .minimal
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.barTintColor = UIColor.lightText
    searchController.searchBar.tintColor = UIColor(red: 68/255, green: 245/255, blue: 150/250, alpha: 1)
    
    filteredContacts = Array(contactsToView)
    
    tableView.tableHeaderView = searchController.searchBar
    tableView.allowsMultipleSelection = true
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    
    self.searchController.loadViewIfNeeded()
    // Do any additional setup after loading the view.
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
  
  func dupeCheck() {
    var contactsToView = Set(contacts)
    contactsToView.formSymmetricDifference(previousContacts)
    self.contactsToView = contactsToView.sorted(by: {$0.fullName.localizedCaseInsensitiveCompare($1.fullName) == ComparisonResult.orderedAscending})
  }
  
  // MARK: UITableViewDelegate Functions
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Added Contacts"
    case 1:
      return "All Contacts"
    default:
      return ""
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return savedContacts.count
    case 1:
      if searchController.isActive && searchController.searchBar.text != "" {
        return filteredContacts.count
      }
      return contactsToView.count
    default:
      return 0
    }
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
    let item: Contact
    if (indexPath as NSIndexPath).section == 0{
      item = savedContacts[(indexPath as NSIndexPath).row]
    }
    else {
      if searchController.isActive && searchController.searchBar.text != "" {
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !searchController.isActive && searchController.searchBar.text == "" {
      filteredContacts = Array(contactsToView)
    }
    if (indexPath as NSIndexPath).section == 0 {
      filteredContacts.append(savedContacts[(indexPath as NSIndexPath).row])
      savedContacts.remove(at: (indexPath as NSIndexPath).row)
      contactsToView = filteredContacts.sorted {
        $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending
      }
    }
    else {
      savedContacts.append(filteredContacts[(indexPath as NSIndexPath).row])
      filteredContacts.remove(at: (indexPath as NSIndexPath).row)
      contactsToView = filteredContacts
    }
    self.tableView.reloadData()
  }
  
  // MARK: UISearchBarDelegate Functions
  
  func updateSearchResults(for searchController: UISearchController) {
    filteredContacts = contactsToView.filter { contact in
      return contact.fullName.lowercased().contains(searchController.searchBar.text!.lowercased())
    }
    
    tableView.reloadData()
  }
  
  // MARK: Navigation Delegate Functions
  
  @IBAction func toGroupChat(_ sender: Any?) {
    if !fromExistingGroup {
      updateGroup()
      self.realm.beginWrite()
      self.realm.add(self.group)
      try! self.realm.commitWrite()
      let storyboard = UIStoryboard(name: "Group", bundle: nil)
      let viewController = storyboard.instantiateViewController(withIdentifier: "GroupChat") as! GroupChatViewController
      viewController.group = self.group
      let navController = self.navigationController
      _ = self.navigationController?.popToRootViewController(animated: false)
      navController?.pushViewController(viewController, animated: true)
      /*updateGroup()
       HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "group", data: groupDict, completionHandler: {returnDict in
       if returnDict["serverCode"] as! Int == 200 {
       dispatch_async(dispatch_get_main_queue(), {
       self.realm.beginWrite()
       self.realm.add(self.group)
       try! self.realm.commitWrite()
       let storyboard = UIStoryboard(name: "Group", bundle: nil)
       let viewController = storyboard.instantiateViewControllerWithIdentifier("GroupChat") as! GroupChatViewController
       viewController.group = self.group
       let navController = self.navigationController
       self.navigationController?.popToRootViewControllerAnimated(false)
       navController?.pushViewController(viewController, animated: true)
       })
       }
       else if returnDict["serverCode"] as! Int == 404 {
       dispatch_async(dispatch_get_main_queue(), {
       let alertController = UIAlertController(title: nil, message:
       "Error communicating with server.", preferredStyle: UIAlertControllerStyle.Alert)
       alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default,handler: nil))
       self.presentViewController(alertController, animated: true, completion: nil)
       })
       }
       })*/
    }
    else {
      var contactsDict = [["contact_id": ""]]
      for i in savedContacts {
        contactsDict.append(["contact_id": "\(i.uuid)"])
      }
      for i in previousContacts {
        contactsDict.append(["contact_id": "\(i.uuid)"])
      }
      HTTPRequestManager.sharedInstance.makeHTTPPATCHCall("group/\(group.uuid)/members", data: contactsDict, completionHandler: {returnDict in
        if returnDict["serverCode"] as! Int == 200 {
          DispatchQueue.main.async(execute: {
            self.realm.beginWrite()
            self.group.groupContacts.append(objectsIn: self.savedContacts)
            do {
              try self.realm.commitWrite()
            }
            catch let error as NSError {
              print("error: \(error.localizedDescription)")
            }
            _ = self.navigationController?.popToViewController(self.chatView, animated: true)
          })
        }
        else if returnDict["serverCode"] as! Int == 404 {
          DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: nil, message:
              "Failed to add new members. Try again.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
          })
        }
      })
    }
  }
  
  func updateGroup() {
    group.groupContacts.append(objectsIn: savedContacts)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
