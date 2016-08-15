//
//  LBUtilities.swift
//  LibraryBox
//
//  Created by David Haselberger Haselberger on 20/06/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation


///Utility functions (used e. g. in LBMainViewController)

/**
 GCD Delay function
 */
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


/**
 Presents an alert via UIAlertController
 */
func showAlert(text : NSString, title : NSString, fn:()->Void){
    let alert = UIAlertController(title: title as String, message: text as String, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in fn()}))
    UIApplication.sharedApplication().delegate?.window!?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
}



