//
//  LBPinningButton.swift
//  LibraryBox
//
//  Created by David on 30/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LBPinningButton: LBRoundedButton {
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let layer = CALayer()
        layer.frame = self.bounds
        if let image = UIImage(named: "addlocation") {
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
    
}