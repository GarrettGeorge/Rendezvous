//
//  GroupDetailViewController.swift
//  Rendezvous
//
//  Created by Admin on 6/2/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

protocol GroupDetailViewControllerDelegate {
  func updateGroups(_ data: Group)
}
class GroupDetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
  
  @IBOutlet var groupIcon: UIButton!
  @IBOutlet var groupName: UITextField!
  @IBOutlet var addContacts: UIButton!
  @IBOutlet var done: UIBarButtonItem!
  
  
  var realm = try! Realm()
  var group: Group?
  
  var groupDict: [String: Dictionary<String, Any>] = [
    "strings": [
      "groupName": "" as Any,
      "uniqueID": "" as Any,
      "leader": "" as Any
    ],
    "members": [
      "membersArray": [[
        "uniqueID": ""
        ]]
    ]
  ]
  
  var foregroundImage: UIImageView!
  let imgPicker = UIImagePickerController()
  
  var delegate: GroupDetailViewControllerDelegate?
  
  let MAIN_COLOR = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.hidesBottomBarWhenPushed = true
    self.tabBarController?.tabBar.isHidden = true
    
    self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    self.edgesForExtendedLayout = UIRectEdge()
    
    imgPicker.delegate = self
    
    groupIcon.titleLabel?.textAlignment = .center
    groupIcon.tintColor = UIColor.darkGray
    groupIcon.clipsToBounds = true
    groupIcon.backgroundColor = UIColor(red: 238/255, green: 252/255, blue: 247/255, alpha: 1)
    foregroundImage = UIImageView(frame: CGRect(x: 21.9669914, y: 21.9669914, width: 75*1.41421356237, height: 75*1.41421356237))
    foregroundImage.image = UIImage(named: "MeetupDefault")
    groupIcon.addSubview(foregroundImage)
    groupIcon.layer.cornerRadius = 75
    groupIcon.layer.borderWidth = 5
    groupIcon.layer.borderColor = UIColor.white.cgColor
    groupIcon.addTarget(self, action: #selector(callImagePicker(_:)), for: .touchUpInside)
    
    groupName.layer.cornerRadius = 5
    groupName.layer.borderWidth = 1
    groupName.layer.borderColor = UIColor.lightGray.cgColor
    groupName.alpha = 0.75
    groupName.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: groupName.frame.size.height))
    groupName.leftViewMode = .always
    groupName.delegate = self
    groupName.addTarget(self, action: #selector(GroupDetailViewController.didTextChange(_:)), for: .editingChanged)
    
    addContacts.backgroundColor = MAIN_COLOR
    addContacts.alpha = 0.5
    addContacts.isEnabled = false
    addContacts.layer.cornerRadius = 15
    // Do any additional setup after loading the view.
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    checkValidGroup()
  }
  
  func updateGroup() {
    group = Group()
    group?.groupName = groupName.text!
    if groupIcon.currentBackgroundImage == nil {
      group?.groupIcon = UIImagePNGRepresentation(UIImage(named: "defaultGroupIcon")!)
    }
    else {
      group?.groupIcon = UIImagePNGRepresentation(groupIcon.currentBackgroundImage!)
    }
    group?.groupLeader = KeychainWrapper.standard.string(forKey: "username")
  }
  
  func updateGroupDictionary() {
    updateGroup()
    groupDict["strings"]!["groupName"] = group?.groupName as Any?
    groupDict["strings"]!["uniqueID"] = group?.uuid as Any?
  }
  
  func checkValidGroup() {
    if groupName.text != "" {
      done.isEnabled = true
      addContacts.alpha = 1
      addContacts.isEnabled = true
    }
    else {
      done.isEnabled = false
      addContacts.alpha = 0.5
      addContacts.isEnabled = false
    }
  }
  
  func didTextChange(_ textField: UITextField) {
    checkValidGroup()
  }
  
  // MARK: Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toAddFriends"{
      updateGroup()
      let viewController = segue.destination as! GroupContactSelectionViewController
      viewController.group = group
    }
  }
  
  @IBAction func toGroupChat(_ sender: Any?) {
    HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "groups", data: groupDict as NSDictionary, completionHandler: {returnDict in
      if returnDict["serverCode"] as! Int == 200 {
        self.updateGroup()
        self.realm.beginWrite()
        self.realm.add(self.group!)
        try! self.realm.commitWrite()
        let storyboard = UIStoryboard(name: "Group", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GroupChat") as! GroupChatViewController
        viewController.group = self.group
        let navController = self.navigationController
        _ = self.navigationController?.popToRootViewController(animated: false)
        navController?.pushViewController(viewController, animated: true)
      }
      else if returnDict["serverCode"] as! Int == 400 || returnDict["serverCode"] as! Int == 404 {
        let alertController = UIAlertController(title: nil, message:
          "Error communicating with server.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
      }
    })
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension GroupDetailViewController: UIImagePickerControllerDelegate {
  func callImagePicker(_ sender: Any?) {
    imgPicker.allowsEditing = true
    imgPicker.sourceType = .photoLibrary
    
    present(imgPicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if var pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
      foregroundImage.removeFromSuperview()
      let shortSide = pickedImage.size.height > pickedImage.size.width ? pickedImage.size.width : pickedImage.size.height
      pickedImage = MapViewController.croppIngimage(pickedImage, toRect: CGRect(x: 0, y: 0, width: shortSide, height: shortSide))
      groupIcon.setBackgroundImage(pickedImage, for: UIControlState())
    }
    dismiss(animated: true, completion: nil)
  }
}
