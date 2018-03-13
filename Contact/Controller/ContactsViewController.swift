//
//  ContactsViewController.swift
//  Rendezvous
//
//  Created by Admin on 4/15/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift
import Contacts

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate{
  
  @IBOutlet var tableView: UITableView!
  
  var contact: Contact!
  var contactStore = CNContactStore()
  
  lazy var realm = try! Realm()
  lazy var contacts: Results<Contact> = { self.realm.objects(Contact.self).sorted(byProperty: "fullName") }()
  var arrayContacts = [Contact]()
  var filteredContacts = [CNContact]()
  var filteredContactNumbers = [NSString]()
  
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    arrayContacts = Array(contacts)
    
    self.hidesBottomBarWhenPushed = true
    self.tabBarController?.tabBar.isHidden = true
    self.extendedLayoutIncludesOpaqueBars = true
    
    self.tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    searchController.searchBar.delegate = self
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    searchController.searchBar.placeholder = "Search by name or phone number"
    searchController.searchBar.searchBarStyle = .minimal
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.barTintColor = UIColor.lightText
    searchController.searchBar.tintColor = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
    
    self.tableView.tableHeaderView = searchController.searchBar
    self.tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.searchController.loadViewIfNeeded()
    //self.tableView.scrollsto
  }
  
  deinit {
    self.searchController.loadViewIfNeeded()
    let _ = self.searchController.view
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    if contacts.count == 0 {
      importContactsPrompt()
    }
  }
  
  // MARK: UITableView Delegate Functions
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive && searchController.searchBar.text != "" {
      return arrayContacts.count
    }
    return contacts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell
    var item = contacts[(indexPath as NSIndexPath).row]
    if searchController.isActive && searchController.searchBar.text != "" {
      item = arrayContacts[(indexPath as NSIndexPath).row]
    }
    else {
      item = contacts[(indexPath as NSIndexPath).row]
    }
    if item.photo != nil {
      cell.photo.image = UIImage(data: item.photo!)
    }
    cell.label?.text = item.fullName
    cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    contact = contacts[(indexPath as NSIndexPath).row]
    self.performSegue(withIdentifier: "ContactsListToDetail", sender: self)
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .Delete {
    //            // Delete the row from the data source
    //            realm.beginWrite()
    //            realm.delete(contacts[indexPath.row])
    //            try! realm.commitWrite()
    //            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    //        }
  }
  
  // prepare segue for checking if segue is to edit or add
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ContactsListToDetail" {
      let viewController = segue.destination as! ContactDetailViewController
      viewController.contact = self.contact
    }
  }
  
  // MARK: UISearchBar Delegate Functions
  func updateSearchResults(for searchController: UISearchController) {
    arrayContacts = contacts.filter { contact in
      return contact.fullName.lowercased().contains(searchController.searchBar.text!.lowercased())
    }
    
    tableView.reloadData()
  }
  
  // MARK: Contact Importing
  
  func importContactsPrompt() {
    let alert = UIAlertController(title: "Import Contacts?", message: "Find out which of your friends are already using Rendezvous and automatically add them.", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Maybe Later", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "Import", style: .default, handler: { Void in
      self.importContacts()
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  func importContacts() {
    if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
      contactStore.requestAccess(for: .contacts) { (authorized: Bool, error: Error?) -> Void in
        if authorized {
          self.getContactsFromStore(self.contactStore)
        }
      }
    }
    else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
      self.getContactsFromStore(self.contactStore)
    }
    else if CNContactStore.authorizationStatus(for: .contacts) == .denied {
      let alert = UIAlertController(title: "Permissions", message: "Access to contacts not currently allowed. Please go to your privacy settings to allow importing contacts.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ -> Void in
        let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
        if settingsURL != nil {
          UIApplication.shared.open(settingsURL!, options: [:], completionHandler: nil)
        }
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func getContactsFromStore(_ store: CNContactStore) {
    do {
      let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
      try contactStore.enumerateContacts(with: fetchRequest) { contact, stop in
        if contact.phoneNumbers.count > 0 {
          for i in contact.phoneNumbers {
            if i.label == CNLabelPhoneNumberMobile {
              let string = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! NSString
              print(string)
              self.filteredContacts.append(contact)
              self.filteredContactNumbers.append(string)
            }
          }
        }
      }
    }
    catch let error as NSError? {
      print("Error: \(error)")
    }
    convertCNContactToContactAndStore()
    self.tableView.reloadData()
  }
  
  func convertCNContactToContactAndStore() {
    for i in 0 ... (filteredContacts.count - 1) {
      let j = filteredContacts[i]
      let temp = Contact()
      if j.emailAddresses.count > 0 {
        temp.email = j.emailAddresses[0].value as String
      }
      temp.fullName = j.givenName + " " + j.familyName
      temp.phoneNumber = filteredContactNumbers[i] as String
      
      arrayContacts.append(temp)
    }
    
    realm.beginWrite()
    realm.add(arrayContacts)
    try! realm.commitWrite()
  }
  
  func crossRefWithServer() {
    if filteredContactNumbers.count > 0 {
      
      //let returnDict = HTTPRequestManager.sharedInstance.makeHTTPCall(url: "username/garrettgeorge/contact", method: "POST", data: filteredContactNumbers)
    }
    DispatchQueue.main.async(execute: {
      self.tableView.reloadData()
    })
  }
  
}
