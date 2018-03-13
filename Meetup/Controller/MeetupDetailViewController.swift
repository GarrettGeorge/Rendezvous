//
//  MeetupDetailViewController.swift
//  Rendezvous
//
//  Created by Admin on 4/26/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

class MeetupDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
  
  var realm = try! Realm()
  var meetup: Meetup!
  
  var meetupDict: [String: Dictionary<String,Any>] = [
    "strings": [
      "meetupName": "" as Any,
      "details": "" as Any,
      "locationName": "" as Any,
      "locationAddress": "" as Any,
      "timeOfMeetup": "" as Any,
      "uniqueID": "" as Any
    ],
    "location": [
      "latitude": 0.0,
      "longitude": 0.0
    ],
    "members": [
      "contactsArray": [[
        "contactID": ""
        ]],
      "groupsArray": [[
        "groupID", ""
        ]],
      
    ]
  ]
  var long: NSNumber = 0.0
  var lat: NSNumber = 0.0
  
  var newMeetup = false
  
  var savedLocation: SavedLocation?
  
  let imgPicker = UIImagePickerController()
  
  @IBOutlet var name: UITextField!
  @IBOutlet var location: UITextField!
  @IBOutlet var done: UIBarButtonItem!
  @IBOutlet var iconHidden: UIButton!
  @IBOutlet var addFriends: UIButton!
  @IBOutlet var expandOptions: UIButton!
  
  var meetupIcon = UIButton()
  var savedLocations = UIButton()
  
  var meetupIconForeground = UIImageView()
  
  // MARK: Expanded Options variables
  var backView = UIView()
  var descriptonTextView = UITextView()
  var datePicker = UIDatePicker()
  var datePickerButton = UIButton()
  var dateClearButton = UIButton()
  
  @IBOutlet var scrollView: UIScrollView!
  
  let MAIN_COLOR = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    meetup = Meetup()
    
    self.hidesBottomBarWhenPushed = true
    self.tabBarController?.tabBar.isHidden = true
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    
    scrollView.frame = self.view.frame
    scrollView.contentSize = self.view.frame.size
    self.view.addSubview(scrollView)
    
    iconHidden.isHidden = true
    
    meetupIcon.frame = CGRect(x: 15,y: 15,width: 100,height: 100)
    meetupIcon.addTarget(self, action: #selector(selectIcon(_:)), for: .touchUpInside)
    meetupIcon.layer.cornerRadius = 50
    meetupIcon.backgroundColor = UIColor(red: 238/255, green: 252/255, blue: 247/255, alpha: 1)
    meetupIconForeground.frame = CGRect(x: 14.644660,y: 14.644660,width: 50*1.41421,height: 50*1.41421)
    meetupIconForeground.image = UIImage(named: "MeetupDefault")
    meetupIcon.addSubview(meetupIconForeground)
    self.scrollView.addSubview(meetupIcon)
    
    self.name.frame = CGRect(x: 125, y: 65, width: self.view.frame.size.width - 135, height: 31)
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    self.edgesForExtendedLayout = UIRectEdge()
    name.delegate = self
    name.addTarget(self, action: #selector(MeetupDetailViewController.didTextChange(_:)), for: .editingChanged)
    location.delegate = self
    imgPicker.delegate = self
    descriptonTextView.delegate = self
    
    savedLocations.frame = CGRect(x: 0, y: 0, width: 28, height: 24)
    savedLocations.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    savedLocations.setImage(UIImage(named: "Save"), for: UIControlState())
    savedLocations.addTarget(self, action: #selector(meetupDetailToContacts(_:)), for: .touchUpInside)
    location.rightView = savedLocations
    location.rightViewMode = .unlessEditing
    
    addFriends.backgroundColor = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 0.50)
    addFriends.layer.cornerRadius = 15
    
    expandOptions.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    expandOptions.layer.cornerRadius = 15
    
    checkValidMeetup()
    
    datePicker.alpha = 0
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    datePicker.frame = CGRect(x: meetupIcon.frame.minX, y: location.frame.maxY + 40, width: location.frame.size.width, height: 175)
    datePicker.center.x = self.scrollView.center.x
    self.scrollView.addSubview(datePicker)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    checkValidMeetup()
  }
  
  @IBAction func expandMeetupDetails(_ sender: Any?) {
    self.expandOptions.translatesAutoresizingMaskIntoConstraints = true
    self.addFriends.translatesAutoresizingMaskIntoConstraints = true
    self.name.translatesAutoresizingMaskIntoConstraints = true
    self.location.translatesAutoresizingMaskIntoConstraints = true
    if descriptonTextView.frame.size.height == 0{
      makeExpandedOptionsSubview()
    }
    let titleToBeSet = self.expandOptions.currentTitle == "More" ? "Less" : "More"
    let shift: CGFloat = self.expandOptions.currentTitle == "More" ? 150 : -150
    let alphaShift: CGFloat = self.expandOptions.currentTitle == "More" ? 1 : 0
    
    UIView.animate(withDuration: 0.5, animations: {
      if self.datePicker.alpha == 1 {
        self.flipDatePicker(self)
      }
      self.expandOptions.center.y += shift
      self.expandOptions.setTitle(titleToBeSet, for: UIControlState())
      self.addFriends.center.y += shift
      self.backView.center.y += shift
      self.datePickerButton.alpha = alphaShift
      self.descriptonTextView.alpha = alphaShift
    })
    
  }
  
  func makeExpandedOptionsSubview() {
    backView = UIView(frame: CGRect(x: 0,y: expandOptions.frame.minY + 150,width: self.view.frame.size.width,height: self.view.frame.maxY - expandOptions.frame.minY))
    backView.backgroundColor = self.view.backgroundColor
    self.scrollView.insertSubview(backView, belowSubview: self.addFriends)
    datePickerButton = UIButton(frame: CGRect(x: self.location.frame.minX,y: 168,width: self.location.frame.size.width - 30,height: 30))
    datePickerButton.backgroundColor = UIColor.white
    datePickerButton.layer.cornerRadius = 5
    datePickerButton.layer.borderColor = UIColor.lightGray.cgColor
    datePickerButton.layer.borderWidth = 1
    datePickerButton.setTitle("Time of Meetup", for: UIControlState())
    datePickerButton.setTitleColor(MAIN_COLOR, for: UIControlState())
    datePickerButton.addTarget(self, action: #selector(flipDatePicker(_:)), for: .touchUpInside)
    self.scrollView.addSubview(datePickerButton)
    dateClearButton = UIButton(frame: CGRect(x: self.location.frame.size.width-7,y: self.location.frame.maxY,width: 30,height: 30))
    dateClearButton.setImage(UIImage(named: "Exit"), for: UIControlState())
    dateClearButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    dateClearButton.addTarget(self, action: #selector(clearDate(_:)), for: .touchUpInside)
    self.view.addSubview(dateClearButton)
    dateClearButton.isEnabled = true
    descriptonTextView.frame = CGRect(x: 22 , y: 210, width: self.view.frame.size.width - 32, height: 100)
    descriptonTextView.layer.cornerRadius = 5
    descriptonTextView.font = UIFont(name: "Helvetica", size: 14)
    descriptonTextView.text = "Meetup information you want everyone to always have on hand."
    descriptonTextView.textColor = UIColor.lightGray
    self.scrollView.insertSubview(descriptonTextView, belowSubview: self.backView)
  }
  
  func flipDatePicker(_ sender: Any?) {
    self.scrollView.endEditing(true)
    let date = datePicker.date
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    let DateInFormat = dateFormatter.string(from: date)
    datePickerButton.setTitle(DateInFormat, for: UIControlState())
    let shift: CGFloat = datePicker.alpha == 0 ? 175 : -175
    let alpha: CGFloat = datePicker.alpha == 0 ? 1 : 0
    let pickerShift: CGFloat = datePicker.alpha == 0 ? 0 : -30
    UIView.animate(withDuration: 0.5, animations: {
      self.datePicker.alpha = alpha
      self.backView.center.y += shift
      self.descriptonTextView.center.y += shift
      self.expandOptions.center.y += shift
      self.addFriends.center.y += shift
      self.datePickerButton.frame = CGRect(x: self.location.frame.minX,y: 168,width: self.location.frame.size.width + pickerShift,height: 30)
    })
    dateClearButton.isHidden = datePicker.alpha != 0
  }
  
  func clearDate(_ sender: Any?) {
    datePickerButton.setTitle("Time of Meetup", for: UIControlState())
    dateClearButton.isHidden = true
  }
  
  func updateMeetup() {
    realm.beginWrite()
    meetup.name = name.text!
    meetup.locationName = location.text
    print(descriptonTextView.text)
    if descriptonTextView.text != "Meetup information you want everyone to always have on hand." {
      meetup.details = descriptonTextView.text
    }
    else {
      meetup.details = "Add some details about your meetup that friends might need like where to park, what to bring, and any other special considerations."
    }
    if datePickerButton.titleLabel?.text != "Time of Meetup" {
      meetup.timeOfMeetup = datePicker.date
    }
    if let image = meetupIcon.currentBackgroundImage {
      self.meetup.meetupIcon = UIImagePNGRepresentation(image)
    }
    try! realm.commitWrite()
  }
  
  func loadFromList() {
    //        if !newMeetup {
    //            name?.text = meetup.meetupName ?? ""
    //            location?.text = meetup.desc ?? ""
    //            if meetup.meetupIcon != nil {
    //                meetupIcon.setBackgroundImage(UIImage(data:meetup.meetupIcon!, scale: 1.0), forState: .Normal)
    //            }
    //        }
    //        else if meetup == nil{
    //            meetup = Meetup()
    //        }
    //        guard let meetup = meetup else {
    //            meetup = Meetup()
    //            return
    //        }
  }
  
  func didTextChange(_ textField: UITextField) {
    checkValidMeetup()
  }
  
  func updateMeetupDictionary(){
    updateMeetup()
    meetupDict["strings"]?["meetupName"] = meetup.name as Any?
    meetupDict["strings"]?["details"] = meetup.details as Any?
    meetupDict["strings"]?["locationName"] = meetup.locationName as Any?
    meetupDict["strings"]?["locationAddress"] = meetup.locationAddress as Any?
    // meetupDict["strings"]!["timeOfMeetup"] =
    
    meetupDict["location"]?["latitude"] = meetup.locationLatitude as Any?
    meetupDict["location"]?["longitude"] = meetup.locationLongitude as Any?
  }
  
  //When the user exits the text field, the textfield now holds what they entered: static until further changed.
  func textFieldDidEndEditing(_ textField: UITextField) {
    checkValidMeetup()
    switch textField.tag {
    case 0:
      name.text = textField.text
      checkValidMeetup()
    case 1:
      location.text = textField.text
      checkValidMeetup()
    default:
      break
    }
  }
  
  func checkValidMeetup(){
    if name.text != "" {
      done.isEnabled = true
      addFriends.isEnabled = true
      addFriends.backgroundColor = MAIN_COLOR
    }
    else {
      done.isEnabled = false
      addFriends.isEnabled = false
      addFriends.backgroundColor = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 0.50)
    }
  }
  
  //When the user presses enter/return, the cursor jumps to the next text field based on its tag.
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    let nextTage = textField.tag+1;
    // Try to find next responder
    let nextResponder=textField.superview?.viewWithTag(nextTage) as UIResponder!
    
    if (nextResponder != nil){
      // Found next responder, so set it.
      nextResponder?.becomeFirstResponder()
    }
    else
    {
      // Not found, so remove keyboard
      textField.resignFirstResponder()
    }
    return false // We do not want UITextField to insert line-breaks.
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let imageView = UIImageView()
    if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
      self.meetupIconForeground.removeFromSuperview()
      imageView.image = pickedImage
      let shortSide = imageView.image!.size.height > imageView.image!.size.width ? imageView.image!.size.width : imageView.image!.size.height
      imageView.image = MapViewController.croppIngimage(imageView.image!, toRect: CGRect(x: 0, y: 0, width: shortSide, height: shortSide))
      let radius: Float = Float(imageView.image!.size.height/2)
      meetupIcon.setBackgroundImage(MapViewController.maskRoundedImage(imageView.image!, radius: radius), for: UIControlState())
      self.meetup.meetupIcon = UIImagePNGRepresentation(MapViewController.maskRoundedImage(imageView.image!, radius: radius))
    }
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToSavedLocations" {
      (segue.destination as! SavedLocationsViewController).delegate = self
    }
    else if segue.identifier == "NewMeetupToAddFriends" {
      updateMeetup()
      let viewController = segue.destination as! MeetupContactSelectionViewController
      viewController.meetup = meetup
      viewController.previousContacts = Set(self.meetup.contacts)
      viewController.previousGroups = Set(self.meetup.groups)
      print(viewController.previousGroups)
    }
    
  }
  
  func selectIcon(_ sender: UIButton) {
    imgPicker.allowsEditing = true
    imgPicker.sourceType = .photoLibrary
    
    present(imgPicker, animated: true, completion: nil)
  }
  
  func meetupDetailToContacts(_ segue: UIStoryboardSegue) {
    self.performSegue(withIdentifier: "ToSavedLocations", sender: self)
  }
  
  @IBAction func done(_ sender: AnyObject) {
    if done.isEnabled {
      
      updateMeetupDictionary()
      let urlGroup = meetupDict["strings"]!["uniqueID"] as! String
      HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: urlGroup, data: meetupDict as NSDictionary, completionHandler: {returnDict in
        if returnDict["serverCode"] as! Int == 200 {
          let storyboard = UIStoryboard(name: "Meetup", bundle: nil)
          let viewController = storyboard.instantiateViewController(withIdentifier: "MeetupChat") as! MeetupChatViewController
          viewController.meetup = self.meetup
          let navController = self.navigationController
          _ = self.navigationController?.popToRootViewController(animated: false)
          navController?.pushViewController(viewController, animated: true)
        }
        else if returnDict["serverCode"] as! Int == 400 {
          let alertController = UIAlertController(title: nil, message:
            "Error communicating with server.", preferredStyle: UIAlertControllerStyle.alert)
          alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default,handler: nil))
          self.present(alertController, animated: true, completion: nil)
        }
      })
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension MeetupDetailViewController: SavedLocationsViewControllerDelegate {
  func updateLocationField(_ location: SavedLocation) {
    print(location)
    self.savedLocation = location
    self.name.text = self.name.text!.isEmpty ? location.locationName + " Meetup" : self.name.text
    self.location.text = self.savedLocation?.locationName
    self.meetup.locationLongitude = location.longitude
    self.meetup.locationLatitude = location.latitude
    self.meetup.locationName = location.locationName
    self.meetup.locationAddress = location.locationAddress
  }
}

extension MeetupDetailViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Meetup information you want everyone to always have on hand."
      textView.textColor = UIColor.lightGray
    }
  }
  
  func dismissKeyboard(_ sender: AnyObject) {
    self.view.endEditing(true)
  }
}
