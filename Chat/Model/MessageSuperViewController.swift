//
//  MeetupViewController.swift
//  Rendezvous
//
//  Created by Admin on 4/27/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import SlackTextViewController
import RealmSwift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let DEBUG_CUSTOM_TYPING_INDICATOR = false

class MessageSuperViewController: SLKTextViewController, UINavigationControllerDelegate {
  
  let MessageCellIdentifier = "messageCell"
  let SelfMessageCellIdentifier = "selfMessageCell"
  let SelfImageCellIndentifier = "sellImageCell"
  
  var messages = [Message]()
  
  var newMessage = Message()
  
  var users = [Contact]()
  
  var searchResults: [Any]?
  
  // Change the nil fail case for testing self versus received message
  lazy var myUserID: String = KeychainWrapper.standard.string(forKey: "unique_id") ?? "Garrett George"
  
  override var tableView: UITableView {
    get {
      return super.tableView!
    }
  }
  
  let imagePicker = UIImagePickerController()
  
  var fullScreenScrollView = UIScrollView()
  var fullScreenImageView = UIImageView()
  var fullScreenImage: UIImage?
  var isFullSize = false
  var imageOptions = UIButton()
    
  // MARK: - Initialisation
  
  override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
    
    return .plain
  }
  
  func commonInit() {
    
    NotificationCenter.default.addObserver(self.tableView, selector: #selector(UITableView.reloadData), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    //NSNotificationCenter.defaultCenter().addObserver(self,  selector: #selector(MeetupViewController.textInputbarDidMove(_:)), name: SLKTextInputbarDidMoveNotification, object: nil)
    
    // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
    
    //        if DEBUG_CUSTOM_TYPiNG_INDICATOR == true {
    //            // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom typing indicator view.
    //            self.registerClassForTypingIndicatorView(TypingIndicatorView.classForCoder())
    //        }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.commonInit()
    
    imagePicker.delegate = self
    print(textView.frame.size.width)
    
    // SLKTVC config
    self.configureActionItems()
    self.typingIndicatorView?.interval = 2.0
    self.bounces = true
    self.shakeToClearEnabled = true
    self.isKeyboardPanningEnabled = true
    self.shouldScrollToBottomAfterKeyboardShows = true
    self.isInverted = true
    
    //Sets left and right button for the keyboard text input view
    let b = UIButton(type: .contactAdd)
    self.leftButton.setImage(b.currentImage, for: UIControlState())
    self.rightButton.setTitle(NSLocalizedString("Send", comment: ""), for: UIControlState())
    
    self.textInputbar.autoHideRightButton = false
    self.textInputbar.rightButton.tintColor = UIColor(red: 51/255, green: 151/255, blue: 219/255, alpha: 1)
    self.textInputbar.maxCharCount = 256
    self.textInputbar.leftButton.setImage(UIImage(named: "Camera"), for: UIControlState())
    self.textInputbar.backgroundColor = UIColor.white
    self.textInputbar.layer.borderWidth = 0.0
    
    self.tableView.backgroundColor = UIColor.white
    
    if DEBUG_CUSTOM_TYPING_INDICATOR == false {
      self.typingIndicatorView!.canResignByTouch = true
    }
    
    self.tableView.separatorStyle = .none
    
    // Custom tableViewCell
    self.tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCellIdentifier)
    self.tableView.register(SelfMessageCell.self, forCellReuseIdentifier: SelfMessageCellIdentifier)
    self.tableView.register(SelfImageCell.self, forCellReuseIdentifier: SelfImageCellIndentifier)
    
    //self.autoCompletionView.registerClass(, forCellReuseIdentifier: )
    self.registerPrefixes(forAutoCompletion: ["@"])
    
    self.textView.delegate = self
    self.textView.placeholder = "Message"
    self.textView.maxNumberOfLines = 10
    self.textView.pastableMediaTypes = .all
    self.textView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
    self.textView.tintColor = UIColor(red: 51/255, green: 151/255, blue: 219/255, alpha: 1)
    self.textView.delegate = self
    self.textView.font = UIFont.systemFont(ofSize: 16.0)
    self.textView.isEditable = true
    self.textView.isSelectable = true
    self.textView.keyboardType = .default
    self.textView.returnKeyType = .next
    
    //Full screen notification listener
    
    // Full screen image attributes
    
    fullScreenScrollView.delegate = self
    fullScreenScrollView.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
    fullScreenScrollView.alpha = 0
    fullScreenScrollView.backgroundColor = UIColor.black
    fullScreenScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    // ScrollView 1/2 Tap Functionality
    let tap1 = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
    tap1.numberOfTapsRequired = 1
    
    let tap2 = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
    tap2.numberOfTapsRequired = 2
    
    tap1.require(toFail: tap2)
    fullScreenScrollView.addGestureRecognizer(tap1)
    fullScreenScrollView.addGestureRecognizer(tap2)
    
    fullScreenImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    fullScreenScrollView.addSubview(fullScreenImageView)
    
    imageOptions.frame = CGRect(x: UIScreen.main.bounds.width - 59, y: 5, width: 44, height: 44)
    imageOptions.setImage(UIImage(named: "ChatImageOptions") , for: .normal)
    //imageOptions.addTarget(self, action: #selector(MessageSuperViewController.showFullImage(_:)), for: .touchUpInside)
    imageOptions.isHidden = true
    self.view.addSubview(imageOptions)
    
    setScrollViewZoomScale()
  }
  
  override func viewWillLayoutSubviews() {
    setScrollViewZoomScale()
  }
  
  func setScrollViewZoomScale() {
    let imageViewSize = fullScreenImageView.bounds.size
    let scrollViewSize = fullScreenScrollView.bounds.size
    let widthScale = scrollViewSize.width / imageViewSize.width
    let heightScale = scrollViewSize.height / imageViewSize.height
    
    fullScreenScrollView.minimumZoomScale = min(widthScale, heightScale)
    fullScreenScrollView.zoomScale = 1.0
  }
  
  override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      self.textView.slk_scrollToBottom(animated: self.textView.isExpanding)
      //self.textView.slk_insertTextAtCaretRange("\n")
    }
    return true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  deinit {
    print("deinit")
    NotificationCenter.default.removeObserver(self)
  }
}

