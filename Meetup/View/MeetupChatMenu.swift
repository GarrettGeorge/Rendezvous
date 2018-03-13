//
//  MeetupMenu.swift
//  Rendezvous
//
//  Created by Admin on 7/22/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class MeetupChatMenu: UIView, UIScrollViewDelegate {
  
  var meetupNameLabel: UILabel!
  var meetupIcon: UIButton!
  var meetupIconForeground: UIImageView!
  var infoLabel: UILabel!
  var locationNameLabel: UILabel!
  var dateLabel: UILabel!
  var detailsLabel: UILabel!
  var detailsEditButton: UIButton!
  
  var infoBorder: UIView!
  var locationBorder: UIView!
  var dateBorder: UIView!
  
  var membersButton: UIButton!
  var membersBorder: UIView!
  var showMapButton: UIButton!
  var showMapBorder: UIView!
  var settingsButton: UIButton!
  var settingsBorder: UIView!
  
  var scrollView: UIScrollView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    
    scrollView = UIScrollView(frame: self.bounds)
    scrollView.delegate = self
    scrollView.contentSize = CGSize(width: self.bounds.width - 10, height: self.bounds.height)
    self.addSubview(scrollView)
    
    meetupNameLabel = UILabel(frame: CGRect(x: 5,y: 30,width: self.bounds.width - 10,height: 20))
    meetupNameLabel.textAlignment = .center
    meetupNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
    scrollView.addSubview(meetupNameLabel)
    
    let buttonHeight = self.bounds.width - 60
    meetupIcon = UIButton(frame: CGRect(x: 30,y: 60,width: buttonHeight,height: buttonHeight))
    meetupIcon.clipsToBounds = true
    meetupIcon.layer.cornerRadius = buttonHeight / 2
    meetupIcon.layer.borderWidth = 5
    meetupIcon.layer.borderColor = UIColor.white.cgColor
    //meetupIconForeground = UIImageView(frame: CGRectMake(buttonHeight - buttonHeight / 1.41421356237, buttonHeight - buttonHeight / 1.41421356237, buttonHeight * 1.41421356237, buttonHeight * 1.41421356237))
    //meetupIcon.addSubview(meetupIconForeground)
    scrollView.addSubview(meetupIcon)
    
    infoLabel = UILabel()
    //        infoLabel.layer.borderWidth = 1
    //        infoLabel.layer.borderColor = UIColor.grayColor().CGColor
    //        infoLabel.layer.cornerRadius = 5
    locationNameLabel = UILabel(frame: CGRect(x: 10,y: 10,width: self.bounds.width - 10,height: 20))
    locationNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17.0)
    dateLabel = UILabel(frame: CGRect(x: 10, y: 36,width: self.bounds.width - 5,height: 20))
    dateLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
    detailsLabel = UILabel()
    detailsLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
    detailsLabel.numberOfLines = 0
    detailsLabel.lineBreakMode = .byWordWrapping
    scrollView.addSubview(infoLabel)
    
    detailsEditButton = UIButton()
    detailsEditButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
    detailsEditButton.setImage(UIImage(named: "Edit"), for: UIControlState())
    
    infoBorder = UIView()
    infoBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    scrollView.addSubview(infoBorder)
    
    locationBorder = UIView(frame: CGRect(x: 0,y: 32,width: self.bounds.width/2, height: 1))
    locationBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    infoLabel.addSubview(locationBorder)
    dateBorder = UIView(frame: CGRect(x: 0,y: 58,width: self.bounds.width/2 + (self.bounds.width/2)/5, height: 1))
    dateBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    infoLabel.addSubview(dateBorder)
    
    membersButton = UIButton()
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
    membersBorder = UIView()
    membersBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    membersButton.addSubview(membersBorder)
    membersButton.addTarget(self, action: #selector(dimBackground(_:)), for: .touchDown)
    membersButton.addTarget(self, action: #selector(resetBackground(_:)), for: .touchDragExit)
    
    showMapButton = UIButton()
    showMapButton.backgroundColor = UIColor.clear
    scrollView.addSubview(showMapButton)
    let showMapIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 25, height: 25))
    showMapIcon.image = UIImage(named: "ShowMap")
    showMapButton.addSubview(showMapIcon)
    let showMapLabel = UILabel(frame: CGRect(x: 60,y: 21,width: bounds.width - 55,height: 30))
    showMapLabel.center.y = showMapIcon.center.y
    showMapLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 18)
    showMapLabel.text = "Show Friends On Map"
    showMapButton.addSubview(showMapLabel)
    showMapBorder = UIView()
    showMapBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    showMapButton.addSubview(showMapBorder)
    showMapButton.addTarget(self, action: #selector(dimBackground(_:)), for: .touchDown)
    showMapButton.addTarget(self, action: #selector(resetBackground(_:)), for: .touchDragExit)
    
    settingsButton = UIButton()
    settingsButton.backgroundColor = UIColor.clear
    scrollView.addSubview(settingsButton)
    let settingsIcon = UIImageView(frame: CGRect(x: 20, y: 20, width: 25, height: 25))
    settingsIcon.image = UIImage(named: "UserSettings")
    settingsButton.addSubview(settingsIcon)
    let settingsLabel = UILabel(frame: CGRect(x: 60,y: 21,width: bounds.width - 55,height: 30))
    settingsLabel.center.y = settingsIcon.center.y
    settingsLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 18)
    settingsLabel.text = "Meetup Settings"
    settingsButton.addSubview(settingsLabel)
    settingsBorder = UIView()
    settingsBorder.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    settingsButton.addSubview(settingsBorder)
    settingsButton.addTarget(self, action: #selector(dimBackground(_:)), for: .touchDown)
    settingsButton.addTarget(self, action: #selector(resetBackground(_:)), for: .touchDragExit)
  }
  
  func dimBackground(_ sender: UIButton) {
    sender.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
  }
  
  func resetBackground(_ sender: UIButton) {
    sender.backgroundColor = UIColor.clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    
  }
  
}
