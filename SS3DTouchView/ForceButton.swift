//
//  UIView+3DTouch.swift
//  SS3DTouchView
//
//  Created by Stoo on 2016-01-08.
//  Copyright © 2016 Monotreme. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox


protocol SSForceButtonDelegate
{
    func updateForceLabel(currentforceValue: CGFloat)
}

enum ForceButtonType: Int {
    case ShadowAbove = 0
    case FlatShadowAbove = 1
    case ShadowBelow = 2
    case Pincushion = 3
    case SquareTopBorder = 4
    case CircleBorder = 5
    case BarnDoor = 6
    case None = 7
}



class ForceButton: UIButton {

    //You can Set These
    var forceButtonType: ForceButtonType
    var shadowColor: UIColor = UIColor.darkGrayColor()
    var shadowOpacity: Float = 0.8
    var maxShadowOffset: CGSize = CGSize(width: 10, height: 10)
    var maxShadowRadius: CGFloat = 10.0
    var minShadowRadius: CGFloat = 2.0
    
    var bottomHit:Bool
    
    //Properties (Don't mess with these)
    private let maxForceValue: CGFloat = 100
    let context = UIGraphicsGetCurrentContext()
    var delegate: SSForceButtonDelegate?
    var innerShadowLayer = CALayer()
    var flatShadowLayer = CALayer()
    var buttonShapeLayer = CAShapeLayer()
    var shadowShapeLayer = CAShapeLayer()
    var bgColor:UIColor = UIColor()
    var buttonCenter = CGPoint()
    var backgroundImage = UIImage()
    let pinImageView: UIImageView = UIImageView()
    let ringProgressView = CProgressView()
    let topBarView = LinearProgressView()
    let leftDoorLayer = CALayer()
    let rightDoorLayer = CALayer()

    
    
    
    
    
    @IBInspectable var vibratesOnBottomHit: Bool = false{
        willSet {
        }
    }
    @IBInspectable var bottomHitVisibleOnBG: Bool = false {
        willSet {
        }
    }
    @IBInspectable var bottomHitVisibleonButton: Bool = false{
        willSet {
        }
    }
    
    //Init
    required init(coder aDecoder: NSCoder) {
        forceButtonType = .ShadowAbove
        bottomHit = false
        super.init(coder: aDecoder)!

    }
    //MARK: INITIALIZE BUTTON
    func initializeButton(withType: ForceButtonType)
    {
        forceButtonType = withType
        buttonCenter = center
        resetButton()
        switch withType {
        case .ShadowAbove:
            shadowAboveWithAmount(0.0)
            print("Setting Up Shadow Above")
        case .ShadowBelow:
            layer.addSublayer(innerShadowLayer)
            shadowBelowWithAmount(0.0)
            print("Setting Up Shadow Below")
        case .FlatShadowAbove:
            //layer.cornerRadius = 20 //Should accomodate for this
            setupFlatShadow()
            flatShadowAboveWithAmount(0.0)
            print("Setting Up Flat Shadow Above")
        case .Pincushion:
            setupPincushionDistortion()
        case .CircleBorder:
            setupCircle()
            circleWithAmount(0.0)
        case .SquareTopBorder:
            setupTopBar()
            topBarWithAmount(0.0)
        case .BarnDoor:
            setupBarnDoor()
            barnDoorWithAmount(0.0)
        default:
            print("Not Setting anything Up")
        }
    }
    
