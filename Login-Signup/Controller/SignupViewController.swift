//
//  SignupViewController.swift
//  Rendezvous
//
//  Created by Admin on 5/19/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
  
  
  @IBOutlet var logo: UILabel!
  @IBOutlet var fullNameField: UITextField!
  @IBOutlet var verificationField: UITextField!
  @IBOutlet var passwordField: UITextField!
  @IBOutlet var signup: UIButton!
  @IBOutlet var signInLabel: UILabel!
  @IBOutlet var signInButton: UIButton!
  @IBOutlet var activity: UIActivityIndicatorView!
  
  var verificationError = UIButton()
  
  let passwordError = UIButton()
  
  let uniquenessAlert = UIButton()
  var isUnique: Bool = false
  
  var verificationErrorAlert = UILabel()
  var passwordErrorAlert = UILabel()
  
  let signupFailureAlert = UILabel()
  
  fileprivate var user: [String: NSString] = ["email": "", "phone_number": ""]
  fileprivate var confirmationCode: String!
  
  let MAIN_COLOR = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
  let ALERT_COLOR = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    
    self.navigationController?.isNavigationBarHidden = true
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBackground")!)
    
    logo.font = UIFont(name: "HelveticaNeue-UltraLight", size: 50)
    logo.textColor = UIColor.white
    
    fullNameField.delegate = self
    fullNameField.layer.cornerRadius = 5
    fullNameField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
    fullNameField.delegate = self
    fullNameField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: self.fullNameField.frame.size.height))
    fullNameField.leftViewMode = .always
    
    verificationField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
    verificationError.setImage(UIImage(named: "IsNotUnique"), for: UIControlState())
    verificationError.addTarget(self, action: #selector(showVerificationFieldErrorAlert(_:)), for: .touchUpInside)
    verificationError.frame = CGRect(x: -3, y: 0, width: 25, height: 25)
    
    verificationField.delegate = self
    verificationField.layer.cornerRadius = 5
    verificationField.rightViewMode = .unlessEditing
    verificationField.addTarget(self, action: #selector(shouldEnableNext(_:)), for: .editingChanged)
    verificationField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: self.verificationField.frame.size.height))
    verificationField.leftViewMode = .always
    
    passwordError.frame = CGRect(x: -3, y: 0, width: 25, height: 25)
    passwordError.setImage(UIImage(named: "IsNotUnique"), for: UIControlState())
    passwordError.addTarget(self, action: #selector(showPasswordFieldErrorAlert(_:)), for: .touchUpInside)
    passwordError.isHidden = true
    
    passwordField.delegate = self
    passwordField.layer.cornerRadius = 5
    passwordField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
    passwordField.addTarget(self, action: #selector(shouldEnableNext(_:)), for: .editingChanged)
    passwordField.rightViewMode = .unlessEditing
    passwordField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: self.passwordField.frame.height))
    passwordField.leftViewMode = .always
    
    signup.backgroundColor = MAIN_COLOR
    signup.alpha = 0.50
    signup.isEnabled = false
    signup.tintColor = UIColor.white
    signup.layer.cornerRadius = 5
    
    signInLabel.textColor = UIColor.white
    
    signInButton.tintColor = UIColor.white
    
    verificationField.addSubview(uniquenessAlert)
    uniquenessAlert.isHidden = true
    
    activity.hidesWhenStopped = true
    
    verificationErrorAlert.backgroundColor = ALERT_COLOR
    verificationErrorAlert.clipsToBounds = true
    verificationErrorAlert.layer.cornerRadius = 5
    verificationErrorAlert.text = "Invalid Email or Phone number."
    verificationErrorAlert.textAlignment = .center
    verificationErrorAlert.textColor = UIColor.white
    verificationErrorAlert.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightLight)
    verificationErrorAlert.alpha = 0
    self.view.addSubview(verificationErrorAlert)
    
    passwordErrorAlert.backgroundColor = ALERT_COLOR
    passwordErrorAlert.clipsToBounds = true
    passwordErrorAlert.layer.cornerRadius = 5
    passwordErrorAlert.text = "Password must be at least 8 characters."
    passwordErrorAlert.textAlignment = .center
    passwordErrorAlert.textColor = UIColor.white
    passwordErrorAlert.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightLight)
    passwordErrorAlert.adjustsFontSizeToFitWidth = true
    passwordErrorAlert.alpha = 0
    self.view.addSubview(passwordErrorAlert)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    passwordField.text = nil
    super.viewDidDisappear(animated)
  }
  override func viewDidLayoutSubviews() {
    verificationErrorAlert.frame = CGRect(x: verificationField.frame.minX, y: verificationField.frame.maxY + 3, width: verificationField.frame.width, height: 25)
    
    passwordErrorAlert.frame = CGRect(x: passwordField.frame.minX, y: passwordField.frame.maxY + 3, width: passwordField.frame.width, height: 25)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
    // Dispose of any resources that can be recreated.
  }
  
  func dismissKeyboard(_ sender: AnyObject) {
    self.view.endEditing(true)
  }
  
  // Verification Field specific methods
  func showVerificationFieldErrorAlert(_ sender: AnyObject) {
    if verificationErrorAlert.alpha != 1 {
      UIView.animate(withDuration: 0.25, animations: {
        self.verificationErrorAlert.alpha = 1
        self.passwordField.center.y += 25
        self.signup.center.y += 25
        if self.passwordErrorAlert.alpha != 0 {
          self.passwordErrorAlert.center.y += 25
        }
      })
    }
  }
  
  func collapseVerificationFieldErrorAlert() {
    UIView.animate(withDuration: 0.25, animations: {
      self.verificationErrorAlert.alpha = 0
      self.passwordField.center.y -= 25
      self.signup.center.y -= 25
      if self.passwordErrorAlert.alpha != 0 {
        self.passwordErrorAlert.center.y -= 25
      }
    })
  }
  
  func shouldShowVerificationFieldError(_ shouldShow: Bool) {
    if shouldShow {
      verificationField.rightView = UIView(frame: CGRect(x: self.verificationField.frame.maxX - 30,y: 0,width: 25,height: 25))
      verificationField.rightView?.addSubview(verificationError)
    }
    else {
      verificationField.rightView = nil
    }
  }
  
  
  func updateUserDictionary() {
    if validatePhoneNumber(verificationField.text!) {
      user["phone_number"] = verificationField.text! as NSString?
    }
    else {
      user["email"] = verificationField.text! as NSString?
    }
  }
  
  // Password Field specific methods
  func showPasswordFieldErrorAlert(_ sender: AnyObject) {
    if passwordErrorAlert.alpha != 1 {
      passwordErrorAlert.frame = CGRect(x: passwordField.frame.minX, y: passwordField.frame.maxY + 3, width: passwordField.frame.width, height: 25)
      UIView.animate(withDuration: 0.25, animations: {
        self.passwordErrorAlert.alpha = 1
        self.signup.center.y += 25
      })
    }
  }
  
  func collapsePasswordFieldErrorAlert() {
    passwordErrorAlert.frame = CGRect(x: passwordField.frame.minX, y: passwordField.frame.maxY + 3, width: passwordField.frame.width, height: 25)
    UIView.animate(withDuration: 0.25, animations: {
      self.passwordErrorAlert.alpha = 0
      self.signup.center.y -= 25
    })
  }
  
  func shouldShowPasswordFieldError(_ shouldShow: Bool) {
    if shouldShow {
      passwordField.rightView = UIView(frame: CGRect(x: self.passwordField.frame.maxX - 30,y: 0,width: 25,height: 25))
      passwordField.rightView?.addSubview(passwordError)
    }
    else {
      passwordField.rightView = nil
    }
  }
  
  
  // HTTP REQUESTS
  
  // Check uniqueness of email/phone
  func checkUniqueness(_ completionHandler: @escaping (_ isUnique: Bool) -> Void) {
    //Determine if verification method is a phone number or email
    let name = validatePhoneNumber(verificationField.text!) ? "phone_number" : "email"
    HTTPRequestManager.sharedInstance.makeHTTPGETCall(name, op: "eq", value: verificationField.text!, completionHandler: {returnDict in
      print(returnDict)
      let convertedDict = returnDict["convertedDict"] as? [String: Any]
      // Email or phone number is unique, i.e. server returned no results
      if convertedDict?["num_results"] as! Int == 0 {
        print("no results")
        completionHandler(true)
      }
        // Email or phone number is already in use, i.e. server returns a user result
      else if convertedDict?["num_results"] as! Int >= 0 {
        print("more than one result")
        completionHandler(false)
      }
      else if returnDict["serverCode"] as! Int == 400 {
        print("auth error")
      }
    })
  }
  
  func shouldEnableNext(_ sender: AnyObject) {
    if validateVerification(verificationField.text ?? "") && validatePassword(passwordField.text ?? "") && verificationField.text != "" {
      signup.alpha = 1
      signup.isEnabled = true
    }
    else {
      signup.alpha = 0.50
      signup.isEnabled = false
    }
  }
  
  func showSignupFailureAlert() {
    UIView.animate(withDuration: 0.25, animations: {
      self.signupFailureAlert.alpha = 1
    })
  }
  
  // MARK: Validation Functions for Sign up
  
  func validateUser() -> Bool {
    if !(validateVerification(verificationField.text ?? "") && validatePassword(passwordField.text ?? "")) {
      // Alert view for current user inputs when invalid
      let alertController = UIAlertController(title: "Incomplete Form", message:
        "All required fields must be filled.", preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
      
      self.present(alertController, animated: true, completion: nil)
      
      return false
    }
    return true
  }
  
  func validateVerification(_ verificationFromField: String) -> Bool {
    return validatePhoneNumber(verificationFromField) || validateEmail(verificationFromField)
  }
  
  func validatePhoneNumber(_ phoneNumberFromField: String) -> Bool {
    let badCharacters = CharacterSet.decimalDigits.inverted
    return phoneNumberFromField.rangeOfCharacter(from: badCharacters) == nil && phoneNumberFromField.characters.count == 10
  }
  
  func validateEmail(_ emailFromField: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    
    // Alert view for invalid email input
    return emailTest.evaluate(with: emailFromField)
  }
  
  func validatePassword(_ pass: String) -> Bool {
    if pass.characters.count >= 8 {
      passwordError.isHidden = true
      passwordField.textColor = UIColor.white
      return true
    }
    passwordError.isHidden = false
    return false
  }
  
  // POST to server for a new user
  @IBAction func signUp(_ sender: AnyObject) {
    updateUserDictionary()
    dismissKeyboard(self)
    activity.startAnimating()
    checkUniqueness({unique in
      self.isUnique = unique
      DispatchQueue.main.async(execute: {
        if !unique {
          self.verificationField.textColor = UIColor.red
          self.verificationErrorAlert.text = "Phone number already in use."
          self.shouldShowVerificationFieldError(true)
          self.uniquenessAlert.isHidden = true
        }
        self.activity.stopAnimating()
      })
      if self.validateUser() && unique {
        // POST to server with user dictionary to tell the server
        // to send a confirmation code via phone#/email
        HTTPRequestManager.sharedInstance.makeHTTPPOSTCall(url: "verify_sms", data: self.user as NSDictionary, completionHandler: { returnDict in
          let convertedDict = returnDict["convertedDict"] as? [String: Any]
          if returnDict["serverCode"] as! Int == 200 {
            // Take the confirmation code from the response dictionary
            // to eventually pass to VerificationViewController in order
            // to reduce network calls.
            self.confirmationCode = convertedDict?["verification_code"] as! String
            print(self.confirmationCode)
            DispatchQueue.main.async(execute: {
              self.performSegue(withIdentifier: "toVerification", sender: self)
            })
          }
          else if returnDict["serverCode"] as! Int == 400 {
            // Alerts the user to a server communication error
            let alertController = UIAlertController(title: nil, message:
              "Error communicating with server. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
          }
        })
      }
    })
  }
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toVerification" {
      let viewController = segue.destination as! VerificationViewController
      viewController.confirmationCode = confirmationCode
      viewController.verificationMethod = verificationField.text!
      viewController.password = passwordField.text!
      viewController.fullName = fullNameField.text ?? ""
      if validatePhoneNumber(verificationField.text!) {
        var desc = verificationField.text!
        desc.insert("-", at: desc.index(desc.startIndex, offsetBy: 3))
        desc.insert("-", at: desc.index(desc.startIndex, offsetBy: 5))
        viewController.verificationDescription = desc + "."
      }
      else {
        viewController.verificationDescription = verificationField.text! + "."
      }
      self.navigationController?.setNavigationBarHidden(true, animated: true)
      
    }
  }
  
  @IBAction func backToSignIn(_ sender: AnyObject) {
    _ = self.navigationController?.popToRootViewController(animated: true)
  }
  
}

