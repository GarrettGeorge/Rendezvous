//
//  Meetup.swift
//  Rendezvous
//
//  Created by Admin on 4/17/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class Meetup: Object {
  
  dynamic var leader: Contact!
  dynamic var name: String = ""
  dynamic var details: String = ""
  let allContacts = List<Contact>()
  let contacts = List<Contact>()
  let groups = List<Group>()
  let messages = List<Message>()
  dynamic var meetupIcon: Data?
  dynamic var locationName: String?
  dynamic var locationAddress: String = ""
  dynamic var locationLatitude: Double = 0.0
  dynamic var locationLongitude: Double = 0.0
  dynamic var timeOfLastMessage: Date?
  dynamic var timeOfMeetup: Date?
  dynamic var shouldBeNotified: Bool = true
  let uuid: String = ""
  //let savedMeetupLocations =  //array instead of set due to CLLoc not being hashable
}

func ==(lhs: Meetup, rhs: Meetup) -> Bool
{
  return lhs.uuid == rhs.uuid
}