    func resetButton()
    {
        backgroundColor = UIColor.cyanColor()
        bgColor = backgroundColor! as UIColor
        buttonCenter = center
        layer.shadowOffset.width = 0.0
        layer.shadowOffset.height = 0.0
        layer.shadowRadius = 0.0
        layer.borderWidth = 0.0
        innerShadowLayer.frame.size = frame.size
        innerShadowLayer.frame.origin = CGPoint(x: 0,y: 0)
        innerShadowLayer.removeFromSuperlayer()
        flatShadowLayer.removeFromSuperlayer()
        shadowShapeLayer.path = nil
        shadowShapeLayer.fillColor = shadowColor.CGColor
        layer.removeAllAnimations()
        setBackgroundImage(UIImage(), forState: state)
        
        for view in subviews {
            view.removeFromSuperview()
        }
        leftDoorLayer.sublayers?.removeAll()
        rightDoorLayer.sublayers?.removeAll()
        self.layer.sublayers?.removeAll()
        layer.masksToBounds = false
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeButton(.ShadowAbove)
        delegate?.updateForceLabel(0.0)
     
    }
    //MARK: HANDLE TOUCHES
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        handleForceWithTouches(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        handleForceWithTouches(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        switch forceButtonType {
        case .ShadowAbove:
            shadowAboveWithAmount(0.0)
        case .ShadowBelow:
            shadowBelowWithAmount(0.0)
        case .FlatShadowAbove:
            flatShadowAboveWithAmount(0.0)
        case .Pincushion:
            pincushionDistortionWithAmount(0, position: CGPoint(x: 0, y: 0))
        case .CircleBorder:
            circleWithAmount(0.0)
        case .SquareTopBorder:
            topBarWithAmount(0.0)
        case .BarnDoor:
            barnDoorWithAmount(0.0)
        default:
            shadowBelowWithAmount(0.0)
        }
        delegate?.updateForceLabel(0)
    }
    
    func handleForceWithTouches(touches: Set<UITouch>) {
        if touches.count != 1 {
            return
        }
        guard let touch = touches.first else {
            return
        }
        switch forceButtonType {
        case .ShadowAbove:
            shadowAboveWithAmount(touch.strength)
        case .ShadowBelow:
            shadowBelowWithAmount(touch.strength)
        case .FlatShadowAbove:
            flatShadowAboveWithAmount(touch.strength)
        case .Pincushion:
            pincushionDistortionWithAmount(touch.strength, position: touch.locationInView(self))
        case .CircleBorder:
            circleWithAmount(touch.strength)
        case .SquareTopBorder:
            topBarWithAmount(touch.strength)
        case .BarnDoor:
            barnDoorWithAmount(touch.strength)
        default:
            print("Button has no type")
        }
        delegate?.updateForceLabel(touch.percentStrength)
        if bottomHit == true{
            if touch.strength == 1.0
            {
                superview!.backgroundColor = UIColor.redColor()
            }
            else{
                superview!.backgroundColor = UIColor.whiteColor()
            }
        }
  
    }

    //MARK: SHADOW ABOVE
    func shadowAboveWithAmount(amount: CGFloat) {
        layer.shadowColor = shadowColor.CGColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: maxShadowOffset.width - (maxShadowOffset.width * amount),
            height: maxShadowOffset.height - (maxShadowOffset.height * amount))
        layer.shadowRadius = maxShadowRadius - (maxShadowRadius * amount) + minShadowRadius
    }
    
