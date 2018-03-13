//
//  SelfImageCell.swift
//  Rendezvous
//
//  Created by Admin on 11/15/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import Nuke

class SelfImageCell: UITableViewCell {
  
  var imageForCell: UIButton!
  var dimensions: String!
  
  override var canBecomeFirstResponder: Bool { return true }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    selectionStyle = .none
    
    imageForCell = UIButton()
    imageForCell.clipsToBounds = true
    imageForCell.adjustsImageWhenHighlighted = false
    imageForCell.addTarget(self, action: #selector(notifyVCForFullScreen(_:)), for: .touchUpInside)
    imageForCell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(openImageMenu(_:))))
    contentView.addSubview(imageForCell)
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
  
  override func prepareForReuse() {
    imageForCell.setImage(nil, for: .normal)
    imageForCell.removeTarget(self, action: #selector(notifyVCForFullScreen(_:)), for: .touchUpInside)
    imageForCell.gestureRecognizers?.forEach(imageForCell.removeGestureRecognizer)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    guard let indexOfx = dimensions.index(of: "x") else {
      return
    }
    if let x = NumberFormatter().number(from: dimensions.substring(to: indexOfx)), let y = NumberFormatter().number(from: dimensions.substring(from: indexOfx.advance(1, for: dimensions))) {
      let imageX = CGFloat(x), imageY = CGFloat(y)
      print("x: \(imageX), y: \(imageY)")
      imageForCell.frame = CGRect(x: self.bounds.width - imageX - 10, y: 5, width: imageX, height: imageY)
    }
    else {
      print("failed to convert to NSNumber")
    }
  }
  
  func notifyVCForFullScreen(_ sender: UIButton) {
    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "showFullScreenImage")))
  }
  
  func openImageMenu(_ recognizer: UILongPressGestureRecognizer) {
    guard recognizer.state == .began else { return }
    
    print("imagemenu")
    becomeFirstResponder()
    
    let imageMenu = UIMenuController.shared
    let forward = UIMenuItem(title: "Forward", action: #selector(MessageSuperViewController.forwardImage(_:)))
    let save = UIMenuItem(title: "Save", action: #selector(MessageSuperViewController.saveImage(_:)))
    imageMenu.menuItems = [forward,save]
    
    imageMenu.setTargetRect(imageForCell.frame, in: imageForCell.superview!.superview!)
    imageMenu.setMenuVisible(true, animated:true)
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if action == #selector(MessageSuperViewController.forwardImage(_:)) || action == #selector(MessageSuperViewController.saveImage(_:)) {
      return true
    }
    return false
  }
}

extension String {
  func index(of string: String, options: String.CompareOptions = .literal) -> String.Index? {
    return range(of: string, options: options, range: nil, locale: nil)?.lowerBound
  }
}

extension String.Index {
  func advance(_ offset:Int, `for` string:String)->String.Index{
    return string.index(self, offsetBy: offset)
  }
}
