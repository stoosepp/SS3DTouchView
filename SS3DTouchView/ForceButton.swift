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
    func updateForceLabel(_ currentforceValue: CGFloat)
}

enum ForceButtonType: Int {
    case dropShadow = 0
    case innerShadow = 1
    case flatShadow = 2
    case sizeScale = 3
    case depthOfField = 4
    case color = 5
    case progressBar = 6
    case circleProgress = 7
    case pincushion = 8
    case barnDoor = 9
    case none = 10
}



class ForceButton: UIButton {

    //You can Set These
    var forceButtonType: ForceButtonType
    var shadowColor: UIColor = UIColor.darkGray
    var shadowOpacity: Float = 0.8
    var maxShadowOffset: CGSize = CGSize(width: 10, height: 10)
    var maxShadowRadius: CGFloat = 10.0
    var minShadowRadius: CGFloat = 2.0
    
    var bottomHit:Bool
    
    //Properties (Don't mess with these)
    fileprivate let maxForceValue: CGFloat = 100
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
     
        forceButtonType = .dropShadow
        bottomHit = false
        
        super.init(coder: aDecoder)!

    }
    
    //MARK: INITIALIZE BUTTON
    func initializeButton(_ withType: ForceButtonType)
    {
        backgroundColor = UIColor.darkGray
        forceButtonType = withType
        buttonCenter = center
        resetButton()
        switch withType {
        case .dropShadow:
            dropShadowWithAmount(0.0)
            print("Setting Up Shadow Above")
        case .innerShadow:
            layer.addSublayer(innerShadowLayer)
            innerShadowWithAmount(0.0)
            print("Setting Up Shadow Below")
        case .flatShadow:
            //layer.cornerRadius = 20 //Should accomodate for this
            setupFlatShadow()
            flatShadowWithAmount(0.0)
            print("Setting Up Flat Shadow Above")
        case .sizeScale:
            print("To Fill in")
            scaleWithAmount(amount: 0.0, location: "topRight")
        case .depthOfField:
            print("To Fill in")
        case .color:
            print("To Fill in")
        case .progressBar:
            setupTopBar()
            topBarWithAmount(0.0)
        case .circleProgress:
            setupCircle()
            circleWithAmount(0.0)
        case .pincushion:
            setupPincushionDistortion()
        case .barnDoor:
            setupBarnDoor()
            barnDoorWithAmount(0.0)
        default:
            print("Not Setting anything Up")
        }
    }
    
    func resetButton()
    {
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
        shadowShapeLayer.fillColor = shadowColor.cgColor
        layer.removeAllAnimations()
        setBackgroundImage(UIImage(), for: state)
        
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
        initializeButton(.dropShadow)
        delegate?.updateForceLabel(0.0)
     
    }
    //MARK: HANDLE TOUCHES
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        handleForceWithTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        handleForceWithTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        switch forceButtonType {
        case .dropShadow:
            dropShadowWithAmount(0.0)
        case .innerShadow:
            innerShadowWithAmount(0.0)
        case .flatShadow:
            flatShadowWithAmount(0.0)
        case .sizeScale:
            backgroundColor = bgColor
        case .depthOfField:
            blurWithAmount(0.0)
            self.unBlur()
        case .color:
            darkenColorWithAmount(0.0)
        case .pincushion:
            pincushionDistortionWithAmount(0, position: CGPoint(x: 0, y: 0))
        case .circleProgress:
            circleWithAmount(0.0)
        case .progressBar:
            topBarWithAmount(0.0)
        case .barnDoor:
            barnDoorWithAmount(0.0)
        default:
            dropShadowWithAmount(0.0)
        }
        if forceButtonType == .circleProgress{
            backgroundColor = .clear
        }
        else{
              backgroundColor = bgColor
        }
        delegate?.updateForceLabel(0)
    }
    
    func handleForceWithTouches(_ touches: Set<UITouch>) {
        if touches.count != 1 {
            return
        }
        guard let touch = touches.first else {
            return
        }
        switch forceButtonType {
        case .dropShadow:
            dropShadowWithAmount(touch.strength)
        case .innerShadow:
            innerShadowWithAmount(touch.strength)
        case .flatShadow:
            flatShadowWithAmount(touch.strength)
        case .sizeScale:
            scaleWithAmount(amount: touch.strength, location: "topRight")
        case .depthOfField:
            blurWithAmount(touch.strength)
        case .color:
            lightenColorWithAmount(touch.strength)
            
        case .pincushion:
            pincushionDistortionWithAmount(touch.strength, position: touch.location(in: self))
        case .circleProgress:
            circleWithAmount(touch.strength)
        case .progressBar:
            topBarWithAmount(touch.strength)
        case .barnDoor:
            barnDoorWithAmount(touch.strength)
        default:
            print("Button has no type")
        }
        delegate?.updateForceLabel(touch.percentStrength)
        if bottomHit == true{
            if touch.strength == 1.0
            {
                superview!.backgroundColor = UIColor.red
            }
            else{
                superview!.backgroundColor = UIColor.white
            }
        }
  
    }

    //MARK: DROP SHADOW
    func dropShadowWithAmount(_ amount: CGFloat) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: maxShadowOffset.width - (maxShadowOffset.width * amount),
            height: maxShadowOffset.height - (maxShadowOffset.height * amount))
        layer.shadowRadius = maxShadowRadius - (maxShadowRadius * amount) + minShadowRadius
    }
    
    //MARK: FLAT SHADOW ABOVE
    func flatShadowWithAmount(_ amount:CGFloat){
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
        buttonShapeLayer.fillColor = UIColor.lightGray.cgColor
        
       //addMovementAnimation() //This is where the problem lies
        flatShadowLayer.addSublayer(shadowShapeLayer)
        self.frame.origin = CGPoint(x: buttonShapeLayer.frame.origin.x - maxShadowOffset.width, y: buttonShapeLayer.frame.origin.y - maxShadowOffset.height)
    }
    
    
    func updateShadowPathWithAmount(_ amount:CGFloat){
        
        backgroundColor = UIColor.clear
    
        let newButtonPath = CGPath(rect: CGRect(x: bounds.origin.x + (maxShadowOffset.width * amount), y: bounds.origin.y + (maxShadowOffset.height * amount), width: bounds.width, height: bounds.height), transform: nil)
        buttonShapeLayer.path = newButtonPath
        
        
        let newShadowPath = CGMutablePath()
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
            print("Shadow on Bottom Right")
            newShadowPath.move(to: CGPoint(x: topRightPointx, y: topRightPointy))//Top Right
            newShadowPath.addLine(to: CGPoint(x: topRightShadowPointx, y:topRightShadowPointy))//Shadow of Top Right)
            newShadowPath.addLine(to: CGPoint(x: bottomRightShadowPointx, y:bottomRightShadowPointy)) //Shadow of Bottom Right
            newShadowPath.addLine(to: CGPoint(x:  bottomLeftShadowPointx, y: bottomLeftShadowPointy)) //Shadow of Bottom Left
            newShadowPath.addLine(to: CGPoint(x: bottomLeftPointx,y:  bottomLeftPointy)) //Bottom Left
            newShadowPath.addLine(to: CGPoint(x: bottomRightPointx,y:  bottomRightPointy)) //Bottom Right
        }
        else if maxShadowOffset.width < 0 && maxShadowOffset.height < 0
        {
            print("Shadow on Top Left")
            newShadowPath.move(to: CGPoint(x: topRightPointx, y: topRightPointy)) //Top Right
            newShadowPath.addLine(to: CGPoint(x:  topRightShadowPointx,y:  topRightShadowPointy))//Shadow of Top Right
            newShadowPath.addLine(to: CGPoint(x:  topLeftShadowPointx,y:  topLeftShadowPointy)) //Shadow of Top Left
            newShadowPath.addLine(to: CGPoint(x:  bottomLeftShadowPointx, y: bottomLeftShadowPointy)) //Shadow of Bottom Left
            newShadowPath.addLine(to: CGPoint(x:  bottomLeftPointx, y: bottomLeftPointy)) //Bottom Left
            newShadowPath.addLine(to: CGPoint(x: topLeftPointx, y: topLeftPointy)) //Top Left
        }
        else if maxShadowOffset.width > 0 && maxShadowOffset.height < 0{
            print("Shadow on Top Right")
            newShadowPath.move(to: CGPoint(x: topRightPointx, y: topRightPointy))//Top Right
            newShadowPath.addLine(to: CGPoint(x: bottomRightPointx, y: bottomRightPointy))//Bottomr Right
            newShadowPath.addLine(to: CGPoint(x:  bottomRightShadowPointx,y:  bottomRightShadowPointy))//Shadow of Bottom Right
            newShadowPath.addLine(to: CGPoint(x: topRightShadowPointx, y: topRightShadowPointy))//Shadow of Top Right
            newShadowPath.addLine(to: CGPoint(x: topLeftShadowPointx, y: topLeftShadowPointy))//Shadow of Top Left
            newShadowPath.addLine(to: CGPoint(x: topLeftPointx, y: topLeftPointy))//Top Left
        }
        else if maxShadowOffset.width < 0 && maxShadowOffset.height > 0{
            print("Shadow on Top Right")
            newShadowPath.move(to: CGPoint(x:topLeftPointx,y: topLeftPointx)) //Top Left
            newShadowPath.addLine(to: CGPoint(x: topLeftShadowPointx, y: topLeftShadowPointy))//Shadow of Top Left
            newShadowPath.addLine(to: CGPoint(x: bottomLeftShadowPointx, y: bottomLeftShadowPointy))//Shadow of Bottom Left
            newShadowPath.addLine(to: CGPoint(x: bottomRightShadowPointx, y: bottomRightShadowPointy))//Shadow of Bottom Right
            newShadowPath.addLine(to: CGPoint(x: bottomRightPointx, y: bottomRightPointy))//Bottomr Right
            newShadowPath.addLine(to: CGPoint(x: bottomLeftPointx, y: bottomLeftPointy))//Bottom Left
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
        layer.add(animationX, forKey: "translationAnimationX")
        layer.add(animationY, forKey: "translationAnimationY")
        layer.speed = 0
    }
    
    
    //MARK: INNER SHADOW
    func innerShadowWithAmount(_ amount: CGFloat) {
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
        let cutout = UIBezierPath(rect: innerShadowLayer.bounds).reversing()
        path.append(cutout)
        innerShadowLayer.shadowPath = path.cgPath
        innerShadowLayer.masksToBounds = true
        
        // Shadow properties
        innerShadowLayer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        innerShadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        innerShadowLayer.shadowOpacity = 1
        innerShadowLayer.shadowRadius = (maxShadowRadius * amount) + minShadowRadius
        //print("Shadow Radius is \(extraShadowLayer.shadowRadius)")
        
        //This next line darkens the color of the button as it moves below the plane by a factor of a quarter
        darkenColorWithAmount(amount / 10)
        
    }
    
    func darkenColorWithAmount(_ amount:CGFloat)
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
    //MARK: SIZE SCALE
    
    
    func scaleWithAmount(amount:CGFloat, location:String){
        print("Button has \(layer.sublayers?.count) sublayers")
        if layer.sublayers?.count != nil{
            for layer in layer.sublayers!{
                layer.removeFromSuperlayer()
            }
        }
        let colorLayer = CALayer()
        colorLayer.frame = bounds
        colorLayer.backgroundColor = bgColor.cgColor
        
        backgroundColor = UIColor.clear
        print(amount)
        let finalSize = CGSize(width: frame.size.width/2, height: frame.size.height/2)
        let newWidth = frame.size.width - (finalSize.width * amount)
        print(newWidth)
        let newHeight = frame.size.height - (finalSize.height * amount)
        colorLayer.frame.size = CGSize(width: newWidth, height: newHeight)
       layer.addSublayer(colorLayer)
        if location == "topRight"{
            colorLayer.frame.origin.x += (frame.size.width - newWidth)
        }
        
        

    }
    
    
    //MARK: Depth OF FIELD
    func blurWithAmount(_ amount:CGFloat){
        self.removeBlur()
       self.blurView(amount * 5)
        print("Blurring")
    }
    
    
    //MARK: COLOR
    //Light gray is 170 170 170
    //Dark gray is 85 85 85
    func lightenColorWithAmount(_ amount:CGFloat)
    {
        //Make the Button darker the lower it gets
        let lightGrayrgb = UIColor.lightGray.rgb()
        let darkGrayrgb = UIColor.darkGray.rgb()
        
        let redValueDiff = CGFloat(lightGrayrgb!.red - darkGrayrgb!.red) * amount
        let greenValueDiff = CGFloat(lightGrayrgb!.green - darkGrayrgb!.green) * amount
        let blueValueDiff = CGFloat(lightGrayrgb!.blue - darkGrayrgb!.blue) * amount
        
        
        let finalRed = CGFloat(darkGrayrgb!.red) + redValueDiff
        let finalGreen = CGFloat(darkGrayrgb!.green) + greenValueDiff
        let finalBlue = CGFloat(darkGrayrgb!.blue) + blueValueDiff
        
        print("R:\(finalRed) G:\(finalGreen) B:\(finalBlue)")
    
    
        backgroundColor = UIColor(red: finalRed/255, green: finalGreen/255, blue: finalBlue/255, alpha: 1)
    }
    
    
    //MARK: PROGRESS BAR
    func setupTopBar()
    {
        topBarView.frame.size.width = self.frame.size.width
        topBarView.barColor = UIColor.lightGray
        topBarView.barThickness = self.frame.size.height / 5
        topBarView.frame.size.height = topBarView.barThickness
        topBarView.frame.origin = CGPoint(x: 0, y: 0)
        topBarView.trackColor = bgColor
        self.addSubview(topBarView)
    }
    
    func topBarWithAmount(_ amount:CGFloat){
        topBarView.progressValue = amount * 100
        topBarView.calcualtePercentage()
        print(topBarView.progressValue)
    }
    
    //MARK: CIRCLE PROGRESS
    func setupCircle()
    {
        ringProgressView.frame = self.bounds
        ringProgressView.backgroundColor = .clear
        backgroundColor = .clear
        ringProgressView.updateProgressCircle(0.0)
        ringProgressView.resetProgressCircle()
        ringProgressView.circleColor = bgColor
        ringProgressView.progressColor = UIColor.lightGray
        ringProgressView.lineWidth = 20
        self.addSubview(ringProgressView)
    }
    
    func circleWithAmount(_ amount:CGFloat){
        let amountFloat = Float(amount) * 100
        ringProgressView.updateProgressCircle(amountFloat)
    }
    
    //MARK: PINCUSHION
    
    func setupPincushionDistortion()
    {
        pinImageView.frame.origin = CGPoint(x:0, y: 0)
        pinImageView.frame.size = frame.size
        //pinImageView.image = backgroundImage
        pinImageView.image = UIImage(named: "checkerboard.jpg")
        pinImageView.contentMode = .scaleToFill
        addSubview(pinImageView)

        print("Setting up pincushion")
        
        UIGraphicsBeginImageContext(bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        backgroundImage = viewImage!

    }
    
    func pincushionDistortionWithAmount(_ amount:CGFloat, position:CGPoint){
        
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
        var newImage:UIImage = UIImage(ciImage: filter.outputImage!)
        //ORIGINAL
        //let newCGIImage = CIContext(options:nil).createCGImage(filter.outputImage!, fromRect:filter.outputImage!.extent)

        let newCGIImage = CIContext(options:nil).createCGImage(filter.outputImage!, from:pinImageView.frame)
        //print(filter.outputImage!.extent)

        let imageViewWidth = pinImageView.frame.size.width
        let imageViewHeight = pinImageView.frame.size.height
        let imageWidth = newImage.size.width
        let imageHeight = newImage.size.height
        
        if imageWidth > imageViewWidth || imageHeight > imageViewHeight{
            //print("Image is wider than ImageView")
            //Code to crop image to fit in imageView
            newImage = cropToBounds(newCGIImage!, width: imageViewWidth, height: imageViewHeight)
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
    
    func cropToBounds(_ image: CGImage, width: CGFloat, height: CGFloat) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image)
        let contextSize: CGSize = pinImageView.bounds.size//contextImage.size
        
        let posX: CGFloat = 0.0
        let posY: CGFloat = 0.0

        //ORIGINAL
        //let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)

        //MY VERSION
        let rect: CGRect = CGRect(x: posX, y: posY, width: contextSize.width, height: contextSize.height)
        //print("Rect:\(rect)")
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let imageUI: UIImage = UIImage(cgImage: imageRef)
        let upsideDownImage: UIImage = UIImage(cgImage: imageRef, scale: imageUI.scale, orientation: imageUI.imageOrientation)
        let FinalImage = UIImage(cgImage: upsideDownImage.cgImage!, scale: 1.0, orientation: .downMirrored)

        
        return FinalImage
    }

    
 
    
    //MARK: BARN DOOR
    func setupBarnDoor()
    {
        
        //Add black background
//        let backgroundLayer = CALayer()
//        backgroundLayer.frame = bounds
//        backgroundLayer.backgroundColor = UIColor.black.cgColor
//        layer.addSublayer(backgroundLayer)
        
        print("Setting Up Barn Door")
        leftDoorLayer.frame = CGRect(x: frame.origin.x - frame.size.width/4, y: frame.origin.y, width: frame.size.width/2, height: frame.size.height)
        leftDoorLayer.backgroundColor = bgColor.cgColor
        layer.addSublayer(leftDoorLayer)
       
       
        rightDoorLayer.frame = CGRect(x: frame.size.width/2 + frame.size.width/4, y: 0, width: frame.size.width/2, height: frame.size.height)
        rightDoorLayer.backgroundColor = bgColor.cgColor
        layer.addSublayer(rightDoorLayer)
        
        
        print("Left:\(leftDoorLayer.frame) Right:\(rightDoorLayer.frame) Self:\(frame)")
 
        
       
      
        
        let darkColor = UIColor.black.cgColor
        let lightColor = UIColor.clear.cgColor
        
        
        let leftGradient = CAGradientLayer()
        leftGradient.frame = leftDoorLayer.bounds
        leftGradient.startPoint = CGPoint.zero;
        leftGradient.endPoint = CGPoint(x: 1, y: 0);
        
        leftGradient.colors = [lightColor,darkColor]
        leftGradient.opacity = 0
        
        let rightGradient = CAGradientLayer()
        rightGradient.frame = rightDoorLayer.bounds
        rightGradient.startPoint = CGPoint.zero
        rightGradient.endPoint = CGPoint(x: 1, y: 0)
    
        rightGradient.colors = [darkColor,lightColor]
        rightGradient.opacity = 0
 
        leftDoorLayer.addSublayer(leftGradient)
        rightDoorLayer.addSublayer(rightGradient)
 
    }
    
    func barnDoorWithAmount(_ amount:CGFloat){
        backgroundColor = UIColor.black
        
        let gradientLeft = leftDoorLayer.sublayers![0]
        let gradientRight = rightDoorLayer.sublayers![0]
        gradientLeft.opacity = Float(amount)
        gradientRight.opacity = Float(amount)
       
        var transformLeft = CATransform3DIdentity
        var transformRight = CATransform3DIdentity
        transformLeft.m34 = 1.0 / -250
        transformRight.m34 = 1.0 / -250
        let pi = CGFloat(M_PI)
        leftDoorLayer.anchorPoint = CGPoint(x: 0,y: 0.5)
        rightDoorLayer.anchorPoint = CGPoint(x: 1,y: 0.5)

        //transform = CATransform3DRotate(transform, (90/amount)/100 * (pi / 180.0), 0, 1, 0.0)
        transformLeft = CATransform3DRotate(transformLeft, amount * pi/2, 0, 1, 0.0)
        transformRight = CATransform3DRotate(transformRight, -amount * pi/2, 0, 1, 0.0)

        rightDoorLayer.transform = transformRight
      leftDoorLayer.transform = transformLeft
        
    }

    
}



