//
//  MessageCell.swift
//  Rendezvous
//
//  Created by Admin on 6/9/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import SlackTextViewController

class MessageCell: UITableViewCell {
  
  var usernameLabel: UILabel!
  var messageLabel: UILabel!
  var timeLabel: UILabel!
  var chatBubble: UIImageView!
  var avatarView: UIImageView!
  var embeddedImage: UIImageView!
  
  var chatWidth: CGFloat?
  
  static let kMessageTableViewCellMinimumHeight: CGFloat = 57.0
  static let kMessageTableViewCellAvatarHeight: CGFloat = 32.0
  static var defaultFontSize: CGFloat {
    get {
      var pointSize: CGFloat = 16.0
      
      let contentSizeCategory: String = UIApplication.shared.preferredContentSizeCategory.rawValue
      pointSize += SLKPointSizeDifferenceForCategory(contentSizeCategory)
      return pointSize
    }
  }
  
  var message: Message? {
    didSet {
      if let m = message {
        usernameLabel.text = m.nameForLabel
        messageLabel.text = m.messageContents
        timeLabel.text = m.timeOfMessage
        setNeedsLayout()
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    backgroundColor = UIColor.clear
    selectionStyle = .none
    
    chatBubble = UIImageView(frame: CGRect.zero)
    chatBubble.contentMode = .scaleToFill
    chatBubble.image = UIImage(named: "ChatBubble")
    
    usernameLabel = UILabel(frame: CGRect.zero)
    usernameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
    usernameLabel.textAlignment = .left
    usernameLabel.textColor = UIColor.gray
    contentView.addSubview(usernameLabel)
    
    messageLabel = UILabel(frame: CGRect.zero)
    messageLabel.autoresizingMask = UIViewAutoresizing()
    messageLabel.font = UIFont(name: "HelveticaNeue", size: 16)
    messageLabel.numberOfLines = 0
    messageLabel.lineBreakMode = .byWordWrapping
    messageLabel.textAlignment = .left
    messageLabel.textColor = UIColor.black
    chatBubble.addSubview(messageLabel)
    
    avatarView = UIImageView(image: UIImage(named: "Car"))
    contentView.addSubview(avatarView)
    
    embeddedImage = UIImageView(frame: CGRect.zero)
    
    
    //timeLabel = UILabel(frame: CGRectZero)
    //timeLabel.textAlignment = .Left
    //timeLabel.textColor = UIColor.blackColor()
    //contentView.addSubview(timeLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    usernameLabel.text = nil
    messageLabel.text = nil
    messageLabel.frame = CGRect.zero
    chatWidth = nil
    //timeLabel.text = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let width = self.bounds.width * 0.7 - 36
    chatBubble.frame = CGRect(x: 46, y: 26, width: self.chatWidth ?? width, height: self.bounds.height - 28)
    usernameLabel.frame = CGRect(x: 12, y: 5, width: (usernameLabel?.intrinsicContentSize.width)!, height: 20)
    messageLabel.frame = CGRect(x: 20,y: 4,width: chatBubble.frame.size.width - 30,height: chatBubble.frame.size.height - 8)
    avatarView.frame = CGRect(x: 10, y: self.bounds.height - 27, width: 32, height: 32)
  }
  
  
}
