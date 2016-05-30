//
//  LBRoundedButton.swift
//  LibraryBox
//
//  Created by David on 29/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit

class LBRoundedButton: UIButton, UIViewControllerTransitioningDelegate {
    
    var outerRingShape: CAShapeLayer!
    var circleBGShape: CAShapeLayer!
    var lineWidth: CGFloat = 3.0{
        didSet {
            updateLayerProperties()
        }
    }
    @IBInspectable var activeColor: UIColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1) {
        didSet {
            updateLayerProperties()
        }
    }
    @IBInspectable var inactiveColor: UIColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1) {
        didSet {
            updateLayerProperties()
        }
    }
    var readyToActivate: Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    private func updateLayerProperties()
    {
        if outerRingShape != nil
        {
            outerRingShape.lineWidth = lineWidth
            outerRingShape.strokeColor = readyToActivate ? activeColor.CGColor : inactiveColor.CGColor
        }
        if circleBGShape != nil
        {
            circleBGShape.lineWidth = lineWidth
            circleBGShape.strokeColor = readyToActivate ? activeColor.CGColor : inactiveColor.CGColor
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
            circleBGShape.strokeColor = inactiveColor.CGColor
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
            outerRingShape.strokeColor = inactiveColor.CGColor
            outerRingShape.fillColor = UIColor.clearColor().CGColor
            outerRingShape.position = CGPoint(x: CGRectGetWidth(self.bounds)/2, y: CGRectGetHeight(self.bounds)/2)
            outerRingShape.transform = CATransform3DIdentity
            outerRingShape.opacity = 1.0
            self.layer.addSublayer(outerRingShape)
        }
        
        
    }
    
    private func frameWithInset() -> CGRect {
        return CGRectInset(self.bounds, lineWidth/2, lineWidth/2)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
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