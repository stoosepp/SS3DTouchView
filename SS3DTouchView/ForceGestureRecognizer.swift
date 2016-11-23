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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
        handleForceWithTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        state = .changed
        handleForceWithTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
        handleForceWithTouches(touches)
    }
    
    func handleForceWithTouches(_ touches: Set<UITouch>) {
        if touches.count != 1 {
            state = .failed
            return
        }
        guard let touch = touches.first else {
            state = .failed
            return
        }
        depthValue = touch.force
    }
}
