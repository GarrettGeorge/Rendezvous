//
//  ContactDetailViewController.swift
//  Rendezvous
//
//  Created by Admin on 7/8/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
  
  var contact: Contact?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.edgesForExtendedLayout = UIRectEdge()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
