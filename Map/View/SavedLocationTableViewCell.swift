//
//  SavedLocationTableViewCell.swift
//  Rendezvous
//
//  Created by Admin on 7/6/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class SavedLocationTableViewCell: UITableViewCell {
  
  @IBOutlet var locationName: UILabel!
  @IBOutlet var locationAddress: UILabel!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
