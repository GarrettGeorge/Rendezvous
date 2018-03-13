//
//  MembersAlertView.swift
//  Rendezvous
//
//  Created by Admin on 7/27/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class MembersAlertView: UIView {
  
  var nameLabel: UILabel!
  var photo: UIImageView!
  var requestButton: UIButton!
  var deleteButton: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.white
    layer.cornerRadius = 5
    
    nameLabel = UILabel(frame: CGRect(x: 10,y: 10,width: bounds.width - 20, height: 25))
    nameLabel.textAlignment = .center
    nameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    addSubview(nameLabel)
    
    let photoWidth = bounds.width - 70
    photo = UIImageView(frame: CGRect(x: 35, y: 45, width: photoWidth, height: photoWidth))
    photo.clipsToBounds = true
    photo.layer.cornerRadius = photoWidth / 2
    addSubview(photo)
    
    requestButton = UIButton(frame: CGRect(x: 20,y: photo.frame.maxY + 10, width: bounds.width - 40,height: 45))
    requestButton.layer.cornerRadius = 5
    requestButton.clipsToBounds = true
    requestButton.setTitleColor(UIColor.white, for: UIControlState())
    requestButton.backgroundColor = UIColor(red: 51/255, green: 151/255, blue: 219/255, alpha: 1)
    addSubview(requestButton)
    
    deleteButton = UIButton(frame: CGRect(x: 20,y: requestButton.frame.maxY + 10, width: bounds.width - 40, height: 45))
    deleteButton.layer.cornerRadius = 5
    deleteButton.clipsToBounds = true
    deleteButton.setTitleColor(UIColor.white, for: UIControlState())
    deleteButton.backgroundColor = UIColor.red
    addSubview(deleteButton)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
