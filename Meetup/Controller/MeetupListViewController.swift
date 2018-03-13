//
//  MeetupListViewController.swift
//  Rendezvous
//
//  Created by Admin on 4/14/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift
import MGSwipeTableCell

class MeetupListViewController: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDataSource {
  
  
  
  @IBOutlet var myTableView: UITableView!
  @IBOutlet weak var toolbarView: UIToolbar!
  
  
  var realm = try! Realm()
  lazy var results: Results<Meetup> = { self.realm.objects(Meetup.self).sorted(byProperty: "timeOfLastMessage") }()
  
  var meetup: Meetup!
  
  lazy var myUserID = KeychainWrapper.standard.string(forKey: "unique_id") ?? "Garrett George"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Meetup List"
    self.myTableView.delegate = self
    self.myTableView.dataSource = self
    self.myTableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    myTableView.reloadData()
  }
  
  func leaveMeetup(_ meetup: Meetup, indexPath: IndexPath) {
    let alertController = UIAlertController(title: "Leave Meetup?", message: "Are you sure you want to leave \(meetup.name)?", preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
    alertController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: {(UIAlertAction) -> Void in
      let uuid = KeychainWrapper.standard.string(forKey: "uniqueID") ?? ""
      let leaveDict = ["op": "remove", "path": "/\(meetup.uuid)", "value": "\(uuid)"]
      /*let returnDict = HTTPRequestManager.sharedInstance.makeHTTPCall(url: "meetups", method: "PATCH", data: leaveDict)
       if returnDict == nil {
       print("Error")
       }
       else if returnDict!["serverCode"] as! Int == 200 {
       self.realm.beginWrite()
       self.realm.delete(meetup)
       try! self.realm.commitWrite()
       self.myTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
       }
       else if returnDict!["serverCode"] as! Int == 400 || returnDict!["serverCode"] as! Int == 404 {
       let alertController = UIAlertController(title: nil, message: "Error communicating with server.", preferredStyle: UIAlertControllerStyle.Alert)
       alertController.addAction(UIKit.UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
       self.presentViewController(alertController, animated: true, completion: nil)
       }*/
    }))
    self.present(alertController, animated: true, completion: nil)
    self.realm.beginWrite()
    self.realm.delete(meetup)
    try! self.realm.commitWrite()
    self.myTableView.deleteRows(at: [indexPath], with: .fade)
  }
  
  func muteMeetup(_ meetup: inout Meetup) {
    realm.beginWrite()
    meetup.shouldBeNotified = !meetup.shouldBeNotified
    try! realm.commitWrite()
    /*
     let uuid = KeychainWrapper.standard.stringForKey("uniqueID")
     let muteDict = ["op": "replace", "path": "/\(uuid)/shouldNotify", "value": "false"]
     let returnDict = HTTPRequestManager.sharedInstance.makeHTTPCall(url: "\(meetup.uuid)", method: "PATCH", data: muteDict)
     if returnDict == nil {
     print("Error")
     }
     else if returnDict!["serverCode"] as! Int == 200 {
     realm.beginWrite()
     meetup.shouldBeNotified = !meetup.shouldBeNotified
     try! realm.commitWrite()
     }
     else if returnDict!["serverCode"] as! Int == 400 || returnDict!["serverCode"] as! Int == 404 {
     let alertController = UIAlertController(title: nil, message: "Error communicating with server.", preferredStyle: UIAlertControllerStyle.Alert)
     alertController.addAction(UIKit.UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
     self.presentViewController(alertController, animated: true, completion: nil)
     }
     */
  }
  
  
  @IBAction func testing(_ sender: AnyObject) {
    
  }
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "meetupListToChat" {
      let viewController = segue.destination as! MeetupChatViewController
      viewController.meetup = meetup
    }
  }
}

extension MeetupListViewController: UITableViewDelegate {
  func tableView(_ myTableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
  {
    return 80
  }
  
  func tableView(_ myTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.results.count
  }
  
  func tableView(_ myTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.myTableView.dequeueReusableCell(withIdentifier: "cell") as! MeetupCellTableViewCell
    var item = results[(indexPath as NSIndexPath).row]
    cell.nameLabel?.text = item.name
    if item.meetupIcon != nil {
      cell.meetupIcon.image = UIImage(data: item.meetupIcon!)
    }
    
    if item.messages.count > 0 {
      if item.messages[0].classification == "text" {
        cell.lastMessageLabel.text = item.messages[0].nameForLabel + ": " + item.messages[0].messageContents
      }
      else if item.messages[0].classification == "image" {
        cell.lastMessageLabel.text = (item.messages[0].senderID == myUserID ? "You have " : item.messages[0].nameForLabel + " has " ) + "sent a photo."
      }
    }
    
    
    cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    var muteText = "Mute"
    if !item.shouldBeNotified {
      muteText = "Un-mute"
    }
    cell.rightButtons = [MGSwipeButton(title: "Leave",icon: UIImage(named: "LeaveMeetup"),backgroundColor: UIColor.red, callback: {
      MGSwipeButtonCallback in
      // Leave meetup
      self.leaveMeetup(item, indexPath: indexPath)
      return true
    }),MGSwipeButton(title: muteText, icon: UIImage(named: "Mute"), backgroundColor: UIColor.lightGray, callback: {
      MGSwipeButtonCallback in
      // Mute meetup notifications
      self.muteMeetup(&item)
      return true
    })]
    cell.rightSwipeSettings.transition = MGSwipeTransition.drag
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    meetup = results[(indexPath as NSIndexPath).row]
    self.performSegue(withIdentifier: "meetupListToChat", sender: self)
  }
}
