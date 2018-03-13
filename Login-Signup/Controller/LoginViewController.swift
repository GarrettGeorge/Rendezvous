//
//  LoginViewController.swift
//  Rendezvous
//
//  Created by Admin on 5/18/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UINavigationControllerDelegate {
  
  @IBOutlet var logo: UILabel!
  @IBOutlet var userNameField: UITextField!
  @IBOutlet var passwordField: UITextField!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var noAccLabel: UILabel!
  @IBOutlet var signUp: UIButton!
  @IBOutlet var activityView: UIActivityIndicatorView!
  
  var fbLogin = FBSDKLoginButton()
  
  var realm: Realm!
  
  var facebookid: String?
  var userName: String?
  var userEmail: String?
  
  let originalY: CGFloat = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    realm = try! Realm()
    
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBackground")!)
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    logo.font = UIFont(name: "HelveticaNeue-UltraLight", size: 50)
    logo.textColor = UIColor.white
    
    userNameField.layer.cornerRadius = 5
    userNameField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
    userNameField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: userNameField.frame.size.height))
    userNameField.leftViewMode = .always
    userNameField.delegate = self
    
    passwordField.layer.cornerRadius = 5
    passwordField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
    passwordField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: passwordField.frame.size.height))
    passwordField.leftViewMode = .always
    passwordField.delegate = self
    
    loginButton.backgroundColor = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
    loginButton.tintColor = UIColor.white
    loginButton.layer.cornerRadius = 5
    
    let borderView = UIView(frame: CGRect(x: 40,y: loginButton.frame.maxY - 5,width: self.view.frame.size.width - 80, height: 1))
    borderView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
    self.view.addSubview(borderView)
    
    activityView.isHidden = true
    activityView.hidesWhenStopped = true
    
    noAccLabel.textColor = UIColor.white
    
    signUp.tintColor = UIColor.white
  }
  
  override func viewDidLayoutSubviews() {
    fbLogin.frame = CGRect(x: loginButton.frame.minX, y: loginButton.frame.maxY + 21, width: loginButton.frame.size.width, height: 42)
    fbLogin.readPermissions = ["public_profile", "email", "user_friends"]
    fbLogin.delegate = self
    self.view.addSubview(fbLogin)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    // Checks if a current Facebook Access token exists, if so skip Login
    /*if FBSDKAccessToken.currentAccessToken() != nil || NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey") {
     let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
     let tabBarController = storyboard.instantiateInitialViewController()
     self.presentViewController(tabBarController!, animated: true, completion: nil)
     }*/
  }
  
  func dismissKeyboard(_ sender: AnyObject) {
    self.view.endEditing(true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // Checks credentials with those stored in the Keychain
  // for non network logins
  
  // MARK: Navigation
  
  @IBAction func login(_ sender: AnyObject) {
    dismissKeyboard(self)
    let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
    let tabBarController = storyboard.instantiateInitialViewController()
    self.present(tabBarController!, animated: true, completion: nil)
    /*HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "auth", data: ["username": KeychainWrapper.standard.stringForKey("username") ?? "", "password": KeychainWrapper.standard.stringForKey("password") ?? ""], completionHandler: { returnDict in
     if returnDict["serverCode"] as! Int == 200 {
     _ = KeychainWrapper.standard.setString(returnDict["convertedDict"]!["access_token"] as! String, forKey: "access_token")
     _ = KeychainWrapper.standard.setString(returnDict["convertedDict"]!["unique_id"] as! String, forKey: "unique_id")
     _ = KeychainWrapper.standard.setString(self.userNameField.text!, forKey: "username")
     _ = KeychainWrapper.standard.setString(self.passwordField.text!, forKey: "password")
     NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
     NSUserDefaults.standardUserDefaults().synchronize()
     dispatch_async(dispatch_get_main_queue(), {
     let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
     let tabBarController = storyboard.instantiateInitialViewController()
     self.presentViewController(tabBarController!, animated: true, completion: nil)
     })
     }
     else if returnDict["serverCode"] as! Int == 401 {
     dispatch_async(dispatch_get_main_queue(), {
     let alertController = UIAlertController(title: "Incorrect Username or Password", message:
     "The information you entered is incorrect. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
     alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default,handler: nil))
     self.presentViewController(alertController, animated: true, completion: nil)
     })
     }
     else if returnDict["serverCode"] as! Int == 404 {
     dispatch_async(dispatch_get_main_queue(), {
     let alertController = UIAlertController(title: "Server Error", message:
     "Error communicating with server. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
     alertController.addAction(UIAlertAction(title: "Dismiss.", style: UIAlertActionStyle.Default,handler: nil))
     self.presentViewController(alertController, animated: true, completion: nil)
     })
     }
     })*/
  }
}

extension LoginViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // shift up
    if self.view.frame.origin.y == 0.0 {
      UIView.animate(withDuration: 0.1, animations: {
        self.view.frame.origin.y -= 50
      })
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    // shift down
    UIView.animate(withDuration: 0.1, animations: {
      self.view.frame.origin.y = 0.0
    })
  }
}