extension MessageSuperViewController {
  
  func configureActionItems() {
    
    let arrowItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(MessageSuperViewController.hideOrShowTextInputBar(_:)))
    self.navigationItem.rightBarButtonItems = [arrowItem]
  }
  
  func hideOrShowTextInputBar(_ sender: AnyObject) {
    
    guard let buttonItem = sender as? UIBarButtonItem
      else {
        return
    }
    
    let hide = !self.isTextInputbarHidden
    let image = hide ? UIImage(named: "") : UIImage(named: "")
    
    self.setTextInputbarHidden(hide, animated: true)
    buttonItem.image = image
  }
  
  // Updates those users that are currently typing when called from NSNotificationCenter on socket.on
  func handleUserTypingNotification(_ notification: Foundation.Notification) {
    if let typingUser = notification.object as? String {
      if typingUser != myUserID {
        self.typingIndicatorView?.insertUsername(typingUser)
      }
    }
  }
}

extension MessageSuperViewController: UIImagePickerControllerDelegate {
  
  // MARK: Overriden Methods
  
  override func ignoreTextInputbarAdjustment() -> Bool {
    return super.ignoreTextInputbarAdjustment()
  }
  
  override func textWillUpdate() {
    super.textWillUpdate()
  }
  
  override func textDidUpdate(_ animated: Bool) {
    super.textDidUpdate(animated)
  }
  
  
  override func didPressRightButton(_ sender: Any?) {
    self.textView.refreshFirstResponder()
    
    // Creates temporary Message from keyboard input
    let message = Message()
    if let id = KeychainWrapper.standard.string(forKey: "unique_id"), let displayName = KeychainWrapper.standard.string(forKey: "display_name") {
      message.senderID = id
      message.nameForLabel = displayName
    }
      //
      // Change to senderID = "Failed" once logging in is finished
      //
    else {
      message.nameForLabel = "Garrett George"
      message.senderID = "Garrett George"
    }
    
    message.classification = newMessage.classification
    if newMessage.classification == "text" {
      message.messageContents = textView.text
    }
    else {
      message.messageContents = newMessage.messageContents
      message.thumbnail = newMessage.thumbnail
    }
    print(message)
    // MARK: SlkTVC method calls
    
    // Creates the path and scroll position for the new message such that new
    // messages appear bottom up
    let indexPath = IndexPath(row: 0, section: 0)
    let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
    let scrollPos: UITableViewScrollPosition = self.isInverted ? .bottom : .top
    
    // Updates the tableView with the new Message
    self.tableView.beginUpdates()
    self.messages.insert(message, at: 0)
    self.newMessage = message
    self.tableView.insertRows(at: [indexPath], with: rowAnimation)
    self.tableView.endUpdates()
    
    // Self scrolls to the bottom
    self.tableView.scrollToRow(at: indexPath, at: scrollPos, animated: true)
    
    self.tableView.reloadRows(at: [indexPath], with: .automatic)
    
    // Call to super for clean up behind the scenes
    super.didPressRightButton(sender)
  }
  
