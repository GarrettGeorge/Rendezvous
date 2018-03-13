//
//  ContactCell.swift
//  Rendezvous
//
//  Created by Admin on 4/18/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
  
  var photo: UIImageView!
  var label: UILabel!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    photo = UIImageView(image: UIImage(named: "ContactsDefault"))
    photo.layer.cornerRadius = 16
    contentView.addSubview(photo)
    
    label = UILabel(frame: CGRect.zero)
    contentView.addSubview(label)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    photo.image = UIImage(named: "ContactsDefault")
    label.text = nil
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    photo.frame = CGRect(x: 8, y: 7, width: 32, height: 32)
    
    label.frame = CGRect(x: 50, y: 7, width: bounds.width - 50, height: 25)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  
}
