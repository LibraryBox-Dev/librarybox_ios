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