    //MARK: FLAT SHADOW ABOVE
    func flatShadowAboveWithAmount(amount:CGFloat){
        //Move On press
        updateShadowPathWithAmount(amount)
        if amount == 0.0{
            backgroundColor = bgColor
        }
        //layer.timeOffset = Double(amount)
    }
    func setupFlatShadow(){
        layer.addSublayer(flatShadowLayer)
        layer.addSublayer(buttonShapeLayer)
        buttonShapeLayer.fillColor = bgColor.CGColor
        
       //addMovementAnimation() //This is where the problem lies
        flatShadowLayer.addSublayer(shadowShapeLayer)
    }
    
    
    func updateShadowPathWithAmount(amount:CGFloat){
        
        backgroundColor = UIColor.clearColor()
    
        let newButtonPath = CGPathCreateWithRect(CGRect(x: bounds.origin.x + (maxShadowOffset.width * amount), y: bounds.origin.y + (maxShadowOffset.height * amount), width: bounds.width, height: bounds.height), nil)
        buttonShapeLayer.path = newButtonPath
        
        
        let newShadowPath = CGPathCreateMutable()
        //Button Corner
        let topLeftPointx: CGFloat = 0.0 + (maxShadowOffset.width * amount)
        let topLeftPointy: CGFloat = 0.0 + (maxShadowOffset.height * amount)
        let topRightPointx = frame.size.width + (maxShadowOffset.width * amount)
        let topRightPointy: CGFloat = 0.0 + (maxShadowOffset.height * amount)
        let bottomLeftPointx: CGFloat = 0.0 + (maxShadowOffset.width * amount)
        let bottomLeftPointy = frame.size.height + (maxShadowOffset.height * amount)
        let bottomRightPointx = frame.size.width + (maxShadowOffset.width * amount)
        let bottomRightPointy = frame.size.height + (maxShadowOffset.height * amount)
        
        //ShadowCorners
        let widthOffset = maxShadowOffset.width - (maxShadowOffset.width * amount)
        let heightOffset = maxShadowOffset.height - (maxShadowOffset.height * amount)
        let topLeftShadowPointx = topLeftPointx + widthOffset
        let topLeftShadowPointy = topLeftPointy + heightOffset
        let topRightShadowPointx = topRightPointx + widthOffset
        let topRightShadowPointy = topRightPointy + heightOffset
        let bottomLeftShadowPointx = bottomLeftPointx + widthOffset
        let bottomLeftShadowPointy = bottomLeftPointy + heightOffset
        let bottomRightShadowPointx = bottomRightPointx + widthOffset
        let bottomRightShadowPointy = bottomRightPointy + heightOffset
        
        if maxShadowOffset.width > 0 && maxShadowOffset.height > 0
        {
            //print("Shadow on Bottom Right")
            CGPathMoveToPoint(newShadowPath, nil, topRightPointx, topRightPointy) //Top Right
            CGPathAddLineToPoint(newShadowPath, nil, topRightShadowPointx, topRightShadowPointy)//Shadow of Top Right
            CGPathAddLineToPoint(newShadowPath, nil, bottomRightShadowPointx, bottomRightShadowPointy) //Shadow of Bottom Right
            CGPathAddLineToPoint(newShadowPath, nil, bottomLeftShadowPointx, bottomLeftShadowPointy) //Shadow of Bottom Left
            CGPathAddLineToPoint(newShadowPath, nil, bottomLeftPointx, bottomLeftPointy) //Bottom Left
            CGPathAddLineToPoint(newShadowPath, nil, bottomRightPointx, bottomRightPointy) //Bottom Right
        }
        else if maxShadowOffset.width < 0 && maxShadowOffset.height < 0
        {
            print("Shadow on Top Left")
            CGPathMoveToPoint(newShadowPath, nil, topRightPointx, topRightPointy) //Top Right
            CGPathAddLineToPoint(newShadowPath, nil, topRightShadowPointx, topRightShadowPointy )//Shadow of Top Right
            CGPathAddLineToPoint(newShadowPath, nil, topLeftShadowPointx, topLeftShadowPointy) //Shadow of Top Left
            CGPathAddLineToPoint(newShadowPath, nil, bottomLeftShadowPointx, bottomLeftShadowPointy) //Shadow of Bottom Left
            CGPathAddLineToPoint(newShadowPath, nil, bottomLeftPointx, bottomLeftPointy) //Bottom Left
            CGPathAddLineToPoint(newShadowPath, nil, topLeftPointx, topLeftPointy) //Top Left
        }
        else if maxShadowOffset.width > 0 && maxShadowOffset.height < 0{
            print("Shadow on Top Right")
            CGPathMoveToPoint(newShadowPath, nil, topRightPointx, topRightPointy) //Top Right
            CGPathAddLineToPoint(newShadowPath, nil, bottomRightPointx, bottomRightPointy) //Bottomr Right
            CGPathAddLineToPoint(newShadowPath, nil, bottomRightShadowPointx, bottomRightShadowPointy) //Shadow of Bottom Right
            CGPathAddLineToPoint(newShadowPath, nil, topRightShadowPointx, topRightShadowPointy)//Shadow of Top Right
            CGPathAddLineToPoint(newShadowPath, nil, topLeftShadowPointx, topLeftShadowPointy) //Shadow of Top Left
            CGPathAddLineToPoint(newShadowPath, nil, topLeftPointx, topLeftPointy) //Top Left
        }
        else if maxShadowOffset.width < 0 && maxShadowOffset.height > 0{
            print("Shadow on Top Right")
            CGPathMoveToPoint(newShadowPath, nil, topLeftPointx, topLeftPointx) //Top Left
            CGPathAddLineToPoint(newShadowPath, nil, topLeftShadowPointx, topLeftShadowPointy) //Shadow of Top Left
            CGPathAddLineToPoint(newShadowPath, nil, bottomLeftShadowPointx, bottomLeftShadowPointy) //Shadow of Bottom Left
            CGPathAddLineToPoint(newShadowPath, nil, bottomRightShadowPointx, bottomRightShadowPointy) //Shadow of Bottom Right
            CGPathAddLineToPoint(newShadowPath, nil, bottomRightPointx, bottomRightPointy) //Bottomr Right
            CGPathAddLineToPoint(newShadowPath, nil, bottomLeftPointx, bottomLeftPointy) //Bottom Left
        }
        shadowShapeLayer.path = newShadowPath
    }
    
    
    func addMovementAnimation(){
        //This works for positive and negative values of maxShadowOffset
        let animationX = CABasicAnimation(keyPath: "transform.translation.x")
        let animationY = CABasicAnimation(keyPath: "transform.translation.y")
        animationX.toValue = CGFloat(maxShadowOffset.width)
        animationY.toValue = CGFloat(maxShadowOffset.height)
        animationX.duration = 1
        animationY.duration = 1
        layer.addAnimation(animationX, forKey: "translationAnimationX")
        layer.addAnimation(animationY, forKey: "translationAnimationY")
        layer.speed = 0
    }
    
    
    //MARK: SHADOW BELOW
    func shadowBelowWithAmount(amount: CGFloat) {
        if maxShadowOffset.width > 0
        {
           innerShadowLayer.frame.size.width = frame.size.width + maxShadowOffset.width * 5
        }
        if maxShadowOffset.height < 0
        {
            innerShadowLayer.frame.size.height = frame.size.height - maxShadowOffset.height * 5
        }
        if maxShadowOffset.width < 0
        {
           innerShadowLayer.frame.size.width = frame.size.width - maxShadowOffset.width * 5
            innerShadowLayer.frame.origin.x = (maxShadowOffset.width * 5)
        }
        if maxShadowOffset.height > 0
        {
            innerShadowLayer.frame.size.height = frame.size.height + maxShadowOffset.height * 5
            innerShadowLayer.frame.origin.y =  -(maxShadowOffset.height * 5)
        }
        layer.masksToBounds = true
        
        // Shadow path (1pt ring around bounds)
        let path = UIBezierPath(rect: innerShadowLayer.bounds.insetBy(dx: -(amount * maxShadowRadius), dy: -(amount * maxShadowRadius)))
        let cutout = UIBezierPath(rect: innerShadowLayer.bounds).bezierPathByReversingPath()
        path.appendPath(cutout)
        innerShadowLayer.shadowPath = path.CGPath
        innerShadowLayer.masksToBounds = true
        
        // Shadow properties
        innerShadowLayer.shadowColor = UIColor(white: 0, alpha: 1).CGColor
        innerShadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        innerShadowLayer.shadowOpacity = 1
        innerShadowLayer.shadowRadius = (maxShadowRadius * amount) + minShadowRadius
        //print("Shadow Radius is \(extraShadowLayer.shadowRadius)")
        
        //This next line darkens the color of the button as it moves below the plane by a factor of a quarter
        darkenColorWithAmount(amount / 10)
        
    }
    
