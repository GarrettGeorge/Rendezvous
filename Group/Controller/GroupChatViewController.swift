//
//  GroupChatViewController.swift
//  Rendezvous
//
//  Created by Admin on 6/14/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//
import UIKit
import RealmSwift

class GroupChatViewController: MessageSuperViewController {
  
  @IBOutlet var settings: UIBarButtonItem!
  
  var realm = try! Realm()
  
  var group: Group!
  
  var menu: GroupChatMenu!
  var menuShadow: UIView!
  
  var isFirstTime: Bool!
  var maxNumberOfLines: Int!
  
  var observer: Any!
  
  override func viewDidLoad() {
    // Converts the group's List<Message> to array for use
    self.messages = Array(group.messages)
    
    super.viewDidLoad()
    
    observer = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "showFullScreenImage"), object: nil, queue: nil) { Notification in
      super.showFullImage()
    }
    
    self.navigationItem.title = group.groupName
    self.navigationItem.rightBarButtonItem = settings
    
    // MARK: Socket.IO
    
    // Handles notifications from SocketIOManager whe nantoher use begins typing.
    // Calls to handleUserTypingNotification
    NotificationCenter.default.addObserver(self, selector: #selector(super.handleUserTypingNotification(_:)), name: Notification.Name("userTypingNotification"), object: nil)
    
    // Handles new messages from server and sync the async .on listener to update self.newMessage
    SocketIOManager.sharedInstance.getNewMessage { messageData -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        let message = Message()
        message.nameForLabel = messageData["username"] as! String
        message.messageContents = messageData["message"] as! String
        message.timeOfMessage = messageData["date"] as! String
        message.senderID = messageData["sender_id"] as! String
        message.classification = messageData["classification"] as! String
        if message.classification == "image" {
          if let base64String = messageData["base64String"] as? String {
            if let data = Data(base64Encoded: base64String) {
              message.thumbnail = data
            }
          }
        }
        message.uuid = messageData["uuid"] as! String
        if message.senderID != self.myUserID {
          self.typingIndicatorView?.removeUsername(message.nameForLabel)
          self.newMessage = message
          self.didReceiveNewMessage()
        }
        
        let dateFormatter = DateFormatter()
        let date = dateFormatter.date(from: message.timeOfMessage)
        self.group.timeOfLastMessage = date
        
      })
    }
    // Conects to socket, verifies connection, and updates client with new messages if pertinent
    //SocketIOManager.sharedInstance.connectToSocket()
    
    isFirstTime = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let width: CGFloat = self.view.frame.size.width * 0.80
    menu = GroupChatMenu(frame: CGRect(x: self.view.bounds.width,y: 0,width: width,height: UIScreen.main.bounds.height))
    
    menu.groupNameLabel.text = group.groupName
    
    if group.groupIcon != nil {
      menu.groupIcon.setBackgroundImage(UIImage(data: group.groupIcon! as Data), for: UIControlState())
    }
    else {
      
    }
    
    menu.membersButton.addTarget(self, action: #selector(gotoMembers(_:)), for: .touchUpInside)
    
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
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    NotificationCenter.default.removeObserver(observer, name: Notification.Name(rawValue: "showFullScreenImage"), object: nil)
    
    if self.isMovingFromParentViewController {
      // Disconnects from server and socket
      //SocketIOManager.sharedInstance.disconnectFromServer(myUserID)
      //SocketIOManager.sharedInstance.disconnectFromSocket()
    }
    
    self.hidesBottomBarWhenPushed = true
    self.tabBarController?.tabBar.isHidden = true
  }
  
  @IBAction func openMenu(_ sender: Any?) {
    self.view.endEditing(true)
    menu.isHidden = false
    UIView.animate(withDuration: 0.25, animations: {
      self.menu.center.x -= self.menu.frame.size.width
      self.menuShadow.alpha = 1
    })
  }
  
  
  func closeMenu(_ sender: Any?) {
    UIView.animate(withDuration: 0.25, animations: {
      self.menu.center.x += self.menu.frame.size.width
      self.menuShadow.alpha = 0
    })
  }
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "chatToMembers" {
      let viewController = segue.destination as! GroupMembersViewController
      viewController.group = group
      viewController.chatView = self
    }
  }
  
  func gotoMembers(_ sender: Any?) {
    closeMenu(self)
    self.performSegue(withIdentifier: "chatToMembers", sender: self)
  }
  
  // MARK: Overriden Super Methods
  override func textViewDidChange(_ textView: UITextView) {
    super.textViewDidChange(textView)
    if textView == self.textView {
      //SocketIOManager.sharedInstance.didBeginTyping(myUserID)
    }
  }
  
  override func didPressRightButton(_ sender: Any?) {
    /*print(textView.text)
     print(textView.text.contains("\n"))
     print(textView.attributedText)
     */
    // Call to super function to reload table view rows and update
    super.didPressRightButton(sender)
    
    // MARK: Socket.io method calls
    var base64String = ""
    if newMessage.thumbnail != nil {
      if let encodedString = newMessage.thumbnail?.base64EncodedString(options: .lineLength64Characters) {
        base64String = encodedString
      }
    }
    let messageDict: [String: String] = [
      "name_for_label": newMessage.nameForLabel,
      "message_contents": newMessage.messageContents,
      "sender_id": myUserID,
      "classification": newMessage.classification,
      "thumbnail_as_base_64": base64String
    ]
    /*
     SocketIOManager.sharedInstance.sendMessage(messageDict)
     */
    // Add new message to the meeetup's List<Message> in Realm
    try! realm.write {
      self.group.messages.insert(self.newMessage, at: 0)
    }
    
    newMessage = Message()
  }
  
  override func didReceiveNewMessage() {
    self.messages.insert(self.newMessage, at: 0)
    
    super.didReceiveNewMessage()
    
    do {
      try realm.write {
        self.group.messages.insert(self.newMessage, at: 0)
        //self.group.timeOfLastMessage = self.newMessage.timeOfMessage
      }
    }
    catch let error as NSError {
      print("error: \(error.localizedDescription)")
    }
  }
  
}
