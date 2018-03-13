//
//  Contact.swift
//  Rendezvous
//
//  Created by Admin on 4/21/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import Foundation
import RealmSwift

class Contact: Object {
  
  dynamic var email: String = ""
  dynamic var fullName: String = ""
  dynamic var phoneNumber: String = ""
  dynamic var uuid = UUID().uuidString
  dynamic var photo: Data?
  
  override static func primaryKey() -> String? {
    return "uuid"
  }
}
