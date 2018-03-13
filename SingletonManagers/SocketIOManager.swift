//
//  SocketIOManager.swift
//  Rendezvous
//
//  Created by Admin on 6/8/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
  
  let username = "Garrett George"
  
  // Singleton
  static let sharedInstance = SocketIOManager()
  //http://192.168.1.74:5000
  // http://45.55.175.57:3000
  var socket: SocketIOClient = SocketIOClient(socketURL: URL(fileURLWithPath: "http://45.55.175.57:3000"))
  
  override init() {
    super.init()
  }
  
  // Called on Meetup and Group chat viewDidLoad()
  func connectToSocket() {
    // joinNamespace placeholder for when joining specific chat room
    socket.joinNamespace("/chat")
    addHandlers()
    // Establishes handshake with server forcing WebSockets
    socket.connect()
  }
  
  func disconnectFromSocket() {
    socket.leaveNamespace()
    socket.disconnect()
  }
  
  // Establishes handlers for listening (socket.on)
  func addHandlers() {
    // Waits for confirmation of handshake in the form of receiving non-nil missedMessages [[String: AnyObject]]
    self.socket.on("missedMessages") { data, ack in
      self.socket.emit("connectUser", self.username)
    }
    socket.on("userTyping") { dataArray, ack in
      NotificationCenter.default.post(name: Notification.Name("userTypingNotification"), object: dataArray[0] as? String)
    }
    socket.on("newUser") { usersArray -> Void in
      //NSNotificationCenter.defaultCenter().postNotificationName("newUserAddedNotification", object: usersArray[0])
    }
  }
  
  func disconnectFromServer(_ username: String, completionHandler: () -> Void) {
    socket.emit("disconnectUser", username)
    completionHandler()
  }
  
  func disconnectFromServer(_ username: String) {
    socket.emit("disconnectUser", username)
  }
  
  func sendMessage(_ messageAsDict: [String: String]) {
    socket.emit("postNewMessage", messageAsDict)
  }
  
  // Gets new message in the form of a dictionary with call to completion handler for syncing to main queue
  func getNewMessage(_ completionHandler: @escaping (_ messageData: [String: Any]) -> Void) {
    socket.on("message") { (messageArray, ack) -> Void in
      var messageDict = ["username": "", "message": "", "date": ""]
      messageDict["username"] = messageArray[0] as? String
      messageDict["message"] = messageArray[1] as? String
      messageDict["date"] = messageArray[0] as? String
      
      
      completionHandler(messageDict)
    }
  }
  
  func didBeginTyping(_ username: String) {
    socket.emit("didBeginTyping", username)
  }
  
  func addUsers(_ usersArray: [String]) {
    socket.emit("postNewUsers", usersArray)
  }
}
