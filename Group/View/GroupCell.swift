//
//  GroupCell.swift
//  Rendezvous
//
//  Created by Admin on 7/24/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
  
  var photo: UIImageView!
  var label: UILabel!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    photo = UIImageView(image: UIImage(named: "defaultGroupIcon"))
    contentView.addSubview(photo)
    
    label = UILabel(frame: CGRect.zero)
    contentView.addSubview(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    photo.image = UIImage(named: "defaultGroupIcon")
    label.text = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    photo.frame = CGRect(x: 8, y: 7, width: 32, height: 32)
    
    label.frame = CGRect(x: 44, y: 7, width: bounds.width - 50, height: 25)
  }
  
}
