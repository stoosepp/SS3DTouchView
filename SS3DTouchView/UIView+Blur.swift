//
//  UIView+Blur
//  SS3DTouchView
//
//  Created by Stoo on 2016-11-23.
//  Copyright © 2016 Monotreme. All rights reserved.
//

import Foundation
import UIKit


extension UIView{
    
    
    func blurView(_ blurRadius:CGFloat){
        if self.superview == nil
        {
            return
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 1)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        let blur = CIFilter(name: "CIGaussianBlur")!
    
        
        blur.setValue(CIImage(image: image!), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext  = CIContext(options: nil)
        
        let result = blur.value(forKey: kCIOutputImageKey) as! CIImage!
        
        let boundingRect = CGRect(x:-blurRadius * 2,
                                  y: -blurRadius * 2,
                                  width: frame.width + blurRadius * 4,
                                  height: frame.height + blurRadius * 4)
        
        let cgImage = ciContext.createCGImage(result!, from: boundingRect)
        
        let filteredImage = UIImage(cgImage: cgImage!)
        
        let blurOverlay = BlurOverlay()
        blurOverlay.frame = boundingRect
        blurOverlay.tag = 100
        blurOverlay.image = filteredImage
        //blurOverlay.contentMode = UIViewContentMode.left
        self.addSubview(blurOverlay)
        backgroundColor = UIColor.clear

    }
    class BlurOverlay: UIImageView
    {
    }
    
    func removeBlur(){
        if let viewWithTag = self.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            backgroundColor = UIColor.darkGray
        }else{
            print("No!")
        }
    }
    
}
