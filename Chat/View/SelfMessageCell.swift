//
//  SelfMessageCell.swift
//  Rendezvous
//
//  Created by Admin on 7/20/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import SlackTextViewController

class SelfMessageCell: UITableViewCell {
  
  var chatBubble: UIImageView!
  var messageLabel: UILabel!
  
  var chatWidth: CGFloat?
  
  static let kMessageTableViewCellMinimumHeight: CGFloat = 50.0
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
        messageLabel.text = m.messageContents
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
    chatBubble.image = UIImage(named: "SelfChatBubble")
    contentView.addSubview(chatBubble)
    
    messageLabel = UILabel(frame: CGRect.zero)
    messageLabel.font = UIFont(name: "HelveticaNeue", size: 16)
    messageLabel.numberOfLines = 0
    messageLabel.lineBreakMode = .byWordWrapping
    messageLabel.textAlignment = .left
    messageLabel.textColor = UIColor.white
    chatBubble.addSubview(messageLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    messageLabel.text = nil
    chatWidth = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    var chatBubbleWidth: CGFloat!
    if chatWidth == nil {
      chatBubbleWidth = self.bounds.width * 0.7 - 10
    }
    else {
      chatBubbleWidth = chatWidth! - 10
    }
    
    chatBubble.frame = CGRect(x: self.bounds.width - (chatWidth ?? (self.bounds.width * 0.7)), y: 5, width: chatBubbleWidth, height: self.bounds.height - 10)
    messageLabel.frame = CGRect(x: 8,y: 4,width: chatBubble.frame.size.width - 22,height: chatBubble.frame.size.height - 8)
  }
  
  
}