  // Called from socket.on("getNewMessage")
  // Identical to tableView calls of didPressRightButton()
  func didReceiveNewMessage() {
    let indexPath = IndexPath(row: 0, section: 0)
    let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
    let scrollPos: UITableViewScrollPosition = self.isInverted ? .bottom : .top
    
    self.tableView.beginUpdates()
    self.tableView.insertRows(at: [indexPath], with: rowAnimation)
    self.tableView.endUpdates()
    
    self.tableView.scrollToRow(at: indexPath, at: scrollPos, animated: true)
    
    self.tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  override func didPressLeftButton(_ sender: Any?) {
    let cameraMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let photoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { (UIAlertAction) in
      self.openPhotoLibrary()
    })
    
    let takePhoto = UIAlertAction(title: "Open Camera", style: .default, handler: { (UIAlertAction) in
      self.openCamera()
    })
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    cameraMenu.addAction(photoLibrary)
    cameraMenu.addAction(takePhoto)
    cameraMenu.addAction(cancel)
    
    self.present(cameraMenu, animated: true, completion: nil)
  }
  
  func openPhotoLibrary() {
    imagePicker.sourceType = .photoLibrary
    present(imagePicker, animated: true, completion: nil)
  }
  
  func openCamera(){
    imagePicker.sourceType = .camera
    imagePicker.showsCameraControls = true
    present(imagePicker, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
    if action == #selector(forwardImage(_:)) || action == #selector(saveImage(_:)) {
      print("can perform")
      return true
    }
    return false
  }
  
