//
//  CProgressView.swift
//  CProgressView
//
//  Created by Sebastian Trześniewski on 21.04.2015.
//  Copyright (c) 2015 Sebastian Trześniewski. All rights reserved.
//

import UIKit

@IBDesignable class CProgressView: UIView {
    
    // Variables
    fileprivate var π: CGFloat = CGFloat(M_PI)
    fileprivate var progressCircle = CAShapeLayer()
    fileprivate var realProgressCircle = CAShapeLayer()
    fileprivate var circlePath = UIBezierPath()
    internal var statusProgress: Int = Int()
    
    // Method for calculate ARC
    fileprivate func arc(_ arc: CGFloat) -> CGFloat {
        let results = ( π * arc ) / 180
        return results
    }
    
    // Variables for IBInspectable
    @IBInspectable var circleColor: UIColor = UIColor.gray
    @IBInspectable var progressColor: UIColor = UIColor.green
    @IBInspectable var lineWidth: Float = Float(3.0)
    @IBInspectable var valueProgress: Float = Float()
    @IBInspectable var imageView: UIImageView = UIImageView()
    @IBInspectable var image: UIImage?
    
    override func draw(_ rect: CGRect) {
        
        // Create Path for ARC
        let centerPointArc = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radiusArc: CGFloat = self.frame.width / 2 * 0.8
        circlePath = UIBezierPath(arcCenter: centerPointArc, radius: radiusArc, startAngle: arc(-90), endAngle: arc(270), clockwise: true)
        
        // Define background circle progress
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = circleColor.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = CGFloat(lineWidth)
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = 100
        
        // Define real circle progress
        realProgressCircle.path = circlePath.cgPath
        realProgressCircle.strokeColor = progressColor.cgColor
        realProgressCircle.fillColor = UIColor.clear.cgColor
        realProgressCircle.lineWidth = CGFloat(lineWidth) + 0.1
        realProgressCircle.strokeStart = 0
        realProgressCircle.strokeEnd = CGFloat(valueProgress) / 100
        
        // UIImageView
        imageView.frame = CGRect(origin: CGPoint(x: circlePath.bounds.minX, y: circlePath.bounds.minY), size: CGSize(width: circlePath.bounds.width, height: circlePath.bounds.height))
        imageView.image = image
        imageView.layer.cornerRadius = radiusArc
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        // Set for sublayer circle progress
        layer.addSublayer(progressCircle)
        layer.addSublayer(realProgressCircle)
    }
    
    // Method for update status progress
    func updateProgressCircle(_ status: Float) {
        statusProgress = Int(status)
        realProgressCircle.strokeEnd = CGFloat(status) / 100
    }
    
    func resetProgressCircle() {
        realProgressCircle.strokeEnd = CGFloat(0.0)
    }
    
    // Method for update look :)
    func changeColorBackgroundCircleProgress(_ stroke: UIColor?, fill: UIColor?) {
        progressCircle.strokeColor = stroke!.cgColor
        progressCircle.fillColor = fill!.cgColor
    }
    
    func changeColorRealCircleProgress( _ stroke: UIColor?, fill: UIColor?) {
        realProgressCircle.strokeColor = stroke!.cgColor
        realProgressCircle.fillColor = fill!.cgColor
    }
    
    func changeLineWidth(_ size: CGFloat) {
        progressCircle.lineWidth = size
        realProgressCircle.lineWidth = size + 0.1
    }
    
}