extension SignupViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if self.view.frame.origin.y == 0.0 {
      UIView.animate(withDuration: 0.1, animations: {
        self.view.frame.origin.y -= 98
      })
    }
    switch textField.tag {
    case 0:
      break
    case 1:
      if textField.textColor == UIColor.red {
        textField.textColor = UIColor.white
        verificationError.isHidden = false
        collapseVerificationFieldErrorAlert()
      }
    case 2:
      if textField.textColor == UIColor.red {
        textField.textColor = UIColor.black
        passwordError.isHidden = false
        collapsePasswordFieldErrorAlert()
      }
    default:
      break
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    //checkValidContact()
    UIView.animate(withDuration: 0.1, animations: {
      self.view.frame.origin.y = 0.0
    })
    switch textField.tag {
    case 0:
      break
    case 1:
      if validateVerification(textField.text ?? "") || textField.text == ""{
        shouldShowVerificationFieldError(false)
      }
      else {
        verificationField.text = "Invalid Phone number."
        verificationField.textColor = UIColor.red
        shouldShowVerificationFieldError(true)
        uniquenessAlert.isHidden = true
      }
    case 2:
      if validatePassword(textField.text ?? "") || textField.text == ""{
        shouldShowPasswordFieldError(false)
      }
      else {
        passwordField.textColor = UIColor.red
        shouldShowPasswordFieldError(true)
      }
    default:
      break
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let nextTag: NSInteger = textField.tag + 1;
    // Try to find next responder
    if let nextResponder: UIResponder? = textField.superview!.viewWithTag(nextTag){
      nextResponder?.becomeFirstResponder()
    }
    else {
      // Not found, so remove keyboard.
      textField.resignFirstResponder()
    }
    return false // We do not want UITextField to insert line-breaks.
  }
}
