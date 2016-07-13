//
//  LBPinningPopoverViewController.swift
//  LibraryBox
//
//  Created by David on 13/07/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol LBPinningPopoverDelegate
{
    func pinAddress()
}

class LBPinningPopoverViewController: UIViewController {

    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var pinCloseBoxButton: UIButton!
    @IBOutlet weak var addAddressButton: UIButton!
    
    var delegate: LBPinningPopoverDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePopoverUI(_:)), name: "LBCurrentClosestBeacon", object: nil)
        pinCloseBoxButton.userInteractionEnabled = false
        addAddressButton.selected = true
    }

    func updatePopoverUI(notification: NSNotification)
    {
        let theBeacon: CLBeacon = notification.object as! CLBeacon
        var proximityString: String = "NOT IN RANGE"
        switch theBeacon.proximity {
        case .Far:
            proximityString = "FAR"
        case .Near:
            proximityString = "NEAR"
        case .Immediate:
            proximityString = "CLOSE"
        case .Unknown:
            proximityString = "NOT IN RANGE"
        }
        let beaconAccuracy = Int(theBeacon.accuracy)
        let proximityStringAppearance = proximityString + " (~" + String(beaconAccuracy) + "m)"
        proximityLabel.text = proximityStringAppearance
        if(proximityString == "NEAR")
        {
            pinCloseBoxButton.userInteractionEnabled = true
            pinCloseBoxButton.selected = true
        }
        else if(proximityString == "CLOSE")
        {
            pinCloseBoxButton.userInteractionEnabled = true
            pinCloseBoxButton.selected = true
        }
        else
        {
            pinCloseBoxButton.userInteractionEnabled = false
            pinCloseBoxButton.selected = false
        }
        pinCloseBoxButton.setNeedsDisplay()
    }
    
    @IBAction func pinCloseBox(sender: AnyObject!)
    {
    
    }
    
    @IBAction func addAddress(sender: AnyObject!)
    {
        self.dismissViewControllerAnimated(true, completion:{
            self.delegate?.pinAddress()
        })
    }
    
}