  override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      handleImageFromSelection(pickedImage)
    }
    dismiss(animated: true, completion: nil)
  }
  
  override func didPasteMediaContent(_ userInfo: [AnyHashable: Any]) {
    print(textView.selectedRange.location)
    if let pickedImage = UIPasteboard.general.image {
      handleImageFromSelection(pickedImage)
    }
  }
  
  func handleImageFromSelection(_ pickedImage: UIImage) {
    textView.textStorage.insert(NSAttributedString(string: "\n"), at: textView.selectedRange.location)
    textView.selectedRange.location = textView.selectedRange.location + 1
    textView.font = UIFont.systemFont(ofSize: 16.0)
    
    // Image resizing
    let textViewWidth: CGFloat = self.textView.frame.size.width - 20
    let percentResize = textViewWidth / pickedImage.size.width
    let toBeExportedHeight = pickedImage.size.height * percentResize
    var resizedImage = ImageManipulationManager.sharedInstance.resizeImage(exportedWidth: Int(textViewWidth),exportedHeight: Int(toBeExportedHeight), originalImage: pickedImage)
    if resizedImage != nil {
      resizedImage = ImageManipulationManager.sharedInstance.maskRoundedImage(resizedImage!, radius: 30)
      
    }
    
    // Storage into TextView
    let attributedString = NSAttributedString(string: textView.text)
    let attachment = NSTextAttachment()
    attachment.image = resizedImage
    let attString = NSAttributedString(attachment: attachment)
    print(textView.selectedRange.location)
    textView.textStorage.insert(attString, at: textView.selectedRange.location)
    textView.selectedRange.location = textView.selectedRange.location + 1
    textView.textStorage.insert(NSAttributedString(string: "\n"), at: textView.selectedRange.location)
    textView.selectedRange.location = textView.selectedRange.location + 1
    textView.font = UIFont.systemFont(ofSize: 16.0)
    
    // Manage message classification
    newMessage.classification = "image"
    if resizedImage != nil {
      if let data = UIImageJPEGRepresentation(resizedImage!, 0.50) {
        print("setting thumbnail")
        newMessage.thumbnail = data
      }
    }
    newMessage.messageContents = String(describing: textViewWidth) + "x" + String(describing: toBeExportedHeight)
    print(newMessage.messageContents)
  }
  
  override func willRequestUndo() {
    super.willRequestUndo()
  }
  
  override func canPressRightButton() -> Bool {
    return super.canPressRightButton()
  }
  
  override func canShowTypingIndicator() -> Bool {
    return DEBUG_CUSTOM_TYPING_INDICATOR ? true : super.canShowTypingIndicator()
  }
  
  override func shouldProcessText(forAutoCompletion text: String) -> Bool {
    return true
  }
  
  override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
    var array: [AnyObject]?
    
    self.searchResults = nil
    
    if prefix == "@" {
      if word.characters.count > 0 {
        array = (self.users as NSArray).filtered(using: NSPredicate(format: "self BEGINSWITH[c] %@", word)) as [AnyObject]?
      }
      else {
        array = self.users
      }
    }
    
    var show = false
    
    if array?.count > 0 {
      self.searchResults = (array! as NSArray).sortedArray(using: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
      show = (self.searchResults?.count > 0)
    }
    
    self.showAutoCompletionView(show)
  }
  
  override func heightForAutoCompletionView() -> CGFloat {
    guard let searchResults = self.searchResults else {
      return 0
    }
    
    let cellHeight = self.autoCompletionView.delegate?.tableView!(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0))
    guard let height = cellHeight else{
      return 0
    }
    return height * CGFloat(searchResults.count)
  }
}

extension MessageSuperViewController {
  
