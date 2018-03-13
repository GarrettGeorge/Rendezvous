//
//  MeetupChatViewController.swift
//  Rendezvous
//
//  Created by Admin on 6/14/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import SlackTextViewController
import RealmSwift

class MeetupChatViewController: MessageSuperViewController {
  
  @IBOutlet var settings: UIBarButtonItem!
  
  var meetup: Meetup!
  
  var realm = try! Realm()
  
  var menu: MeetupChatMenu!
  var menuShadow: UIView!
  
  var observer: Any!
  
  override func viewDidLoad() {
    //Converts the meetup's List<Message> to array for use
    self.messages = Array(meetup.messages)
    
    observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "showFullScreenImage"), object: nil, queue: nil) { Notification in
      super.showFullImage()
    }
    
    super.viewDidLoad()
    self.hidesBottomBarWhenPushed = true
    self.tabBarController?.tabBar.isHidden = false
    
    self.navigationItem.title = meetup.name
    self.navigationItem.rightBarButtonItem = settings
    
    self.textView.delegate = self
    // MARK: Socket.IO
    
    //Handles notifications from SocketIOManager when another user begins typing.
    //Calls to handleUserTypingNotification
    NotificationCenter.default.addObserver(self, selector: #selector(super.handleUserTypingNotification(_:)), name: Notification.Name("userTypingNotification"), object: nil)
    //Handles new messages from server and syncs the async .on listener to update self.newMessage
    SocketIOManager.sharedInstance.getNewMessage { messageData -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        let message = Message()
        message.nameForLabel = messageData["username"] as! String
        message.messageContents = messageData["message"] as! String
        message.timeOfMessage = messageData["date"] as! String
        message.senderID = messageData["sender_id"] as! String
        if message.senderID != self.myUserID {
          self.typingIndicatorView?.removeUsername(message.nameForLabel)
          self.newMessage = message
          self.didReceiveNewMessage()
        }
        else if message.senderID == self.myUserID {
          
        }
        let dateFormatter = DateFormatter()
        let date = dateFormatter.date(from: message.timeOfMessage)
        self.meetup.timeOfLastMessage = date
        
      })
    }
    // Connects to socket, verifies connection, and updates client with new messages if pertinent
    
    // SocketIOManager.sharedInstance.connectToSocket()
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    menuShadow.removeFromSuperview()
    menu.removeFromSuperview()
    
    NotificationCenter.default.removeObserver(observer, name: Notification.Name(rawValue: "showFullScreenImage"), object: nil)
    
    //Disconnect from socket
    // SocketIOManager.sharedInstance.disconnectFromServer(myUsername)
    // SocketIOManager.sharedInstance.disconnectFromSocket()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let width: CGFloat = self.view.frame.size.width * 0.80
    menu = MeetupChatMenu(frame: CGRect(x: self.view.bounds.width,y: 0,width: width,height: UIScreen.main.bounds.height))
    // Meetup name
    menu.meetupNameLabel.text = meetup.name
    // Meetup Icon
    if meetup.meetupIcon != nil {
      menu.meetupIcon.setBackgroundImage(UIImage(data: meetup.meetupIcon! as Data), for: UIControlState())
    }
    else {
      menu.meetupIcon.setBackgroundImage(UIImage(named: "MeetupDefault"), for: UIControlState())
    }
    var shift: CGFloat = 0.0
    // Name of Meetup location
    if meetup.locationName != "" {
      menu.locationNameLabel.text = meetup.locationName
      shift += 10
    }
    else {
      menu.dateLabel.center.y -= 23
      menu.dateBorder.center.y -= 23
      menu.locationNameLabel.removeFromSuperview()
      menu.locationBorder.removeFromSuperview()
      shift -= 10
    }
    
    // Date of Meetup toString
    if meetup.timeOfMeetup != nil {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      dateFormatter.timeStyle = .short
      let DateInFormat = dateFormatter.string(from: meetup.timeOfMeetup! as Date)
      menu.dateLabel.text = DateInFormat
      shift += 10
    }
    else {
      menu.dateLabel.removeFromSuperview()
      menu.dateBorder.removeFromSuperview()
    }
    // Details of Meetup (variable size)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    paragraphStyle.alignment = .left
    
    let pointSize: CGFloat = 16.0
    
    let attributes = [
      NSFontAttributeName : UIFont.systemFont(ofSize: pointSize),
      NSParagraphStyleAttributeName : paragraphStyle
    ]
    let detailsBounds = (meetup.details as NSString).boundingRect(with: CGSize(width: width - 35, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
    menu.detailsLabel.frame = CGRect(x: 10, y: menu.locationNameLabel.bounds.height + menu.dateLabel.bounds.height + shift, width: width - 35, height: detailsBounds.height + 5)
    if meetup.details == "Add some details about your meetup that friends might need like where to park, what to bring, and any other special considerations." {
      menu.detailsLabel.textColor = UIColor.lightGray
    }
    menu.detailsLabel.text = meetup.details
    menu.infoLabel.frame = CGRect(x: 10, y: menu.meetupIcon.frame.maxY + 10, width: width - 20, height: menu.detailsLabel.frame.minY + detailsBounds.height + 5)
    menu.infoLabel.addSubview(menu.locationNameLabel)
    menu.infoLabel.addSubview(menu.dateLabel)
    menu.infoLabel.addSubview(menu.detailsLabel)
    menu.detailsEditButton.frame = CGRect(x: menu.infoLabel.bounds.width - 27, y: menu.infoLabel.frame.minY + 2, width: 35, height: 35)
    menu.detailsEditButton.addTarget(self, action: #selector(editMeetupDetails(_:)), for: .touchUpInside)
    menu.scrollView.addSubview(menu.detailsEditButton)
    menu.infoBorder.frame = CGRect(x: 0,y: menu.infoLabel.frame.maxY + 15,width: menu.bounds.width - 10, height: 2)
    
    menu.membersButton.frame = CGRect(x: 0,y: menu.infoBorder.frame.maxY,width: width,height: 60)
    menu.membersButton.addTarget(self, action: #selector(goToMembersView(_:)), for: .touchUpInside)
    menu.membersBorder.frame = CGRect(x: 15,y: menu.membersButton.bounds.height - 2,width: menu.membersButton.bounds.width - 10,height: 2)
    menu.membersButton.addSubview(menu.membersBorder)
    menu.scrollView.addSubview(menu.membersButton)
    
    menu.showMapButton.frame = CGRect(x: 0,y: menu.membersButton.frame.maxY,width: width,height: 60)
    menu.showMapButton.addTarget(self, action: #selector(showMeetupInMap(_:)), for: .touchUpInside)
    menu.showMapBorder.frame = CGRect(x: 15,y: menu.showMapButton.bounds.height - 2,width: menu.showMapButton.bounds.width - 10,height: 2)
    menu.showMapButton.addSubview(menu.showMapBorder)
    menu.scrollView.addSubview(menu.showMapButton)
    
    menu.settingsButton.frame = CGRect(x: 0, y: menu.showMapButton.frame.maxY, width: width, height: 60)
    menu.settingsBorder.frame = CGRect(x: 15,y: menu.settingsButton.bounds.height - 2,width: menu.settingsButton.bounds.width - 10,height: 2)
    menu.settingsButton.addSubview(menu.settingsBorder)
    menu.scrollView.addSubview(menu.settingsButton)
    
    menu.scrollView.contentSize = CGSize(width: menu.bounds.width - 10, height: menu.settingsButton.frame.maxY + 20)
    UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
    UIApplication.shared.keyWindow?.addSubview(self.menu)
    menu.isHidden = true
    
    menuShadow = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height))
    menuShadow.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
    menuShadow.alpha = 0
    menuShadow.isUserInteractionEnabled = true
    menuShadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeMenu(_:))))
    UIApplication.shared.keyWindow?.insertSubview(menuShadow, belowSubview: menu)
  }
  
  // MARK: MessageSuper Method Overrides
  override func textViewDidChange(_ textView: UITextView) {
    if textView == self.textView {
      SocketIOManager.sharedInstance.didBeginTyping(myUserID)
    }
  }
  
  override func didPressRightButton(_ sender: Any?) {
    // Call to super function to reload table view rows and update
    super.didPressRightButton(sender)
    
    // MARK: Socket.io method calls
    //SocketIOManager.sharedInstance.sendMessage(self.newMessage.messageContents, senderID: self.newMessage.senderID)
    
    // Add new message to the meeetup's List<Message> in Realm
    try! realm.write {
      self.meetup.messages.insert(self.newMessage, at: 0)
    }
    
    newMessage = Message()
  }
  
  override func didReceiveNewMessage() {
    self.messages.insert(self.newMessage, at: 0)
    
    super.didReceiveNewMessage()
    
    try! realm.write {
      self.meetup.messages.insert(self.newMessage, at: 0)
    }
  }
  
  // MARK: Meetup Menu Functions
  @IBAction func openMenu(_ sender: AnyObject) {
    self.view.endEditing(true)
    menu.isHidden = false
    UIView.animate(withDuration: 0.25, animations: {
      self.menu.center.x -= self.menu.frame.size.width
      self.menuShadow.alpha = 1
    })
  }
  
  func closeMenu(_ sender: AnyObject) {
    UIView.animate(withDuration: 0.25, animations: {
      self.menu.center.x += self.menu.frame.size.width
      self.menuShadow.alpha = 0
    })
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ChatToMembers" {
      let viewController = segue.destination as! MeetupMembersViewController
      viewController.meetup = meetup
      viewController.chatView = self
    }
  }
  
  func editMeetupDetails(_ sender: AnyObject) {
    print("edit")
  }
  
  func goToMembersView(_ sender: AnyObject) {
    closeMenu(self)
    self.performSegue(withIdentifier: "ChatToMembers", sender: self)
  }
  
  func showMeetupInMap(_ sender: AnyObject) {
    print("map")
  }
}
