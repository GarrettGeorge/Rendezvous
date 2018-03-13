//
//  ViewController.swift
//  Rendezvous
//
//  Created by Garrett George on 4/11/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift
import Foundation
import QuartzCore
import ImageIO
import FBSDKLoginKit
import FBSDKCoreKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MapViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
  
  //UI view controller variables
  @IBOutlet var mainMapView: MKMapView!
  
  var buttonBar = UIView()
  var newMeetupView = UIView()
  var newMeetupButton = UIButton()
  var moreButton = UIButton()
  
  var newMeetupViewShown = false
  var meetupIconButton = UIButton()
  var defaultMeetupIconButton: UIButton!
  var meetupNameTextField = UITextField()
  var locationTextField = UITextField()
  var savedLocationsButton = UIButton()
  var savedLocationObject: SavedLocation?
  
  var meetupsFilterView = UIView()
  var meetupsFilterViewShown = false
  var currentFilteredMeetup = Meetup()
  var currentFilteredRegion = MKCoordinateRegion()
  var currentFilteredAnnotation = MKPointAnnotation()
  
  var expandedMenu = UIView()
  var expandedMenuShown = false
  var expandedMenuShadow = UIView()
  
  var broadcastLocationView = UIView()
  var broadcastLocationShadow = UIView()
  var proximitySlider = UISlider()
  var sliderText = UILabel()
  
  var savedAlert = UIView()
  var savedAlertText = UILabel()
  
  
  // MapKit Variables for searching and custom annotations
  var searchController: UISearchController!
  var searchBar: UISearchBar!
  var localSearchRequest:MKLocalSearchRequest!
  var localSearch:MKLocalSearch!
  var localSearchResponse:MKLocalSearchResponse!
  var annotation: MKAnnotation!
  var annotationPoint: MKPointAnnotation = MKPointAnnotation()
  var annotationPinView:MKPinAnnotationView!
  var centerLocation: CLLocation!
  
  //New Meetup Variables
  var meetup: Meetup?
  var newMeetupLocation: CLLocation?
  var newMeetupAddress: String = ""
  var newMeetupName: String = ""
  
  //var newMeetupLocation:
  var realm = try! Realm()
  lazy var liveMeetups: Results<Meetup> = { self.realm.objects(Meetup.self).sorted(byProperty: "meetupName")}()
  lazy var savedLocations: Results<SavedLocation> = { self.realm.objects(SavedLocation.self).sorted(byProperty: "latitude")}()
  var liveMeetupButtons = [UIButton]()
  var annotations = [MKPointAnnotation]()
  var userLocationRegion: MKCoordinateRegion?
  var regionToShow = MKCoordinateRegion()
  var myLocationName: String = ""
  var myLocation = CLLocationCoordinate2D()
  
  // Image Picking
  var imagePicker = UIImagePickerController()
  
  let MAIN_COLOR = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
  
  //Method based variables
  fileprivate var locationManager: CLLocationManager?
  
  // Tab bar control variable
  var isMapItemSelected = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager = CLLocationManager()
    
    NotificationCenter.default.addObserver(self, selector: #selector(clearNewMeetupSubview(_:)), name: NSNotification.Name(rawValue: "clearNewMeetup"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(filterMapViewWithMeetups(_:)), name: NSNotification.Name(rawValue: "filterMapWithMeetup"), object: nil)
    
    self.view.isUserInteractionEnabled = true
    self.navigationController?.navigationBar.isHidden = false
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "More"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(makeExpandedMenuMaps(_:)))
    
    makeButtonBarSubView()
    self.view.addSubview(buttonBar)
    // 2
    imagePicker.delegate = self
    locationManager?.delegate = self
    self.tabBarController?.delegate = self
    
    self.mainMapView.tintColor = UIColor(red: 31/255, green: 140/255, blue: 248/255, alpha: 1)
    self.mainMapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMeetupsFilterView(_:))))
    locationManager?.requestAlwaysAuthorization()
    // 3
    if CLLocationManager.authorizationStatus() == .authorizedAlways {
      locationManager?.distanceFilter = 10.0
      locationManager?.desiredAccuracy = kCLLocationAccuracyBest
      locationManager?.requestLocation()
    }
    mainMapView.delegate = self
    self.mainMapView.showsCompass = true
    self.mainMapView.showsUserLocation = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    isMapItemSelected = false
    self.hidesBottomBarWhenPushed = false
    self.tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    liveMeetups = { self.realm.objects(Meetup.self)}()
    isMapItemSelected = true
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    dismissMeetupsFilterView(self)
  }
  
  func makeButtonBarSubView() {
    // Superview for the bar button view frame
    buttonBar = UIView(frame: CGRect(x: 5,y: 5,width: self.view.frame.size.width-10,height: 48))
    buttonBar.layer.cornerRadius = 15
    buttonBar.backgroundColor = MAIN_COLOR
    
    // Button for opening options for location services functions
    moreButton.frame = CGRect(x: 13,y: 2,width: 44,height: 44)
    moreButton.setImage(UIImage(named: "Meetup"), for: UIControlState())
    moreButton.setImage(UIImage(named: "MeetupHighlighted"), for: .selected)
    moreButton.addTarget(self, action: #selector(MapViewController.makeMeetupsFilterView(_:)), for: .touchUpInside)
    moreButton.adjustsImageWhenHighlighted = false
    buttonBar.addSubview(moreButton)
    
    // Centered search bar for searching the map for locations
    searchBar = UISearchBar(frame: CGRect(x: 59,y: 0,width: self.view.frame.size.width-118,height: 48))
    searchBar.searchBarStyle = .default
    searchBar.backgroundImage = UIImage()
    searchBar.placeholder = "Search for a place or address"
    let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
    textFieldInsideSearchBar?.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    searchBar.enablesReturnKeyAutomatically = true
    searchBar.delegate = self
    buttonBar.addSubview(searchBar)
    
    // Button for creating new meetup directly from the main screen
    newMeetupButton = UIButton(type: .contactAdd)
    newMeetupButton.frame = CGRect(x: self.view.frame.size.width-62,y: 2,width: 44,height: 44)
    newMeetupButton.tintColor = UIColor.white
    newMeetupButton.addTarget(self, action: #selector(MapViewController.makeNewMeetupSubview(_:)), for: .touchUpInside)
    buttonBar.addSubview(newMeetupButton)
  }
  
  // New Meetup view
  func makeNewMeetupSubview(_ sender: AnyObject) {
    
    if self.newMeetupView.frame.size.height == 0 {
      //Superview for the new meetup region
      self.newMeetupView = UIView(frame: CGRect(x: 5,y: 58,width: self.view.frame.size.width-10,height: 145))
      self.newMeetupView.backgroundColor = MAIN_COLOR
      self.newMeetupView.layer.cornerRadius = 15
      
      // Button for adding a meetup avatar
      self.meetupIconButton = UIButton(frame: CGRect(x: 10,y: 5,width: 44,height: 44))
      self.meetupIconButton.clipsToBounds = true
      self.meetupIconButton.layer.cornerRadius = 22
      self.meetupIconButton.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
      self.meetupIconButton.backgroundColor = UIColor(red: 238/255, green: 252/255, blue: 247/255, alpha: 1)
      self.meetupIconButton.setImage(UIImage(named: "MeetupDefault"), for: UIControlState())
      self.meetupIconButton.addTarget(self, action: #selector(MapViewController.callImagePicker(_:)), for: .touchUpInside)
      self.meetupIconButton.adjustsImageWhenHighlighted = false
      self.newMeetupView.addSubview(meetupIconButton)
      
      // Text field for new meetup name
      meetupNameTextField = UITextField(frame: CGRect(x: 59,y: 10,width: self.newMeetupView.frame.size.width-69,height: 33))
      meetupNameTextField.tag = 0
      meetupNameTextField.placeholder = "Meetup Name"
      meetupNameTextField.backgroundColor = UIColor.white
      meetupNameTextField.layer.cornerRadius = 5
      meetupNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: meetupNameTextField.frame.size.height))
      meetupNameTextField.leftViewMode = .always
      meetupNameTextField.clearButtonMode = .always
      self.newMeetupView.addSubview(meetupNameTextField)
      
      locationTextField = UITextField(frame: CGRect(x: 59,y: 53,width: meetupNameTextField.frame.size.width,height: 33))
      locationTextField.tag = 1
      locationTextField.placeholder = "Meetup Location"
      locationTextField.backgroundColor = UIColor.white
      locationTextField.layer.cornerRadius = 5
      locationTextField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: locationTextField.frame.size.height))
      locationTextField.leftViewMode = .always
      locationTextField.clearButtonMode = .always
      savedLocationsButton.frame = CGRect(x: 0, y: 0, width: 28, height: 22)
      savedLocationsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
      savedLocationsButton.setImage(UIImage(named: "Save"), for: UIControlState())
      savedLocationsButton.addTarget(self, action: #selector(unwindToDetail(_:)), for: .touchUpInside)
      locationTextField.rightView = savedLocationsButton
      locationTextField.rightViewMode = .unlessEditing
      self.newMeetupView.addSubview(locationTextField)
      
      let locationImgView = UIImageView(image: UIImage(named: "ReCenter"))
      locationImgView.frame = CGRect(x: 17, y: 54, width: 32, height: 32)
      //self.newMeetupView.addSubview(locationImgView)
      
      let addFriendsButton = UIButton(frame: CGRect(x: (self.view.frame.size.width/2 - 100),y: 94,width: 200,height: 44))
      addFriendsButton.setTitle("Add Friends", for: UIControlState())
      addFriendsButton.layer.cornerRadius = 15
      addFriendsButton.backgroundColor = UIColor(red: 51/255, green: 151/255, blue: 219/255, alpha: 1)
      addFriendsButton.addTarget(self, action: #selector(MapViewController.addFriends(_:)), for: .touchUpInside)
      self.newMeetupView.addSubview(addFriendsButton)
      
      self.view.addSubview(self.newMeetupView)
    }
    if !self.newMeetupViewShown {
      showNewMeetupSubview()
    }
    else if self.newMeetupViewShown {
      dismissNewMeetupSubview()
    }
    
  }
  
  func showNewMeetupSubview() {
    self.view.endEditing(true)
    if self.meetupsFilterViewShown {
      dismissMeetupsFilterView(self)
    }
    shiftCenterRegion(self.newMeetupView, shouldShiftDown: true)
    self.newMeetupView.isHidden = false
    self.newMeetupViewShown = true
  }
  
  func dismissNewMeetupSubview() {
    self.view.endEditing(true)
    self.newMeetupView.isHidden = true
    self.newMeetupViewShown = false
    shiftCenterRegion(self.newMeetupView, shouldShiftDown: false)
  }
  
  func clearNewMeetupSubview(_ notification: Foundation.Notification) {
    self.meetupNameTextField.text = ""
    self.locationTextField.text = ""
    self.meetupIconButton.layer.cornerRadius = 22
    self.meetupIconButton.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
    self.meetupIconButton.backgroundColor = UIColor(red: 238/255, green: 252/255, blue: 247/255, alpha: 1)
    self.meetupIconButton.setImage(UIImage(named: "MeetupDefault"), for: UIControlState())
    self.newMeetupLocation = CLLocation()
    self.newMeetupAddress = ""
    self.meetup = nil
    dismissNewMeetupSubview()
  }
  
  func unwindToDetail(_ segue: UIStoryboardSegue) {
    self.performSegue(withIdentifier: "toSavedLocations", sender: self)
  }
  
  func addFriends(_ sender: AnyObject) {
    self.view.endEditing(true)
    let storyboard = UIStoryboard(name: "Meetup", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "AddFriends") as! MeetupContactSelectionViewController
    
    guard let name = meetupNameTextField.text,
      let location = locationTextField.text else {
        return
    }
    
    if self.meetup == nil {
      self.meetup = Meetup()
      self.meetup!.locationAddress = self.newMeetupAddress
      self.meetup!.locationLatitude = newMeetupLocation?.coordinate.latitude ?? 0.0
      self.meetup!.locationLongitude = newMeetupLocation?.coordinate.longitude ?? 0.0
      self.meetup!.name = name
      self.meetup!.locationName = location
      self.meetup!.meetupIcon = UIImagePNGRepresentation((self.meetupIconButton.imageView?.image)!)
      viewController.meetup = self.meetup
    }
    
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  // Groups map filter view
  func makeMeetupsFilterView(_ sender: UIButton) {
    
    if self.meetupsFilterView.frame.size.height == 0 {
      self.meetupsFilterView = UIView(frame: CGRect(x: 5,y: 58,width: self.view.frame.size.width-10,height: 54))
      self.meetupsFilterView.layer.cornerRadius = 15
      self.meetupsFilterView.backgroundColor = MAIN_COLOR
      
      let liveMeetupsArray = Array(liveMeetups)
      if liveMeetupsArray.count > 0 {
        for i in 0 ... liveMeetupsArray.count - 1 {
          let f: CGFloat = CGFloat(i)
          let tempButton = UIButton(frame: CGRect(x: 10*(f + 1)+44*f,y: 5,width: 44,height: 44))
          tempButton.layer.allowsEdgeAntialiasing = true
          liveMeetupButtons.append(tempButton)
          
          var icon = UIImage(named: "MeetupDefault")
          if let iconData = liveMeetupsArray[i].meetupIcon {
            icon = UIImage(data: iconData)
          }
          //icon = MapViewController.maskRoundedImage(icon!, radius: Float(icon!.size.height/2))
          liveMeetupButtons[i].setImage(icon, for: UIControlState())
          liveMeetupButtons[i].tag = i
          liveMeetupButtons[i].addTarget(self, action: #selector(filterMapViewWithMeetups(_:)), for: .touchUpInside)
          self.meetupsFilterView.addSubview(liveMeetupButtons[i])
          
        }
      }
      self.view.addSubview(self.meetupsFilterView)
      self.meetupsFilterView.isHidden = true
      self.moreButton.isSelected = true
    }
    if self.meetupsFilterViewShown && self.meetupsFilterView.frame.size.height != 0{
      dismissMeetupsFilterView(self)
    }
    else {
      showMeetupsFilterView()
    }
    
    
  }
  
  func showMeetupsFilterView() {
    if self.newMeetupViewShown {
      dismissNewMeetupSubview()
    }
    self.meetupsFilterView.isHidden = false
    self.meetupsFilterViewShown = true
    self.moreButton.isSelected = true
  }
  
  func dismissMeetupsFilterView(_ sender: AnyObject) {
    self.meetupsFilterView.isHidden = true
    self.meetupsFilterViewShown = false
    self.moreButton.isSelected = false
  }
  
  func filterMapViewWithMeetups(_ sender: UIButton) {
    if !annotations.isEmpty {
      removeAnnotations()
    }
    if currentFilteredMeetup != liveMeetups[sender.tag]{
      self.mainMapView.removeAnnotation(currentFilteredAnnotation)
      self.currentFilteredMeetup = liveMeetups[sender.tag]
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: self.currentFilteredMeetup.locationLatitude, longitude: self.currentFilteredMeetup.locationLongitude)
      annotation.title = self.currentFilteredMeetup.name
      _ = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MeetupDestination")
      self.currentFilteredAnnotation = annotation
      self.mainMapView.addAnnotation(annotation)
      self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
      //self.currentFilteredRegion = self.mainMapView.region
    }
    else {
      self.mainMapView.setRegion(currentFilteredRegion, animated: true)
    }
    
  }
  
  // Expanded Menu
  func makeExpandedMenuMaps(_ sender: AnyObject) {
    if !self.expandedMenuShown && self.expandedMenu.frame.size.height == 0 {
      let width: CGFloat = self.view.frame.size.width * 0.70
      self.expandedMenu = UIView(frame: CGRect(x: self.view.frame.size.width,y: 0,width: width,height: UIScreen.main.bounds.height))
      self.expandedMenu.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
      self.expandedMenu.isUserInteractionEnabled = true
      
      // Map based functions
      // Maps title label
      let mapLabel = UILabel(frame: CGRect(x: 10,y: 10,width: self.expandedMenu.frame.size.width-15,height: 40))
      mapLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 22)
      mapLabel.text = "Maps"
      mapLabel.textAlignment = .left
      let mapBorderLayer = CALayer()
      mapBorderLayer.frame = CGRect(x: -10, y: mapLabel.frame.size.height - 2, width: mapLabel.frame.size.width + 4, height: 2)
      mapBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      mapLabel.layer.addSublayer(mapBorderLayer)
      self.expandedMenu.addSubview(mapLabel)
      
      // Flagging a location UI
      let flagLocationButton = UIButton(frame: CGRect(x: 0,y: 48,width: self.expandedMenu.frame.size.width,height: 58))
      flagLocationButton.backgroundColor = UIColor.clear
      flagLocationButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), for: .touchDown)
      flagLocationButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchUpInside)
      flagLocationButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchDragExit)
      let flagLocationIcon = UIImageView(frame: CGRect(x: 10, y: 13, width: 33, height: 33))
      flagLocationIcon.image = UIImage(named: "Flag")
      flagLocationButton.addSubview(flagLocationIcon)
      let flagLocationLabel = UILabel(frame: CGRect(x: 48,y: 10,width: flagLocationButton.frame.size.width - 53,height: 40))
      flagLocationLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 16)
      flagLocationLabel.text = "Flag a Location"
      flagLocationButton.addSubview(flagLocationLabel)
      let flagLocationBorderLayer = CALayer()
      flagLocationBorderLayer.frame = CGRect(x: 10, y: flagLocationButton.frame.size.height - 2, width: flagLocationButton.frame.size.width - 20, height: 2)
      flagLocationBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      flagLocationButton.layer.addSublayer(flagLocationBorderLayer)
      self.expandedMenu.addSubview(flagLocationButton)
      
      // Broadcasting location UI
      let broadcastLocationButton = UIButton(frame: CGRect(x: 0,y: 104,width: self.expandedMenu.frame.size.width,height: 58))
      broadcastLocationButton.backgroundColor = UIColor.clear
      broadcastLocationButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), for: .touchDown)
      broadcastLocationButton.addTarget(self, action: #selector(broadcastMyLocation(_:)), for: .touchUpInside)
      broadcastLocationButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchDragExit)
      let broadcastLocationIcon = UIImageView(frame: CGRect(x: 10, y: 13, width: 33, height: 33))
      broadcastLocationIcon.image = UIImage(named: "Broadcast")
      broadcastLocationButton.addSubview(broadcastLocationIcon)
      let broadcastLocationLabel = UILabel(frame: CGRect(x: 48,y: 10,width: broadcastLocationButton.frame.size.width - 53,height: 40))
      broadcastLocationLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 16)
      broadcastLocationLabel.text = "Broadcast my Location"
      broadcastLocationButton.addSubview(broadcastLocationLabel)
      let broadcastLocationBorderLayer = CALayer()
      broadcastLocationBorderLayer.frame = CGRect(x: 10, y: broadcastLocationButton.frame.size.height - 2, width: broadcastLocationButton.frame.size.width - 20, height: 2)
      broadcastLocationBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      broadcastLocationButton.layer.addSublayer(broadcastLocationBorderLayer)
      self.expandedMenu.addSubview(broadcastLocationButton)
      
      // Finding local meetups UI
      let nearbyMeetupsButton = UIButton(frame: CGRect(x: 0,y: 160,width: self.expandedMenu.frame.size.width,height: 58))
      nearbyMeetupsButton.backgroundColor = UIColor.clear
      nearbyMeetupsButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), for: .touchDown)
      nearbyMeetupsButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchUpInside)
      nearbyMeetupsButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchDragExit)
      let nearbyMeetupsIcon = UIImageView(frame: CGRect(x: 10, y: 13, width: 33, height: 33))
      nearbyMeetupsIcon.image = UIImage(named: "NearbyMeetups")
      nearbyMeetupsButton.addSubview(nearbyMeetupsIcon)
      let nearbyMeetupsLabel = UILabel(frame: CGRect(x: 48, y: 10, width: nearbyMeetupsButton.frame.size.width - 53, height: 40))
      nearbyMeetupsLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 16)
      nearbyMeetupsLabel.text = "Find Nearby Meetups"
      nearbyMeetupsButton.addSubview(nearbyMeetupsLabel)
      let nearbyMeetupsBorderLayer = CALayer()
      nearbyMeetupsBorderLayer.frame = CGRect(x: 10, y: nearbyMeetupsButton.frame.size.height - 2, width: nearbyMeetupsButton.frame.size.width - 20, height: 2)
      nearbyMeetupsBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      nearbyMeetupsButton.layer.addSublayer(nearbyMeetupsBorderLayer)
      self.expandedMenu.addSubview(nearbyMeetupsButton)
      
      // Account based functions
      // Account title label
      let accountLabel = UILabel(frame: CGRect(x: 10,y: 234,width: self.expandedMenu.frame.size.width - 14, height: 40))
      accountLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 22)
      accountLabel.text = "Account"
      let accountBorderLayer = CALayer()
      accountBorderLayer.frame = CGRect(x: -10, y: accountLabel.frame.size.height - 2, width: accountLabel.frame.size.width + 2, height: 2)
      accountBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      accountLabel.layer.addSublayer(accountBorderLayer)
      self.expandedMenu.addSubview(accountLabel)
      
      let profileButton = UIButton(frame: CGRect(x: 0,y: 272,width: self.expandedMenu.frame.size.width,height: 58))
      profileButton.backgroundColor = UIColor.clear
      profileButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), for: .touchDown)
      profileButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchUpInside)
      profileButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchDragExit)
      let profileIcon = UIImageView(frame: CGRect(x: 10, y: 13, width: 33, height: 33))
      profileIcon.image = UIImage(named: "Broadcast")
      profileButton.addSubview(profileIcon)
      let profileLabel = UILabel(frame: CGRect(x: 48, y: 10, width: profileButton.frame.size.width - 53, height: 40))
      profileLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 16)
      profileLabel.text = KeychainWrapper.standard.string(forKey: "display_name")
      profileButton.addSubview(profileLabel)
      let profileBorderLayer = CALayer()
      profileBorderLayer.frame = CGRect(x: 10, y: profileButton.frame.size.height - 2, width: profileButton.frame.size.width - 20, height: 2)
      profileBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      profileButton.layer.addSublayer(profileBorderLayer)
      self.expandedMenu.addSubview(profileButton)
      
      let settingsButton = UIButton(frame: CGRect(x: 0,y: 328,width: self.expandedMenu.frame.size.width,height: 58))
      settingsButton.backgroundColor = UIColor.clear
      settingsButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), for: .touchDown)
      settingsButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchUpInside)
      settingsButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchDragExit)
      let settingsIcon = UIImageView(frame: CGRect(x: 10, y: 13, width: 33, height: 33))
      settingsIcon.image = UIImage(named: "UserSettings")
      settingsButton.addSubview(settingsIcon)
      let settingsLabel = UILabel(frame: CGRect(x: 48, y: 10, width: settingsButton.frame.size.width - 53, height: 40))
      settingsLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 16)
      settingsLabel.text = "Settings"
      settingsButton.addSubview(settingsLabel)
      let settingsBorderLayer = CALayer()
      settingsBorderLayer.frame = CGRect(x: 10, y: settingsButton.frame.size.height - 2, width: settingsButton.frame.size.width - 20, height: 2)
      settingsBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      settingsButton.layer.addSublayer(settingsBorderLayer)
      self.expandedMenu.addSubview(settingsButton)
      
      let contactsButton = UIButton(frame: CGRect(x: 0, y: 384, width: self.expandedMenu.frame.size.width, height: 58))
      contactsButton.backgroundColor = UIColor.clear
      contactsButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), for: .touchDown)
      contactsButton.addTarget(self, action: #selector(presentContactsViewController(_:)), for: .touchUpInside)
      contactsButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchDragExit)
      let contactsIcon = UIImageView(frame: CGRect(x: 10, y: 13, width: 33, height: 33))
      contactsIcon.image = UIImage(named: "Contacts")
      contactsButton.addSubview(contactsIcon)
      let contactsLabel = UILabel(frame: CGRect(x: 48, y: 10, width: settingsButton.frame.size.width - 53, height: 40))
      contactsLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 16)
      contactsLabel.text = "Contacts"
      contactsButton.addSubview(contactsLabel)
      let contactsBorderLayer = CALayer()
      contactsBorderLayer.frame = CGRect(x: 10, y: contactsButton.frame.size.height - 2, width: contactsButton.frame.size.width - 20, height: 2)
      contactsBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      contactsButton.layer.addSublayer(contactsBorderLayer)
      self.expandedMenu.addSubview(contactsButton)
      
      let logoutButton = UIButton(frame: CGRect(x: 0, y: 440, width: self.expandedMenu.frame.size.width, height: 58))
      logoutButton.backgroundColor = UIColor.clear
      logoutButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), for: .touchDown)
      logoutButton.addTarget(self, action: #selector(logoutUser(_:)), for: .touchUpInside)
      logoutButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), for: .touchDragExit)
      let logoutIcon = UIImageView(frame: CGRect(x: 10, y: 13, width: 33, height: 33))
      logoutIcon.image = UIImage(named: "Logout")
      logoutButton.addSubview(logoutIcon)
      let logoutLabel = UILabel(frame: CGRect(x: 48, y: 10, width: settingsButton.frame.size.width - 53, height: 40))
      logoutLabel.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 16)
      logoutLabel.text = "Logout"
      logoutButton.addSubview(logoutLabel)
      let logoutBorderLayer = CALayer()
      logoutBorderLayer.frame = CGRect(x: 10, y: logoutButton.frame.size.height - 2, width: logoutButton.frame.size.width - 20, height: 2)
      logoutBorderLayer.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
      logoutButton.layer.addSublayer(logoutBorderLayer)
      self.expandedMenu.addSubview(logoutButton)
      
      self.expandedMenuShadow = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height))
      self.expandedMenuShadow.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
      self.expandedMenuShadow.isUserInteractionEnabled = true
      self.expandedMenuShadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MapViewController.dismissExpandedMenu(_:))))
      
      self.expandedMenuShown = true
      UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
      UIApplication.shared.keyWindow?.addSubview(self.expandedMenuShadow)
      UIApplication.shared.keyWindow?.addSubview(self.expandedMenu)
      UIView.animate(withDuration: 0.25, animations: {
        self.expandedMenuShadow.alpha = 1
        self.expandedMenu.center.x -= self.expandedMenu.frame.size.width
      })
    }
    else if !self.expandedMenuShown && self.expandedMenu.frame.size.height != 0 {
      UIView.animate(withDuration: 0.25, animations: {
        self.expandedMenuShadow.alpha = 1
        self.expandedMenu.center.x -= self.expandedMenu.frame.size.width
      })
      self.expandedMenuShown = true
      
    }
  }
  
  func dismissExpandedMenu(_ sender: AnyObject) {
    UIView.animate(withDuration: 0.25, animations: {
      self.expandedMenuShadow.alpha = 0
      self.expandedMenu.center.x += self.expandedMenu.frame.size.width
    })
    self.expandedMenuShown = false
    UIApplication.shared.isStatusBarHidden = false
  }
  
  func presentContactsViewController(_ sender: UIButton) {
    let storyboard = UIStoryboard(name: "Contacts", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "ContactsList") as! ContactsViewController
    dismissExpandedMenu(self)
    unHighlightButtonBackground(sender)
    self.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func logoutUser(_ sender: AnyObject) {
    let loginManager = FBSDKLoginManager()
    loginManager.logOut()
    UserDefaults.standard.set(false, forKey: "hasLoginKey")
    let storyboard = UIStoryboard(name: "LoginEntryViews", bundle: nil)
    let viewController = storyboard.instantiateViewController(withIdentifier: "LoginNavController") as! UINavigationController
    present(viewController, animated: true, completion: nil)
  }
  
  func highlightButtonBackground(_ sender: UIButton) {
    sender.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
  }
  
  func unHighlightButtonBackground(_ sender: UIButton) {
    sender.backgroundColor = UIColor.clear
  }
  
  // Broadcast my location
  func broadcastMyLocation(_ sender: AnyObject) {
    dismissExpandedMenu(self)
    unHighlightButtonBackground(sender as! UIButton)
    let x = self.view.center.x - 125
    let y = self.mainMapView.center.y - 188/4
    self.broadcastLocationShadow = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height))
    self.broadcastLocationShadow.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    self.broadcastLocationShadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBroadcastLocationAlert(_:))))
    UIApplication.shared.keyWindow?.addSubview(self.broadcastLocationShadow)
    self.broadcastLocationView = UIView(frame: CGRect(x: x,y: y,width: 250,height: 188))
    self.broadcastLocationView.layer.cornerRadius = 15
    self.broadcastLocationView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    let broadcastLocationTitle = UILabel(frame: CGRect(x: 0,y: 0,width: self.broadcastLocationView.frame.size.width,height: 35))
    broadcastLocationTitle.text = "Broadcast My Location"
    broadcastLocationTitle.textAlignment = .center
    let titleBorderLayer = CALayer()
    titleBorderLayer.frame = CGRect(x: 0, y: broadcastLocationTitle.frame.size.height - 1, width: self.broadcastLocationView.frame.size.width, height: 1)
    titleBorderLayer.backgroundColor = MAIN_COLOR.cgColor
    broadcastLocationTitle.layer.addSublayer(titleBorderLayer)
    self.broadcastLocationView.addSubview(broadcastLocationTitle)
    
    let locationIcon = UIImageView(image: UIImage(named: "ReCenter"))
    locationIcon.frame = CGRect(x: 5, y: 44, width: 32, height: 32)
    self.broadcastLocationView.addSubview(locationIcon)
    
    let locationNameTextField = UITextField(frame: CGRect(x: 42,y: 46,width: self.broadcastLocationView.frame.size.width - 52,height: 32))
    locationNameTextField.placeholder = "Location Nickname"
    locationNameTextField.text = self.myLocationName
    locationNameTextField.clearButtonMode = .whileEditing
    self.broadcastLocationView.addSubview(locationNameTextField)
    
    proximitySlider.frame = CGRect(x: 10,y: 75,width: self.broadcastLocationView.frame.size.width - 20,height: 32)
    proximitySlider.isContinuous = true
    proximitySlider.minimumValue = 2
    proximitySlider.maximumValue = 35
    proximitySlider.tintColor = MAIN_COLOR
    //proximitySlider.thumbTintColor = MAIN_COLOR
    proximitySlider.value = 35
    proximitySlider.addTarget(self, action: #selector(proximitySliderValueDidChange(_:)), for: .valueChanged)
    self.broadcastLocationView.addSubview(proximitySlider)
    
    self.sliderText.frame = CGRect(x: 10, y: 107, width: self.broadcastLocationView.frame.size.width - 20, height: 32)
    self.sliderText.text = "To: All My Friends"
    self.sliderText.textAlignment = .center
    let sliderTextBorderLayer = CALayer()
    sliderTextBorderLayer.frame = CGRect(x: -10, y: self.sliderText.frame.size.height + 1, width: self.broadcastLocationView.frame.size.width, height: 1)
    sliderTextBorderLayer.backgroundColor = MAIN_COLOR.cgColor
    self.sliderText.layer.addSublayer(sliderTextBorderLayer)
    self.broadcastLocationView.addSubview(self.sliderText)
    
    let cancelButton = UIButton(frame: CGRect(x: 0,y: 143,width: self.broadcastLocationView.frame.size.width/2,height: 45))
    cancelButton.clipsToBounds = true
    cancelButton.setTitle("Cancel", for: UIControlState())
    cancelButton.setTitleColor(MAIN_COLOR, for: UIControlState())
    //cancelButton.addTarget(self, action: #selector(highlightButtonBackground(_:)), forControlEvents: .TouchDown)
    //cancelButton.addTarget(self, action: #selector(unHighlightButtonBackground(_:)), forControlEvents: .TouchDragExit)
    cancelButton.addTarget(self, action: #selector(dismissBroadcastLocationAlert(_:)), for: .touchUpInside)
    self.broadcastLocationView.addSubview(cancelButton)
    let confirmButton = UIButton(frame: CGRect(x: 126,y: 143,width: self.broadcastLocationView.frame.size.width/2, height: 45))
    confirmButton.setTitle("Confirm", for: UIControlState())
    confirmButton.setTitleColor(MAIN_COLOR, for: UIControlState())
    confirmButton.addTarget(self, action: #selector(broadcastLocationToServer(_:)), for: .touchUpInside)
    self.broadcastLocationView.addSubview(confirmButton)
    let buttonSeparator = UIView(frame: CGRect(x: 125,y: 141,width: 1,height: 37))
    buttonSeparator.backgroundColor = MAIN_COLOR
    self.broadcastLocationView.addSubview(buttonSeparator)
    
    UIApplication.shared.keyWindow?.addSubview(self.broadcastLocationView)
  }
  
  func dismissBroadcastLocationAlert(_ sender: AnyObject) {
    self.broadcastLocationShadow.removeFromSuperview()
    self.broadcastLocationView.removeFromSuperview()
  }
  
  func proximitySliderValueDidChange(_ sender: UISlider) {
    let value = sender.value
    
    if value >= 5 && value < 10 {
      self.sliderText.text = "To: Friends 5 minutes away"
    }
    else if value >= 10 && value < 15 {
      self.sliderText.text = "To: Friends 10 minutes away"
    }
    else if value >= 15 && value < 20 {
      self.sliderText.text = "To: Friends 15 minutes away"
    }
    else if value >= 20 && value < 25 {
      self.sliderText.text = "To: Friends 20 minutes away"
    }
    else if value >= 25 && value < 30{
      self.sliderText.text = "To: Friends 25 minutes away"
    }
    else if value >= 30 && value < 35 {
      self.sliderText.text = "To: Friends 30 minutes away"
    }
    else if value == 35 {
      self.sliderText.text = "To: All My Friends"
    }
  }
  
  func broadcastLocationToServer(_ sender: UIButton) {
    let broadcastDict: [String: String] = ["proximity": (String(proximitySlider.value)), "latitude": String(self.myLocation.latitude), "longitude": String(self.myLocation.longitude)]
    let username = KeychainWrapper.standard.string(forKey: "username")
    HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "\(username)/location", data: broadcastDict as NSDictionary, completionHandler: {returnDict in
      if returnDict["serverCode"] as! Int == 200 {
        // show broadcasting location icon on map
      }
      else if returnDict["serverCode"] as! Int == 404 {
        let alertController = UIAlertController(title: nil, message:
          "Broadcast location failed. Try again.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
      }
    })
  }
  
  func diagnose(_ file: String = #file, line: Int = #line) -> Bool {
    print("Testing \(file):\(line)")
    return true
  }
  
  func shiftCenterRegion(_ view: UIView, shouldShiftDown should: Bool) {
    var locationRegion = mainMapView.region
    if should {
      locationRegion.center.latitude += 0.0035
      self.mainMapView.setRegion(locationRegion, animated: true)
    }
    else {
      locationRegion.center.latitude -= 0.0035
      self.mainMapView.setRegion(locationRegion, animated: true)
    }
    
  }
  
  static func maskRoundedImage(_ image: UIImage, radius: Float) -> UIImage {
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    layer.allowsEdgeAntialiasing = true
    
    layer.masksToBounds = true
    layer.cornerRadius = CGFloat(radius)
    layer.borderWidth = 20
    layer.borderColor = UIColor.white.cgColor
    
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return roundedImage!
  }
  
  static func croppIngimage(_ imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
    
    let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
    let cropped:UIImage = UIImage(cgImage:imageRef)
    return cropped
  }
  
  //    func resizeImage(image: UIImage,targetSize size:CGSize) -> UIImage {
  //        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
  //
  //    }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if searchBar.isFirstResponder {
      searchBar.endEditing(true)
    }
    if let touch = touches.first {
      if self.newMeetupViewShown {
        let threshold: CGFloat = 270.0
        let loc = touch.location(in: self.view)
        if loc.y > threshold {
          self.newMeetupView.isHidden = true
          self.newMeetupViewShown = false
          self.newMeetupView.endEditing(true)
          dismissNewMeetupSubview()
        }
      }
    }
  }
  
  override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      removeAnnotations()
      if !self.newMeetupViewShown {
        guard let locationRegion = userLocationRegion else {
          return
        }
        self.mainMapView.setRegion(locationRegion, animated: true)
      }
    }
  }
  
  func fadeViewInThenOut(_ view : UIView, delay: TimeInterval) {
    
    let animationDuration = 0.25
    
    // Fade in the view
    UIView.animate(withDuration: animationDuration, animations: { () -> Void in
      view.alpha = 1
    }, completion: { (Bool) -> Void in
      
      // After the animation completes, fade out the view after a delay
      
      UIView.animate(withDuration: animationDuration, delay: delay, options: UIViewAnimationOptions(), animations: { () -> Void in
        view.alpha = 0
      }, completion: nil)
    })
  }
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toSavedLocations" {
      (segue.destination as! SavedLocationsViewController).delegate = self
    }
  }
}