    func darkenColorWithAmount(amount:CGFloat)
    {
        
        //Make the Button darker the lower it gets
        let rgbValue = bgColor.rgb()
        var redValue = CGFloat(rgbValue!.red)
        redValue = (redValue - (redValue * amount))/255
        var greenValue = CGFloat(rgbValue!.green)
        greenValue = (greenValue - (greenValue * amount))/255
        var blueValue = CGFloat(rgbValue!.blue)
        blueValue = (blueValue - (blueValue * amount))/255
        let alphaValue = CGFloat(rgbValue!.alpha)
        backgroundColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
    }
    
    //MARK: PINCUSHION
    
    func setupPincushionDistortion()
    {
        pinImageView.frame.origin = CGPoint(x:0, y: 0)
        pinImageView.frame.size = frame.size
        //pinImageView.image = backgroundImage
        pinImageView.image = UIImage(named: "checkerboard.jpg")
        pinImageView.contentMode = .ScaleToFill
        addSubview(pinImageView)

        print("Setting up pincushion")
        
        UIGraphicsBeginImageContext(bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        backgroundImage = viewImage

    }
    
    func pincushionDistortionWithAmount(amount:CGFloat, position:CGPoint){
        
        print(position)
        //1 Remove All Subviews
        for view in subviews {
            view.removeFromSuperview()
        }

        print(position)
        //2
        let beginImage = CIImage(image: backgroundImage)
        
        // 3
        let filter :CIFilter = CIFilter(name: "CIBumpDistortion")!
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: position.x, y: position.y), forKey:"inputCenter")
        filter.setValue(75, forKey:"inputRadius")
        filter.setValue(-1 * amount, forKey:"inputScale")//Positive creates a bump, negative an indent
 
