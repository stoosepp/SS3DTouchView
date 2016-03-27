//
//  UITouch+3DTouch.swift
//  SS3DTouchView
//
//  Created by Stoo on 2016-01-11.
//  Copyright © 2016 Monotreme. All rights reserved.
//

import Foundation
import UIKit

extension UITouch
{
    var strength: CGFloat {
        get{
            return (force / maximumPossibleForce)
        }
    }
    
    var percentStrength: CGFloat {
        get{
            return strength * 100
        }
    }
    
    var weight: CGFloat {
        get{
            //This math is based on normalizing from a kitchen scale. Probably not that accurate
            return (percentStrength / 0.23191489)
        }
    }
}