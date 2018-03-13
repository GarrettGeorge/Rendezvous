//
//  UsernameViewController.swift
//  Rendezvous
//
//  Created by Admin on 7/13/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class UsernameViewController: UIViewController, UINavigationControllerDelegate {
  
  
  @IBOutlet var userPhoto: UIButton!
  @IBOutlet var usernameField: UITextField!
  @IBOutlet var nextButton: UIButton!
  @IBOutlet var alreadyAccountLabel: UILabel!
  @IBOutlet var backToSignIn: UIButton!
  
  var uniqueUsernameIcon = UIButton()
  var usernameErrorAlert = UILabel()
  
  var facebook_id: String?
  
  let imgPicker = UIImagePickerController()
  var userImage: UIImage?
  
  var fullName: String?
  var verificationMethod: String!
  var password: String!
  var profilePictureURL: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBackground")!)
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    imgPicker.delegate = self
    
    userPhoto.addTarget(self, action: #selector(callImgPicker(_:)), for: .touchUpInside)
    
    uniqueUsernameIcon.frame = CGRect(x: -3, y: 0, width: 25, height: 25)
    uniqueUsernameIcon.setImage(UIImage(named: "IsNotUnique"), for: UIControlState())
    uniqueUsernameIcon.addTarget(self, action: #selector(showUsernameUniquenessAlert(_:)), for: .touchUpInside)
    
    usernameField.addTarget(self, action: #selector(dismissUsernameFailedAlert(_:)), for: .editingDidBegin)
    usernameField.addTarget(self, action: #selector(updateNextButton(_:)), for: .editingChanged)
    usernameField.rightView = UIView(frame: CGRect(x: usernameField.frame.size.width - 30,y: 0,width: 25,height: 25))
    usernameField.rightView?.addSubview(uniqueUsernameIcon)
    usernameField.rightViewMode  = .unlessEditing
    usernameField.rightView?.isHidden = true
    usernameField.layer.cornerRadius = 5
    usernameField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
    usernameField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: usernameField.frame.size.height))
    usernameField.leftViewMode = .always
    
    nextButton.backgroundColor = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
    nextButton.setTitleColor(UIColor.white, for: UIControlState())
    nextButton.layer.cornerRadius = 5
    nextButton.isEnabled = false
    nextButton.alpha = 0.50
    
    alreadyAccountLabel.textColor = UIColor.white
    backToSignIn.tintColor = UIColor.white
    backToSignIn.addTarget(self, action: #selector(backToSignIn(_:)), for: .touchUpInside)
    
    if profilePictureURL != nil {
      userPhoto.setTitle(nil, for: UIControlState())
      if let url = URL(string: profilePictureURL!) {
        if let data = try? Data(contentsOf: url) {
          userPhoto.setBackgroundImage(UIImage(data: data), for: UIControlState())
        }
      }
    }
  }
  
  override func viewDidLayoutSubviews() {
    usernameErrorAlert.frame = CGRect(x: usernameField.frame.minX, y: usernameField.frame.maxY + 3, width: usernameField.frame.size.width, height: 25)
    usernameErrorAlert.backgroundColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
    usernameErrorAlert.clipsToBounds = true
    usernameErrorAlert.layer.cornerRadius = 5
    usernameErrorAlert.text = "Username already in use."
    usernameErrorAlert.textAlignment = .center
    usernameErrorAlert.textColor = UIColor.white
    usernameErrorAlert.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightLight)
    usernameErrorAlert.adjustsFontSizeToFitWidth = true
    usernameErrorAlert.alpha = 0
    self.view.addSubview(usernameErrorAlert)
  }
  
  func checkUsernameUniqueness(_ completionHandler: @escaping (_ returnBool: Bool) -> Void) {
    self.view.endEditing(true)
    // GET request to query the database for potential
    // instances of the desired username
    HTTPRequestManager.sharedInstance.makeHTTPGETCall("username", op: "eq", value: usernameField.text!, completionHandler: {returnDict in
      // Desired username not currently associated
      // with a user account
      let convertedDict = returnDict["convertedDict"] as? [String: Any]
      if returnDict["serverCode"] as! Int == 200 {
        if convertedDict?["num_results"] as! Int == 0 {
          DispatchQueue.main.async(execute: {
            self.dismissUsernameFailedAlert(self)
            self.usernameField.rightView?.isHidden = true
          })
          completionHandler(true)
        }
        else {
          DispatchQueue.main.async(execute: {
            self.usernameField.rightView?.isHidden = false
          })
          completionHandler(false)
        }
      }
        // Request/Server communication error
      else if returnDict["serverCode"] as! Int == 400 {
        DispatchQueue.main.async(execute: {
          let alertController = UIAlertController(title: nil, message:
            "Error communicating with server.", preferredStyle: UIAlertControllerStyle.alert)
          alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default,handler: nil))
          self.present(alertController, animated: true, completion: nil)
        })
        completionHandler(false)
      }
    })
  }
  
  func showUsernameUniquenessAlert(_ sender: AnyObject) {
    if usernameErrorAlert.alpha != 1 {
      UIView.animate(withDuration: 0.25, animations: {
        self.usernameErrorAlert.alpha = 1
        self.nextButton.center.y += 25
      })
    }
  }
  
  func dismissUsernameFailedAlert(_ sender: AnyObject) {
    if usernameErrorAlert.alpha != 0 {
      UIView.animate(withDuration: 0.25, animations: {
        self.usernameErrorAlert.alpha = 0
        self.nextButton.center.y -= 25
      })
    }
    
  }
  
  func updateNextButton(_ sender: AnyObject) {
    if usernameField.text != "" {
      nextButton.alpha = 1
      nextButton.isEnabled = true
    }
    else {
      nextButton.alpha = 0.5
      nextButton.isEnabled = false
    }
  }
  
  func dismissKeyboard(_ sender: AnyObject) {
    if usernameField.text == "" {
      usernameField.rightView?.isHidden = true
    }
    self.view.endEditing(true)
  }
  
  /*
   // MARK: - Navigation
   */
  @IBAction func finishSignUp(_ sender: AnyObject) {
    checkUsernameUniqueness({ returnBool in
      if returnBool {
        let userDict = [
          "full_name": self.fullName ?? "",
          "facebook_id": self.facebook_id ?? "",
          "username": self.usernameField.text!,
          "phone_number": self.verificationMethod,
          "email": "",
          "password": self.password ?? ""
          ] as [String : Any]
        /*if let image = self.userImage {
         let imageData = UIImageJPEGRepresentation(image, 0.5)
         let base64String = imageData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
         userDict["image"] = ["content_type": "image/jpeg", "filename":"test.jpg", "file_data": base64String]
         }*/
        
        // Officially create a new user instance in the users database
        HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "register", data: userDict as NSDictionary, completionHandler: {returnDict in
          let convertedDict = returnDict["convertedDict"] as? [String: Any]
          if returnDict["serverCode"] as! Int == 200 {
            // Adds email/phone number to keychain for quick login
            
            // Checks if account information is already stored in the keychain
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            // If there is already information stored remove it
            if !hasLoginKey {
              let removeAll: Bool = KeychainWrapper.standard.removeAllKeys()
              if !removeAll {
                print("Keychain removal failed")
              }
            }
            // Adds email/phone and password to keychain and sets hasLoginKey to true if successful
            if self.facebook_id == nil {
              _ = KeychainWrapper.standard.set(self.usernameField.text!, forKey: "username")
              _ = KeychainWrapper.standard.set(self.verificationMethod, forKey: "verfification")
              _ = KeychainWrapper.standard.set(self.password, forKey: "password")
            }
            else {
              _ = KeychainWrapper.standard.set(self.facebook_id!, forKey: "facebook_id")
            }
            if self.fullName != nil {
              _ = KeychainWrapper.standard.set(self.fullName!, forKey: "display_name")
            }
            else {
              _ = KeychainWrapper.standard.set(self.usernameField.text!, forKey: "display_name")
            }
            
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            UserDefaults.standard.synchronize()
            
            _ = KeychainWrapper.standard.set(String(convertedDict?["id"] as! Int), forKey: "user_id")
            // takes user to main viewController
            var authDict = ["username": KeychainWrapper.standard.string(forKey: "username") ?? "", "password": KeychainWrapper.standard.string(forKey: "password") ?? ""]
            if self.facebook_id != nil {
              authDict = ["facebook_id": self.facebook_id!]
            }
            HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url:"auth", data: authDict as NSDictionary, completionHandler: { returnDict in
              if returnDict["serverCode"] as! Int == 400 {
                DispatchQueue.main.async {
                  let alertController = UIAlertController(title: "Auth Token Error", message:
                    "Failed to get an auth token. Try again.", preferredStyle: UIAlertControllerStyle.alert)
                  alertController.addAction(UIAlertAction(title: "Try again", style: .default,handler: { (UIAlertAction) in
                    UserDefaults.standard.set(false, forKey: "hasLoginKey")
                    let m = FBSDKLoginManager()
                    m.logOut()
                    _ = self.navigationController?.popToRootViewController(animated: true)
                  }))
                  
                  self.present(alertController, animated: true, completion: nil)
                }
              }
              else if returnDict["serverCode"] as! Int == 200 {
                print(convertedDict?["access_token"] as! String)
                _ = KeychainWrapper.standard.set(convertedDict?["access_token"] as! String, forKey: "access_token")
                DispatchQueue.main.async {
                  let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
                  let tabBarController = storyboard.instantiateInitialViewController()
                  self.present(tabBarController!, animated: true, completion: nil)
                }
              }
            })
          }
          else if returnDict["serverCode"] as! Int == 400 {
            DispatchQueue.main.async(execute: {
              let alertController = UIAlertController(title: "Account Creation Error", message:
                "Failed to create a Rendezvous account with your information. Try again.", preferredStyle: UIAlertControllerStyle.alert)
              alertController.addAction(UIAlertAction(title: "Try again", style: .default,handler: nil))
              
              self.present(alertController, animated: true, completion: nil)
            })
          }
          print(returnDict)
        })
        
      }
    })
  }
  
  func backToSignIn(_ sender: AnyObject) {
    UserDefaults.standard.set(false, forKey: "hasLoginKey")
    let m = FBSDKLoginManager()
    m.logOut()
    _ = KeychainWrapper.standard.removeAllKeys()
    _ = self.navigationController?.popToRootViewController(animated: true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension UsernameViewController: UIImagePickerControllerDelegate {
  func callImgPicker(_ sender: UIButton) {
    imgPicker.sourceType = .photoLibrary
    imgPicker.allowsEditing = true
    present(imgPicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
      userImage = image
      userPhoto.setBackgroundImage(image, for: UIControlState())
      userPhoto.setTitle(nil, for: UIControlState())
    }
    dismiss(animated: true, completion: nil)
  }
}
