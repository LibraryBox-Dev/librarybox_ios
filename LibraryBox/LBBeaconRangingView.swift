//
//  LBBeaconRangingView.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import UIKit
import CoreLocation

class LBBeaconRangingView: UIView
{
    var beacons: [CLBeacon] = []
    var bgLine: CAShapeLayer!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup()
    {
        
    }
    
    func update()
    {
        
    }
}
