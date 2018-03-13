//
//  SettingsCell.swift
//  Rendezvous
//
//  Created by Admin on 4/24/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet var onOffSwitch: UISwitch!
    @IBOutlet var label: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
