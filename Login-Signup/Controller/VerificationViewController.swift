//
//  VerificationViewController.swift
//  Rendezvous
//
//  Created by Admin on 7/12/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {
  
  
  @IBOutlet var confirmationLabelTitle: UILabel!
  @IBOutlet var confirmationLabelSubtitle: UILabel!
  @IBOutlet var superView: UIView!
  @IBOutlet var confirmationField: UITextField!
  @IBOutlet var nextButton: UIButton!
  var verificationDestinationLabel = UILabel()
  var resendButton = UIButton()
  var verificationDescription: String!
  
  var fullName: String!
  var verificationMethod: String!
  var password: String!
  var confirmationCode: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor(patternImage: UIImage(named: "LoginBackground")!)
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    
    superView.layoutIfNeeded()
    
    confirmationLabelTitle.textColor = UIColor.white
    confirmationLabelSubtitle.textColor = UIColor.white
    verificationDestinationLabel.textColor = UIColor.white
    resendButton.setTitleColor(UIColor.white, for: UIControlState())
    nextButton.backgroundColor = UIColor(red: 50/255, green: 225/255, blue: 165/255, alpha: 1)
    nextButton.setTitleColor(UIColor.white, for: UIControlState())
    nextButton.layer.cornerRadius = 5
    nextButton.isEnabled = false
    nextButton.alpha = 0.50
    nextButton.addTarget(self, action: #selector(checkCodeWithServer(_:)), for: .touchUpInside)
    
    confirmationField.addTarget(self, action: #selector(shouldEnableNext(_:)), for: .editingChanged)
    confirmationField.layer.cornerRadius = 5
    confirmationField.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
    confirmationField.layer.borderWidth = 0
    confirmationField.leftView = UIView(frame: CGRect(x: 0,y: 0,width: 10,height: confirmationField.frame.size.height))
    confirmationField.leftViewMode = .always
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidLayoutSubviews() {
    verificationDestinationLabel.frame = CGRect(x: 0, y: 0, width: superView.frame.size.width / 2 - 2, height: superView.frame.size.height)
    verificationDestinationLabel.textAlignment = .right
    verificationDestinationLabel.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightLight)
    verificationDestinationLabel.text = verificationDescription
    verificationDestinationLabel.textColor = UIColor.white
    self.superView.addSubview(verificationDestinationLabel)
    
    resendButton.frame = CGRect(x: superView.frame.size.width / 2 + 2, y: 0, width: superView.frame.size.width / 2 - 2, height: superView.frame.size.height)
    resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightLight)
    resendButton.setTitle("Resend Code.", for: UIControlState())
    resendButton.setTitleColor(UIColor.white, for: UIControlState())
    self.superView.addSubview(resendButton)
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    confirmationField.text = nil
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  func dismissKeyboard(_ sender: AnyObject) {
    self.view.endEditing(true)
  }
  
  func shouldEnableNext(_ sender: AnyObject) {
    if confirmationField.text?.characters.count == 6 {
      nextButton.isEnabled = true
      nextButton.alpha = 1
    }
    else {
      nextButton.isEnabled = false
      nextButton.alpha = 0.50
    }
  }
  
  func checkCodeWithServer(_ sender: AnyObject) {
    if confirmationField.text! == confirmationCode {
      self.performSegue(withIdentifier: "toUsername", sender: self)
    }
    else {
      let alertController = UIAlertController(title: nil, message:
        "Incorrect confirmation code. Please try again or resend.", preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default,handler: nil))
      self.present(alertController, animated: true, completion: nil)
      
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toUsername" {
      let viewController = segue.destination as! UsernameViewController
      viewController.fullName = fullName
      viewController.verificationMethod = verificationMethod
      viewController.password = password
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
}
