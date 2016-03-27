//
//  ForceGestureRecognizer.swift
//  SS3DTouchView
//
//  Created by Stoo on 2016-01-11.
//  Copyright © 2016 Monotreme. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class ForceGestureRecognizer: UIGestureRecognizer {
    
    var depthValue: CGFloat = 0
    var depthValuePercent: CGFloat = 0
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        state = .Began
        handleForceWithTouches(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        state = .Changed
        handleForceWithTouches(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        state = .Ended
        handleForceWithTouches(touches)
    }
    
    func handleForceWithTouches(touches: Set<UITouch>) {
        if touches.count != 1 {
            state = .Failed
            return
        }
        guard let touch = touches.first else {
            state = .Failed
            return
        }
        depthValue = touch.force
    }
}
