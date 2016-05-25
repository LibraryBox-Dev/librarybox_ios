//
//  LBWIFIButton.swift
//  LibraryBox
//
//  Created by David on 25/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit




@IBDesignable
class LBWIFIButton: UIButton, UIViewControllerTransitioningDelegate {
    
    private var outerRingShape: CAShapeLayer!
    private var circleBGShape: CAShapeLayer!
    
    var lineWidth: CGFloat = 5.0{
        didSet {
            updateLayerProperties()
        }
    }
    
    var connectionColor: UIColor = UIColor(red: 0.0, green: 100/255, blue: 1.0, alpha: 1) {
        didSet {
            updateLayerProperties()
        }
    }
    
    var scanningColor: UIColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1) {
        didSet {
            updateLayerProperties()
        }
    }
    
    var readyToConnect: Bool = false {
        didSet {
            return self.readyToConnect ? connectionReady() : scanning()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        self.clipsToBounds = true
        let image = createImage(self.bounds)
        self.setBackgroundImage(image, forState: UIControlState.Normal)
    }
    
    private func updateLayerProperties()
    {
        if outerRingShape != nil
        {
            outerRingShape.lineWidth = lineWidth
            outerRingShape.strokeColor = readyToConnect ? connectionColor.CGColor : scanningColor.CGColor
        }
        if circleBGShape != nil
        {
                circleBGShape.lineWidth = lineWidth
                circleBGShape.strokeColor = readyToConnect ? connectionColor.CGColor : scanningColor.CGColor
        }
        
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        createLayersIfNeeded()
        updateLayerProperties()
    }
    
    private func createLayersIfNeeded() {
        if circleBGShape == nil {
            circleBGShape = CAShapeLayer()
            circleBGShape.path = UIBezierPath(ovalInRect:frameWithInset()).CGPath
            circleBGShape.bounds = frameWithInset()
            circleBGShape.lineWidth = lineWidth
            circleBGShape.strokeColor = scanningColor.CGColor
            circleBGShape.fillColor = UIColor.whiteColor().CGColor
            circleBGShape.position = CGPoint(x: CGRectGetWidth(self.bounds)/2, y: CGRectGetHeight(self.bounds)/2)
            circleBGShape.transform = CATransform3DIdentity
            circleBGShape.opacity = 0.4
            self.layer.addSublayer(circleBGShape)
        }
        
        if outerRingShape == nil {
            outerRingShape = CAShapeLayer()
            outerRingShape.path = UIBezierPath(ovalInRect:frameWithInset()).CGPath
            outerRingShape.bounds = frameWithInset()
            outerRingShape.lineWidth = lineWidth
            outerRingShape.strokeColor = scanningColor.CGColor
            outerRingShape.fillColor = UIColor.clearColor().CGColor
            outerRingShape.position = CGPoint(x: CGRectGetWidth(self.bounds)/2, y: CGRectGetHeight(self.bounds)/2)
            outerRingShape.transform = CATransform3DIdentity
            outerRingShape.opacity = 0.8
            self.layer.addSublayer(outerRingShape)
        }
        
        
    }
    
    private func frameWithInset() -> CGRect {
        return CGRectInset(self.bounds, lineWidth/2, lineWidth/2)
    }
    
    func createImage(rect: CGRect) -> UIImage{
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context,  UIColor.clearColor().CGColor);
        CGContextFillEllipseInRect(context, CGRectInset(rect, 4, 4));
        CGContextStrokePath(context);
        let image =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return image
    }
    
    private func scanning(){
        self.titleLabel?.removeFromSuperview()
        //CAAnimation
    }
    
    private func connectionReady(){
        self.addSubview(self.titleLabel!)
        //CAAnimation
    }
    
    
    override func animationDidStart(anim: CAAnimation) {
        disableTouch()
    }
    
    private func disableTouch() {
        self.userInteractionEnabled = false
    }
    
    private func enableTouch() {
        self.userInteractionEnabled = true
    }

    
    
    
}