extension LoginViewController: FBSDKLoginButtonDelegate {
  func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
    return true
  }
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) { activityView.isHidden = false
    activityView.startAnimating()
    if result.isCancelled {
      activityView.stopAnimating()
    }
    returnUserData({ (id,name,email,profilePictureURL) in
      // Check to see if facebookID is already associated with a user account
      HTTPRequestManager.sharedInstance.makeHTTPGETCall("facebook_id", op: "eq", value: id!, completionHandler: {returnDict in
        let serverDict = returnDict["convertedDict"] as? [String: Any]
        if returnDict["serverCode"] as! Int == 200 {
          print(serverDict?["num_results"] as! Int)
          if serverDict?["num_results"] as! Int != 0 {
            HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "auth", data: ["facebook_id": id!], completionHandler: { returnDict in
              if returnDict["serverCode"] as! Int == 200 {
                DispatchQueue.main.async(execute: {
                  _ = KeychainWrapper.standard.set(serverDict?["access_token"] as! String, forKey: "access_token")
                  _ = KeychainWrapper.standard.set(id!, forKey: "facebook_id")
                  _ = KeychainWrapper.standard.set(name ?? "User", forKey: "display_name")
                  self.activityView.stopAnimating()
                  let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
                  let tabBarController = storyboard.instantiateInitialViewController()
                  self.present(tabBarController!, animated: true, completion: nil)
                })
              }
              else if returnDict["serverCode"] as! Int == 404 {
                DispatchQueue.main.async(execute: {
                  let alertController = UIAlertController(title: "Server Error", message:
                    "Error communicating with server. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                  alertController.addAction(UIAlertAction(title: "Dismiss.", style: UIAlertActionStyle.default,handler: nil))
                  self.present(alertController, animated: true, completion: nil)
                })
              }
            })
            
          }
          else if serverDict?["num_results"] as! Int == 0 {
            DispatchQueue.main.async(execute: {
              self.activityView.stopAnimating()
              // Push to username creation
              let storyboard = UIStoryboard(name: "LoginEntryViews", bundle: nil)
              let viewController = storyboard.instantiateViewController(withIdentifier: "Username") as!UsernameViewController
              // Get account unique ID for future PATCH request with username
              viewController.facebook_id = id
              viewController.profilePictureURL = profilePictureURL
              viewController.fullName = name
              viewController.verificationMethod = "Facebook"
              self.navigationController?.pushViewController(viewController, animated: true)
            })
          }
        }
          // Else, set up for new account creation
        else if returnDict["serverCode"] as! Int == 404 {
          print("server error")
          let m = FBSDKLoginManager()
          m.logOut()
          DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: "Server Error", message:
              "Error communicating with server. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss.", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
          })
        }
      })
      
      self.activityView.stopAnimating()
    })
  }
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    
  }
  
  func returnUserData(_ completionHandler:@escaping (_ id: String?, _ name: String?, _ email: String?, _ profilePictureURL: String?)->Void) {
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: ["fields": "id, name, email, picture.type(large), friends"])
    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
      if connection != nil {
        if error != nil {
          // Process error
          print("Error: \(error)")
        }
        else {
          if let fbDict = result as? [String : Any] {
            let id = fbDict["id"] as? String
            let name = fbDict["name"] as? String
            let email = fbDict["email"] as? String
            if let profilePictureURL = fbDict["picture"] as? [String : Any] {
              if let profilePictureData = profilePictureURL["data"] as? [String : Any] {
                if let profilePictureURLString = profilePictureData["url"] as? String {
                  completionHandler(id, name, email, profilePictureURLString)
                }
              }
            }
            completionHandler(id, name, email, nil)
            
          }
        }
        
      }
    })
  }
}
