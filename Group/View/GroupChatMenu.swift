//
//  GroupChatMenu.swift
//  Rendezvous
//
//  Created by Admin on 8/15/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class GroupChatMenu: UIView, UIScrollViewDelegate {
  
  var groupNameLabel: UILabel!
  var groupIcon: UIButton!
  
  var iconBorder: UIView!
  
  var membersButton: UIButton!
  var settingsButton: UIButton!
  
  var scrollView: UIScrollView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    
    scrollView = UIScrollView(frame: self.bounds)
    scrollView.delegate = self
    scrollView.contentSize = CGSize(width: self.bounds.width - 10, height: self.bounds.height)
    self.addSubview(scrollView)
    
    groupNameLabel = UILabel(frame: CGRect(x: 5,y: 30,width: self.bounds.width - 10,height: 20))
    groupNameLabel.textAlignment = .center
    groupNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
    scrollView.addSubview(groupNameLabel)
    
    let buttonHeight = self.bounds.width - 60
    groupIcon = UIButton(frame: CGRect(x: 30,y: 60,width: buttonHeight,height: buttonHeight))
    groupIcon.clipsToBounds = true
    groupIcon.layer.cornerRadius = buttonHeight / 2
    groupIcon.layer.borderWidth = 5
    groupIcon.layer.borderColor = UIColor.white.cgColor
    scrollView.addSubview(groupIcon)
    
    iconBorder = UIView(frame: CGRect(x: 0, y: groupIcon.frame.maxY + 15,width: bounds.width,height: 2))
    iconBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    scrollView.addSubview(iconBorder)
    
    membersButton = UIButton(frame: CGRect(x: 0,y: iconBorder.frame.maxY,width: bounds.width,height: 67))
    membersButton.backgroundColor = UIColor.clear
    scrollView.addSubview(membersButton)
    let membersIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 25, height: 25))
    membersIcon.image = UIImage(named: "Members")
    membersButton.addSubview(membersIcon)
    let membersLabel = UILabel(frame: CGRect(x: 60,y: 21,width: bounds.width - 55,height: 30))
    membersLabel.center.y = membersIcon.center.y
    membersLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 18)
    membersLabel.text = "Members"
    membersButton.addSubview(membersLabel)
    let membersBorder = UIView(frame: CGRect(x: 15,y: membersButton.bounds.height - 2,width: membersButton.bounds.width - 10,height: 2))
    membersBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    membersButton.addSubview(membersBorder)
    membersButton.addTarget(self, action: #selector(dimBackground(_:)), for: .touchDown)
    membersButton.addTarget(self, action: #selector(resetBackground(_:)), for: .touchDragExit)
    
    settingsButton = UIButton(frame: CGRect(x: 0,y: membersButton.frame.maxY,width: bounds.width,height: 67))
    settingsButton.backgroundColor = UIColor.clear
    scrollView.addSubview(settingsButton)
    let settingsIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 25, height: 25))
    settingsIcon.image = UIImage(named: "UserSettings")
    settingsButton.addSubview(settingsIcon)
    let settingsLabel = UILabel(frame: CGRect(x: 60,y: 21,width: bounds.width - 55,height: 30))
    settingsLabel.center.y = settingsIcon.center.y
    settingsLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 18)
    settingsLabel.text = "Group Settings"
    settingsButton.addSubview(settingsLabel)
    let settingsBorder = UIView(frame: CGRect(x: 15,y: settingsButton.bounds.height - 2,width: settingsButton.bounds.width - 10,height: 2))
    settingsBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    settingsButton.addSubview(settingsBorder)
    settingsButton.addTarget(self, action: #selector(dimBackground(_:)), for: .touchDown)
    settingsButton.addTarget(self, action: #selector(resetBackground(_:)), for: .touchDragExit)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    
  }
  
  func dimBackground(_ sender: UIButton) {
    sender.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
  }
  
  func resetBackground(_ sender: UIButton) {
    sender.backgroundColor = UIColor.clear
  }
  
}