extension MapViewController: UIImagePickerControllerDelegate {
  func callImagePicker(_ sender: UIButton) {
    imagePicker.sourceType = .photoLibrary
    imagePicker.allowsEditing = true
    present(imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let imageView = UIImageView()
    if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
      self.meetupIconButton.backgroundColor = UIColor.clear
      self.meetupIconButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
      imageView.image = pickedImage
      let shortSide = imageView.image!.size.height > imageView.image!.size.width ? imageView.image!.size.width : imageView.image!.size.height
      imageView.image = MapViewController.croppIngimage(imageView.image!, toRect: CGRect(x: 0, y: 0, width: shortSide, height: shortSide))
      let radius: Float = Float(imageView.image!.size.height/2)
      meetupIconButton.setImage(MapViewController.maskRoundedImage(imageView.image!, radius: radius), for: UIControlState())
    }
    dismiss(animated: true, completion: nil)
  }
}

extension MapViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
    
    self.searchBar.endEditing(true)
    if self.newMeetupViewShown {
      dismissNewMeetupSubview()
    }
    mainMapView.removeAnnotations(mainMapView.annotations)
    //mainMapView.addAnnotation(annotationPoint)
    
    // Begins local search based on current map region
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = searchBar.text
    guard let locationRegion = userLocationRegion else {
      locationManager?.requestLocation()
      return
    }
    localSearchRequest.region = locationRegion
    localSearch = MKLocalSearch(request: localSearchRequest)
    localSearch.start { (localSearchResponse, error) -> Void in
      
      if localSearchResponse == nil{
        let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
      }
      
      for i in (localSearchResponse?.mapItems)! as [MKMapItem] {
        if i.placemark.coordinate.latitude != self.currentFilteredMeetup.locationLatitude && i.placemark.coordinate.longitude != self.currentFilteredMeetup.locationLongitude {
          let annoPoint = MKPointAnnotation()
          annoPoint.coordinate.latitude = i.placemark.coordinate.latitude
          annoPoint.coordinate.longitude = i.placemark.coordinate.longitude
          annoPoint.title = i.name
          self.mainMapView.addAnnotation(annoPoint)
          self.annotations.append(annoPoint)
        }
      }
      
      self.annotationPinView = MKPinAnnotationView(annotation: self.annotationPoint, reuseIdentifier: "SearchedPin")
      self.mainMapView.showAnnotations(self.mainMapView.annotations, animated: true)
      self.regionToShow.center = self.mainMapView.centerCoordinate
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    self.regionToShow = self.mainMapView.region
    self.currentFilteredRegion = self.mainMapView.region
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    let addButton = UIButton(type: .contactAdd) // button with info sign in it
    addButton.tintColor = MAIN_COLOR
    let saveButton = UIButton(type: .detailDisclosure)
    saveButton.tintColor = MAIN_COLOR
    saveButton.setImage(UIImage(named: "Save"), for: UIControlState())
    
    if annotation is MKUserLocation {
      return nil
    }
    //        if annotation.coordinate.latitude == self.userLocationRegion?.center.latitude && annotation.coordinate.longitude == self.userLocationRegion?.center.longitude {
    //            if let pView = mapView.dequeueReusableAnnotationViewWithIdentifier("user") {
    //            //pView.image = UIImage(named: "UserLoc")
    //            pView.canShowCallout = true
    //            pView.leftCalloutAccessoryView = saveButton
    //            pView.rightCalloutAccessoryView = addButton
    //            return pView
    //
    //        }
    var destinationPin = mapView.dequeueReusableAnnotationView(withIdentifier: "MeetupDestination") as? MKPinAnnotationView
    if destinationPin == nil {
      destinationPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MeetupDestination")
      destinationPin?.canShowCallout = true
      destinationPin?.animatesDrop = true
      destinationPin?.pinTintColor = MAIN_COLOR
      destinationPin?.rightCalloutAccessoryView = addButton
      destinationPin?.leftCalloutAccessoryView = saveButton
      return destinationPin
    }
    else if destinationPin != nil {
      return destinationPin
    }
    var searchedPin = mapView.dequeueReusableAnnotationView(withIdentifier: "SearchedPin") as? MKPinAnnotationView
    if searchedPin == nil {
      searchedPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "SearchedPin")
      searchedPin?.canShowCallout = true
      searchedPin?.animatesDrop = true
      searchedPin?.pinTintColor = UIColor.red
      searchedPin?.rightCalloutAccessoryView = addButton
      searchedPin?.leftCalloutAccessoryView = saveButton
      return searchedPin
    }
    else if searchedPin != nil {
      return searchedPin
    }
    return searchedPin == nil ? destinationPin : searchedPin
  }
  
  func getReversedGeocodeLocation(searchLocation location: CLLocation, completionHandler: @escaping (String?, NSError?) ->()) {
    
    CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
      
      var address: String!
      
      if error != nil {
        print("Reverse geocoder failed with error" + error!.localizedDescription)
        return
      }
      else if placemarks?.count > 0 {
        if let pm = placemarks!.first {
          address = pm.name!
        }
      }
      else {
        print("Problem with the data received from geocoder")
      }
      completionHandler(address, error as NSError?)
    })
  }
  
  func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let nmLocation = CLLocation(latitude: annotationView.annotation!.coordinate.latitude, longitude: annotationView.annotation!.coordinate.longitude)
    if control == annotationView.rightCalloutAccessoryView {
      newMeetupLocation = nmLocation
      if mainMapView.selectedAnnotations.count == 0 {
        return
      }
      else {
        let anno = mainMapView.selectedAnnotations[0] as MKAnnotation
        newMeetupName = anno.title!!
      }
      self.getReversedGeocodeLocation(searchLocation: nmLocation, completionHandler: { (address, error) in
        guard error == nil else {
          print("Reverse geocoder failed with error" + error!.localizedDescription)
          return
        }
        guard let address = address else {
          print("No address returned")
          return
        }
        self.newMeetupAddress = address
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        DispatchQueue.main.async(execute: {
          if !self.newMeetupViewShown {
            self.makeNewMeetupSubview(self)
          }
          self.meetupNameTextField.text = self.meetupNameTextField.text == "" ? self.newMeetupName + " Meetup": self.meetupNameTextField.text
          self.locationTextField.text = self.newMeetupAddress
        })
      })
    }
    else if control == annotationView.leftCalloutAccessoryView {
      let newSavedLocation = SavedLocation()
      if mainMapView.selectedAnnotations.count == 0 {
        return
      }
      else {
        let annotation = mainMapView.selectedAnnotations[0] as MKAnnotation
        newSavedLocation.locationName = annotation.title!!
        newSavedLocation.longitude = annotation.coordinate.longitude
        newSavedLocation.latitude = annotation.coordinate.latitude
      }
      
      makeSavedAlert()
      
      if checkDupeSavedLocation(newSavedLocation) {
        self.savedAlertText.text = "Location already saved"
        self.fadeViewInThenOut(self.savedAlert, delay: 1.5)
        return
      }
      
      self.getReversedGeocodeLocation(searchLocation: nmLocation, completionHandler: { (address, error) in
        guard error == nil else {
          print("Reverse geocoder failed with error" + error!.localizedDescription)
          return
        }
        guard let address = address else {
          print("No address returned")
          return
        }
        DispatchQueue.main.async(execute: {
          newSavedLocation.locationAddress = address
          self.realm.beginWrite()
          do {
            self.realm.add(newSavedLocation)
            try self.realm.commitWrite()
            self.savedAlertText.text = "Location Successfully Saved"
            self.fadeViewInThenOut(self.savedAlert, delay: 1.5)
          }
          catch let error as NSError {
            print("Error: \(error)")
            self.savedAlertText.text = "Location Failed To Save"
            self.savedAlert.backgroundColor = UIColor.red
            self.fadeViewInThenOut(self.savedAlert, delay: 1.5)
          }
        })
      })
    }
  }
  
  func makeSavedAlert() {
    self.savedAlert.frame = CGRect(x: 20, y: self.mainMapView.frame.size.height - 60, width: self.mainMapView.frame.size.width - 40, height: 40)
    //self.savedAlert.layer.cornerRadius = 15
    self.savedAlert.backgroundColor = MAIN_COLOR
    savedAlertText.frame = CGRect(x: 0,y: 0,width: self.savedAlert.frame.size.width,height: self.savedAlert.frame.size.height)
    savedAlertText.textAlignment = .center
    savedAlertText.textColor = UIColor.white
    self.savedAlert.addSubview(savedAlertText)
    self.savedAlert.alpha = 0
    self.mainMapView.addSubview(self.savedAlert)
  }
  
  func checkDupeSavedLocation(_ location: SavedLocation) -> Bool {
    
    if savedLocations.count <= 2 {
      for i in savedLocations {
        if i.latitude == location.latitude && i.longitude == location.longitude {
          return true
        }
      }
      return false
    }
    
    var left = 0
    var right = savedLocations.count - 1
    
    while(left <= right) {
      let mid = left/2 + right/2
      let val = savedLocations[mid].latitude
      
      if val == location.latitude {
        return true
      }
      if val < location.latitude {
        left = mid + 1
      }
      if val > location.latitude {
        right = mid - 1
      }
      print("right \(right)")
      print("left \(left)")
    }
    /*
     for i in results {
     if i == location {
     return true
     }
     }*/
    
    return false
  }
  
  func removeAnnotations() {
    mainMapView.removeAnnotations(annotations)
  }
  
  func recenterMapView() {
    guard let locationRegion = userLocationRegion else {
      return
    }
    self.mainMapView.setRegion(locationRegion, animated: true)
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last
    centerLocation = location
    print("did update locations")
    let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    userLocationRegion = region
    mainMapView.showAnnotations(mainMapView.annotations, animated: true)
    
    self.mainMapView.setRegion(region, animated: true)
    annotationPoint.coordinate = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    //self.mainMapView.addAnnotation(annotationPoint)
    self.getReversedGeocodeLocation(searchLocation: location!, completionHandler: { (address, error) in
      guard error == nil else {
        print("Reverse geocoder failed with error" + error!.localizedDescription)
        return
      }
      guard let address = address else {
        print("No address returned")
        return
      }
      self.myLocationName = address
      self.myLocation = (location?.coordinate)!
    })
  }
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    print("here")
  }
  
  func locationManager(_ manager: CLLocationManager,
                       didChangeAuthorization status: CLAuthorizationStatus)
  {
    if status == .authorizedAlways {
      locationManager?.startUpdatingLocation()
      // ...
    }
  }
  
  
  //Error catching locationManager function
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}

extension MapViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if viewController == self.navigationController && isMapItemSelected {
      recenterMapView()
    }
  }
}

extension MapViewController: SavedLocationsViewControllerDelegate {
  func updateLocationField(_ location: SavedLocation) {
    self.locationTextField.text = location.locationName
    self.meetupNameTextField.text = self.meetupNameTextField.text!.isEmpty ? location.locationName + " Meetup" : self.meetupNameTextField.text
    self.newMeetupAddress = location.locationAddress
    self.newMeetupName = location.locationName
    self.newMeetupLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
  }
}
