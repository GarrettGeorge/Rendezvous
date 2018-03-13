//
//  Message.swift
//  Rendezvous
//
//  Created by Admin on 6/8/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class Message: Object {
  
  dynamic var nameForLabel: String = ""
  dynamic var messageContents: String = ""
  dynamic var timeOfMessage: String = ""
  dynamic var senderID: String = ""
  dynamic var classification: String = "text"
  dynamic var thumbnail: Data?
  dynamic var uuid: String = ""
}