        // 4
        var newImage:UIImage = UIImage(CIImage: filter.outputImage!)
        //ORIGINAL
        //let newCGIImage = CIContext(options:nil).createCGImage(filter.outputImage!, fromRect:filter.outputImage!.extent)

        let newCGIImage = CIContext(options:nil).createCGImage(filter.outputImage!, fromRect:pinImageView.frame)
        //print(filter.outputImage!.extent)

        let imageViewWidth = pinImageView.frame.size.width
        let imageViewHeight = pinImageView.frame.size.height
        let imageWidth = newImage.size.width
        let imageHeight = newImage.size.height
        
        if imageWidth > imageViewWidth || imageHeight > imageViewHeight{
            //print("Image is wider than ImageView")
            //Code to crop image to fit in imageView
            newImage = cropToBounds(newCGIImage, width: imageViewWidth, height: imageViewHeight)
        }
        else
        {
            //print("Image is narrower than ImageView")
        }
    
        
        //print("ImageView:\(pinImageView.bounds.size) and Image: \(newImage.size)")
        pinImageView.image = newImage
        addSubview(pinImageView)
       // print(pinImageView.layer.frame)
    }
    
    func cropToBounds(image: CGImageRef, width: CGFloat, height: CGFloat) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image)
        let contextSize: CGSize = pinImageView.bounds.size//contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        /*
        if contextSize.width > contextSize.height {
            posX = 0//((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
            
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
*/
        //ORIGINAL
        //let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)

        //MY VERSION
        let rect: CGRect = CGRectMake(posX, posY, contextSize.width, contextSize.height)
        //print("Rect:\(rect)")
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let imageUI: UIImage = UIImage(CGImage: imageRef)
        let upsideDownImage: UIImage = UIImage(CGImage: imageRef, scale: imageUI.scale, orientation: imageUI.imageOrientation)
        let FinalImage = UIImage(CGImage: upsideDownImage.CGImage!, scale: 1.0, orientation: .DownMirrored)

        
        return FinalImage
    }
    
    //MARK: CIRCLE BUTTON
    func setupCircle()
    {
        
        ringProgressView.frame = self.bounds
        ringProgressView.backgroundColor = .clearColor()
        backgroundColor = .clearColor()
        ringProgressView.updateProgressCircle(0.0)
        ringProgressView.resetProgressCircle()
        ringProgressView.circleColor = UIColor.cyanColor()
        ringProgressView.progressColor = UIColor.blueColor()
        ringProgressView.lineWidth = 20
        self.addSubview(ringProgressView)
        

    }
    
    func circleWithAmount(amount:CGFloat){
        let amountFloat = Float(amount) * 100
        ringProgressView.updateProgressCircle(amountFloat)
    }
    
    //MARK: TOP BORDER
    func setupTopBar()
    {
        topBarView.frame.size.width = self.frame.size.width
        topBarView.barColor = UIColor.blueColor()
        topBarView.barThickness = 20
        topBarView.frame.size.height = topBarView.barThickness
        topBarView.frame.origin = CGPointMake(0, 0)
        topBarView.trackColor = UIColor.cyanColor()
        self.addSubview(topBarView)
    }
    
    func topBarWithAmount(amount:CGFloat){
        topBarView.progressValue = amount * 100
        topBarView.calcualtePercentage()
        print(topBarView.progressValue)

    }
    
    //MARK: BARN DOOR
    func setupBarnDoor()
    {
        leftDoorLayer.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height)
        leftDoorLayer.backgroundColor = UIColor.cyanColor().CGColor
        layer.addSublayer(leftDoorLayer)
        rightDoorLayer.frame = CGRectMake(frame.size.width*0.5, 0, frame.size.width/2, frame.size.height)
        rightDoorLayer.backgroundColor = UIColor.cyanColor().CGColor
        layer.addSublayer(rightDoorLayer)
        backgroundColor = UIColor.blueColor()
        
        let leftGradient = CAGradientLayer()
        leftGradient.frame = leftDoorLayer.bounds
        leftGradient.startPoint = CGPointZero;
        leftGradient.endPoint = CGPointMake(1, 0);
        let darkColor = UIColor.blackColor().CGColor
        let lightColor = UIColor.clearColor().CGColor
        leftGradient.colors = [lightColor,darkColor,]
        
        let rightGradient = CAGradientLayer()
        rightGradient.frame = rightDoorLayer.bounds
        rightGradient.startPoint = CGPointZero
        rightGradient.endPoint = CGPointMake(1, 0)
    
        rightGradient.colors = [darkColor,lightColor]
        
        leftDoorLayer.addSublayer(leftGradient)
        rightDoorLayer.addSublayer(rightGradient)
        titleLabel!.text = "Hello World!"
        
    }
    
    func barnDoorWithAmount(amount:CGFloat){
        let gradientLeft = leftDoorLayer.sublayers![0]
        let gradientRight = rightDoorLayer.sublayers![0]
        gradientLeft.opacity = Float(amount)
        gradientRight.opacity = Float(amount)
        
        var transformLeft = CATransform3DIdentity
        var transformRight = CATransform3DIdentity
        transformLeft.m34 = 1.0 / -250
        transformRight.m34 = 1.0 / -250
        let pi = CGFloat(M_PI)
        leftDoorLayer.anchorPoint = CGPointMake(0,0.5)
        rightDoorLayer.anchorPoint = CGPointMake(1,0.5)

        //transform = CATransform3DRotate(transform, (90/amount)/100 * (pi / 180.0), 0, 1, 0.0)
        transformLeft = CATransform3DRotate(transformLeft, amount * pi/2, 0, 1, 0.0)
        transformRight = CATransform3DRotate(transformRight, -amount * pi/2, 0, 1, 0.0)

        rightDoorLayer.transform = transformRight
      leftDoorLayer.transform = transformLeft
        
    }

    
}


