//
//  SavedLocation.swift
//  Rendezvous
//
//  Created by Admin on 7/6/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class SavedLocation: Object {
  
  dynamic var latitude: Double = 0.0
  dynamic var longitude: Double = 0.0
  dynamic var locationName: String = "Location"
  dynamic var locationAddress: String = ""
  dynamic var locationImage: Data?
  
}

func ==(lhs: SavedLocation, rhs: SavedLocation) -> Bool
{
  return
    lhs.locationName == rhs.locationName &&
      lhs.locationAddress == rhs.locationAddress &&
      lhs.latitude == rhs.latitude &&
      lhs.longitude == rhs.longitude
}
