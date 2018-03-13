//
//  ImageManipulationManager.swift
//  Rendezvous
//
//  Created by Admin on 8/19/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit

class ImageManipulationManager: NSObject {
  
  static let sharedInstance = ImageManipulationManager()
  
  override init() {
    super.init()
  }
  
  func resizeImage(exportedWidth width: Int, exportedHeight height: Int, originalImage image: UIImage) -> UIImage? {
    
    let size = CGSize(width: CGFloat(width), height: CGFloat(height))
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
    image.draw(in: CGRect(origin: CGPoint.zero, size: size))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }
  
  func maskRoundedImage(_ image: UIImage, radius: Float) -> UIImage {
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    layer.allowsEdgeAntialiasing = true
    
    layer.masksToBounds = true
    layer.cornerRadius = CGFloat(radius)
    //layer.borderWidth = 2
    //layer.borderColor = UIColor.white.cgColor
    
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return roundedImage!
  }
  
}
