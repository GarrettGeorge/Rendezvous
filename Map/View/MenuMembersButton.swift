//
//  MenuMembersView.swift
//  Rendezvous
//
//  Created by Admin on 7/22/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class MenuMembersButton: UIButton {
  
  var membersIcon: UIImageView!
  var membersLabel: UILabel!
  var bottomBorder: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clear
    
    membersIcon = UIImageView(frame: CGRect(x: 20, y: 5, width: 25, height: 25))
    membersIcon.image = UIImage(named: "Members")
    self.addSubview(membersIcon)
    
    membersLabel = UILabel(frame: CGRect(x: 60,y: 6,width: bounds.width - 55,height: 30))
    membersLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 18)
    membersLabel.text = "Members"
    self.addSubview(membersLabel)
    
    bottomBorder = UIView(frame: CGRect(x: 15,y: bounds.height - 2,width: bounds.width - 10,height: 2))
    bottomBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    self.addSubview(bottomBorder)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