  // MARK: UITableViewDataSource methods
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  // Number of cells in tableView based on if searching or default view
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.tableView {
      return self.messages.count
    }
    else {
      if let searchResults = self.searchResults {
        return searchResults.count
      }
    }
    
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == self.tableView {
      let msg = messages[indexPath.row]
      if msg.senderID == myUserID {
        if msg.classification == "image" {
          return selfImageCellForRowAtIndexPath(indexPath)
        }
        return selfMessageCellForRowAtIndexPath(indexPath)
      }
      else {
        return messageCellForRowAtIndexPath(indexPath)
      }
    }
    return messageCellForRowAtIndexPath(indexPath)
  }
  
  func messageCellForRowAtIndexPath(_ indexPath: IndexPath) -> MessageCell{
    let cell = self.tableView.dequeueReusableCell(withIdentifier: MessageCellIdentifier) as! MessageCell
    
    let message = self.messages[(indexPath as NSIndexPath).row]
    
    if message.classification == "image" {
      cell.chatBubble.removeFromSuperview()
      
    }
    else {
      cell.contentView.addSubview(cell.chatBubble)
      cell.messageLabel.text = message.messageContents
      let messageWidth = cell.messageLabel.intrinsicContentSize.width
      if messageWidth < (cell.bounds.width - 36 - cell.bounds.width * 0.3){
        cell.chatWidth = messageWidth + 32
      }
    }
    
    
    cell.usernameLabel.text = message.nameForLabel
    
    
    cell.transform = self.tableView.transform
    
    return cell
  }
  
  func selfMessageCellForRowAtIndexPath(_ indexPath: IndexPath) -> SelfMessageCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: SelfMessageCellIdentifier) as! SelfMessageCell
    
    let message = self.messages[indexPath.row]
    
    cell.messageLabel.text = message.messageContents
    let messageWidth = cell.messageLabel.intrinsicContentSize.width
    if messageWidth < (cell.bounds.width * 0.7 - 42) {
      cell.chatWidth = messageWidth + 33
    }
    
    cell.transform = self.tableView.transform
    
    return cell
  }
  
  func selfImageCellForRowAtIndexPath(_ indexPath: IndexPath) -> SelfImageCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: SelfImageCellIndentifier) as! SelfImageCell
    
    let message = self.messages[indexPath.row]
    
    if message.thumbnail != nil {
      /*let uiimage = UIImage(data: message.thumbnail!)
       if let cgimage = uiimage?.cgImage, let scale = uiimage?.scale {
       cell.imageForCell.setImage(UIImage(cgImage: cgimage, scale: scale, orientation: UIImageOrientation.downMirrored), for: .normal)
       }*/
      cell.imageForCell.setImage(UIImage(data: message.thumbnail!), for: .normal)
    }
    cell.dimensions = message.messageContents
    
    cell.transform = self.tableView.transform
    
    return cell
  }
  
  // Calculations of the height of the given cell based on variable text input lengths and screen region sizes
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if tableView == self.tableView {
      let message = self.messages[indexPath.row]
      
      // Height calculation based on a text only message
      if message.classification == "text" {
        var defaultFontSize = MessageCell.defaultFontSize
        var minimumHeight = MessageCell.kMessageTableViewCellMinimumHeight
        var avatarHeight = MessageCell.kMessageTableViewCellAvatarHeight
        var heightTitleOffset: CGFloat = 45.0
        if message.senderID == myUserID{
          defaultFontSize = SelfMessageCell.defaultFontSize
          minimumHeight = SelfMessageCell.kMessageTableViewCellMinimumHeight
          avatarHeight = 0
          heightTitleOffset = 30.0
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        
        let pointSize = defaultFontSize
        
        let attributes = [
          NSFontAttributeName : UIFont.systemFont(ofSize: pointSize),
          NSParagraphStyleAttributeName : paragraphStyle
        ]
        
        var width = (tableView.frame.width * 0.7) - avatarHeight
        width -= 25.0
        
        let bodyBounds = (message.messageContents as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        if message.messageContents.characters.count == 0 {
          print("character count zero")
          return 0
        }
        var height: CGFloat = heightTitleOffset
        height += bodyBounds.height
        
        if height < minimumHeight {
          height = minimumHeight
        }
        return height
      }
        // Height calculation based on a landscape or portrait thumbnail
      else {
        if let indexOfx = message.messageContents.index(of: "x") {
          if let height = NumberFormatter().number(from: message.messageContents.substring(from: indexOfx.advance(1, for: message.messageContents))) {
            return CGFloat(height) + 15
          }
          else {
            print("failed to convert to NSNumber")
          }
        }
        return MessageCell.kMessageTableViewCellMinimumHeight
      }
    }
    return MessageCell.kMessageTableViewCellMinimumHeight
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView == self.autoCompletionView {
      
      guard let searchResults = self.searchResults as? [String] else {
        return
      }
      
      var item = searchResults[(indexPath as NSIndexPath).row]
      
      if self.foundPrefix == "@" && self.foundPrefixRange.location == 0 {
        item += ":"
      }
      
      item += " "
      
      self.acceptAutoCompletion(with: item, keepPrefix: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10.0
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height:10))
    view.backgroundColor = UIColor.white
    
    return view
    
  }
}

extension MessageSuperViewController {
  
  // MARK: UIScrollViewDelegate Methods
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    super.scrollViewDidScroll(scrollView)
  }
  
  override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    if scrollView == fullScreenScrollView {
      return fullScreenImageView
    }
    return nil
  }
  
  override func scrollViewDidZoom(_ scrollView: UIScrollView) {
    if scrollView == fullScreenScrollView {
      let imageViewSize = fullScreenImageView.frame.size
      let scrollViewSize = fullScreenScrollView.bounds.size
      
      let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
      let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
      
      fullScreenScrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
  }
}
