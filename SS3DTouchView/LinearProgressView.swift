//
//  LinearProgressView.swift
//  LinearProgressBar
//
//  Created by Eliel Gordon on 11/13/15.
//  Copyright © 2015 Eliel Gordon. All rights reserved.
//

import UIKit

protocol LinearProgressDelegate: class {
    func didChangeProgress(fromValue from: Double, toValue to: Double)
}

@IBDesignable
class LinearProgressView: UIView {
    
    @IBInspectable var barColor: UIColor = UIColor.green
    @IBInspectable var trackColor: UIColor = UIColor.yellow
    @IBInspectable var barThickness: CGFloat = 10
    @IBInspectable var barPadding: CGFloat = 0
    @IBInspectable var trackPadding: CGFloat = 6 {
        didSet {
            if trackPadding < 0 {
                trackPadding = 0
            }else if trackPadding > barThickness {
                trackPadding = 0
            }
        }
    }
    @IBInspectable var progressValue: CGFloat = 0 {
        didSet {
            if (progressValue >= 100) {
                progressValue = 100
            } else if (progressValue <= 0) {
                progressValue = 0
            }
            setNeedsDisplay()
        }
    }
    
    weak var delegate: LinearProgressDelegate?
    
    override func draw(_ rect: CGRect) {
        drawProgressView()
    }
    
    // Draws the progress bar and track
    func drawProgressView() {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // Progres Bar Track
        context?.setStrokeColor(trackColor.cgColor)
        context?.beginPath()
        context?.setLineWidth(barThickness + trackPadding)
        context?.move(to: CGPoint(x: barPadding, y: frame.size.height / 2))
        context?.addLine(to: CGPoint(x: frame.size.width - barPadding, y: frame.size.height / 2))
        //CGContextSetLineCap(context, CGLineCap.Round)
        
        context?.strokePath()
        
        // Progress Bar
        context?.setStrokeColor(barColor.cgColor)
        context?.setLineWidth(barThickness)
        context?.beginPath()
        context?.move(to: CGPoint(x: barPadding, y: frame.size.height / 2))
        context?.addLine(to: CGPoint(x: barPadding + calcualtePercentage(), y: frame.size.height / 2))
        //CGContextSetLineCap(context, CGLineCap.Round)
        context?.strokePath()
        
        context?.restoreGState()
    }
    
    /**
     Calculates the percent value of the progress bar
     
     - returns: The percentage of progress
     */
    func calcualtePercentage() -> CGFloat {
        let screenWidth = frame.size.width - (barPadding * 2)
        let progress = ((progressValue / 100) * screenWidth)
        return progress < 0 ? barPadding : progress
    }
}
