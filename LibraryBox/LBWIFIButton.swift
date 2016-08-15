//
//  LBWIFIButton.swift
//  LibraryBox
//
//  Created by David Haselberger on 25/05/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation
import UIKit

///Botton class for the Wifi-button in the map interface.
@IBDesignable
class LBWIFIButton: LBRoundedButton {
    
    override var readyToActivate: Bool {
        didSet {
            return self.readyToActivate ? connectionReady() : scanning()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /**
     Overridden function adding the button image in a layer.
     */
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let layer = CALayer()
        layer.frame = self.bounds
        if let image = UIImage(named: "wifinotification") {
            layer.contents = image.CGImage
        }
        layer.contentsGravity = kCAGravityResizeAspect
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.magnificationFilter = kCAFilterLinear
        layer.geometryFlipped = false
        layer.backgroundColor = UIColor.clearColor().CGColor
        layer.opacity = 1.0
        layer.hidden = false
        layer.masksToBounds = false
        layer.shouldRasterize = false
        layer.cornerRadius = 100.0
        layer.borderWidth = 12.0
        layer.borderColor = UIColor.clearColor().CGColor
        layer.transform = CATransform3DMakeScale(0.8, 0.8, 1)
        self.layer.addSublayer(layer)
        
    }
    
    
    func turnOffBGOpacity()
    {
        if circleBGShape != nil {
            circleBGShape.opacity = 1.0
        }
    }
    
    func turnOnBGOpacity()
    {
        if circleBGShape != nil {
            circleBGShape.opacity = 0.4
        }
    }
    
    private func frameWithInset() -> CGRect {
        return CGRectInset(self.bounds, lineWidth/2, lineWidth/2)
    }
    
    override func drawRect(rect: CGRect) {
            super.drawRect(rect)
    }
    
    /**
     Scanning for beacons - Color-Fade Animation. This function starts the animation.
     */
    private func scanning(){
        let wifiFillColorAnimation = CABasicAnimation(keyPath: "fillColor")
        wifiFillColorAnimation.toValue = activeColor.CGColor
        wifiFillColorAnimation.duration = 1.5
        wifiFillColorAnimation.autoreverses = true
        wifiFillColorAnimation.repeatCount = .infinity
        if (self.outerRingShape) != nil
        {
            outerRingShape.addAnimation(wifiFillColorAnimation, forKey: "scanFill")
        }
    }
    
    /**
      If this method is called, animations are stopped.
     */
    private func connectionReady(){
        outerRingShape.removeAllAnimations()
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