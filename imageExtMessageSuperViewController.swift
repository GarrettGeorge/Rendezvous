//
//  imageExtMessageSuperViewController.swift
//  Rendezvous
//
//  Created by Admin on 11/30/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import Nuke

extension MessageSuperViewController {
  
  func showFullImage() {
    /*let tempImageView = UIImageView()
    Nuke.loadImage(with: URL(string: "")!, into: tempImageView) { [weak tempImageView]  in
      tempImageView?.handle(response: $0, isFromMemoryCache: $1)
      self.fullScreenImage = tempImageView?.image
      self.fullScreenImageView.image = self.fullScreenImage
      self.fullScreenImageView.contentMode = .scaleAspectFit
      self.view.addSubview(self.fullScreenImageView)
    }*/
    print("show full screen image")
    self.fullScreenImageView.image = UIImage(named: "ken.jpg")
    fullScreenImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    self.fullScreenScrollView.contentSize = fullScreenImageView.bounds.size
    setScrollViewZoomScale()
    UIApplication.shared.keyWindow?.addSubview(self.fullScreenScrollView)
    UIView.animate(withDuration: 0.15) {
      self.fullScreenScrollView.alpha = 1
      self.fullScreenScrollView.frame = CGRect(x: 0, y: 49, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
  }
  
  func handleSingleTap(_ sender: UITapGestureRecognizer) {
    // On dismiss, reset fullscreenImageView
    UIView.animate(withDuration: 0.15, animations: {
      self.fullScreenScrollView.alpha = 0
      self.fullScreenImageView.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
    }, completion: { b in
      self.fullScreenImageView.image = nil
    })
  }
  
  func handleDoubleTap(_ sender: UITapGestureRecognizer) {
    print(fullScreenScrollView.minimumZoomScale)
    if (fullScreenScrollView.zoomScale > fullScreenScrollView.minimumZoomScale) {
      fullScreenScrollView.setZoomScale(fullScreenScrollView.minimumZoomScale, animated: true)
    } else {
      fullScreenScrollView.setZoomScale(fullScreenScrollView.maximumZoomScale, animated: true)
    }
  }

  func showImageOptions(_ sender: UIButton) {
    let alertMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let forwardAlert = UIAlertAction(title: "Forward", style: .default) { alert in
      self.forwardImage(self)
    }
    let copyAlert = UIAlertAction(title: "Copy", style: .default) { alert in
      self.copyImage()
    }
    let saveAlert = UIAlertAction(title: "Save", style: .default) { alert in
      self.saveImage(self)
    }
    let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertMenu.addAction(forwardAlert)
    alertMenu.addAction(copyAlert)
    alertMenu.addAction(saveAlert)
    alertMenu.addAction(cancelAlert)
    
    present(alertMenu, animated: true, completion: nil)
  }
  
  func forwardImage(_ sender: Any) {
    
  }
  
  func copyImage() {
    UIPasteboard.general.image = fullScreenImage
  }
  
  func saveImage(_ sender: Any) {
    /*
     let tempImageView = UIImageView()
     Nuke.loadImage(with: URL(string: "")!, into: tempImageView) { [weak tempImageView]  in
     tempImageView?.handle(response: $0, isFromMemoryCache: $1)
     UIImageWriteToSavedPhotosAlbum((tempImageView?.image)!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
     }*/
    
    print("saving full size to photo library")
  }
  
  func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
      // we got back an error!
      let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
    } else {
      
    }
  }
}
