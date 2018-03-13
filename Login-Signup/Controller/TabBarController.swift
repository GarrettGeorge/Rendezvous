//
//  TabBarController.swift
//  Rendezvous
//
//  Created by Admin on 6/15/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
  
  var mapItem = UITabBarItem()
  var meetupsItem = UITabBarItem()
  var groupsItem = UITabBarItem()
  var feedItem = UITabBarItem()
  
  var meetupNC: UINavigationController!
  var groupNC: UINavigationController!
  var mapNC: UINavigationController!
  
  var shouldLoadSelectedVC = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    // Do any additional setup after loading the view.
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:UIControlState())
    
    mapItem = UITabBarItem(title: nil, image: UIImage(named: "Map"), tag: 0)
    mapItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    mapItem.image = mapItem.image?.withRenderingMode(.alwaysOriginal)
    let mapStoryboard = UIStoryboard(name: "Main", bundle: nil)
    mapNC = mapStoryboard.instantiateViewController(withIdentifier: "MainNavController") as! UINavigationController
    mapItem.selectedImage = UIImage(named: "MapHighlighted")
    mapNC.tabBarItem = mapItem
    
    meetupsItem = UITabBarItem(title: nil, image: UIImage(named: "Meetup"), tag: 1)
    meetupsItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    meetupsItem.image = meetupsItem.image?.withRenderingMode(.alwaysOriginal)
    let meetupStoryboard = UIStoryboard(name: "Meetup", bundle: nil)
    meetupNC = meetupStoryboard.instantiateViewController(withIdentifier: "MeetupNavController") as! UINavigationController
    meetupsItem.selectedImage = UIImage(named: "MeetupHighlighted")
    meetupNC.tabBarItem = meetupsItem
    
    groupsItem = UITabBarItem(title: nil, image: UIImage(named: "Group"), tag: 2)
    groupsItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    groupsItem.image = groupsItem.image?.withRenderingMode(.alwaysOriginal)
    let groupStoryboard = UIStoryboard(name: "Group", bundle: nil)
    groupNC = groupStoryboard.instantiateViewController(withIdentifier: "GroupNavController") as! UINavigationController
    groupsItem.selectedImage = UIImage(named: "GroupHighlighted")
    groupNC.tabBarItem = groupsItem
    
    feedItem = UITabBarItem(title: nil, image: UIImage(named: "Activity"), tag: 3)
    feedItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    feedItem.image = feedItem.image?.withRenderingMode(.alwaysOriginal)
    let feedStoryboard = UIStoryboard(name: "Contacts", bundle: nil)
    let feedNC = UINavigationController()
    feedItem.selectedImage = UIImage(named: "ActivityHighlighted")
    feedNC.tabBarItem = feedItem
    
    self.tabBar.barTintColor = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
    self.tabBar.tintColor = UIColor.white
    self.setViewControllers([mapNC,meetupNC,groupNC,feedNC], animated: true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
