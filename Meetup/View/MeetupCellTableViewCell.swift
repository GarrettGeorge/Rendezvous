//
//  MeetupCellTableViewCell.swift
//  Rendezvous
//
//  Created by Admin on 4/27/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class MeetupCellTableViewCell: MGSwipeTableCell {
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var groupListLabel: UILabel!
  @IBOutlet var meetupIcon: UIImageView!
  @IBOutlet var groupIcon: UIImageView!
  @IBOutlet var lastMessageLabel: UILabel!
  
  
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
