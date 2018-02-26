//
//  LBUtilities.swift
//  LibraryBox
//
//  Created by David Haselberger Haselberger on 20/06/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation


///Utility functions (used e. g. in LBMainViewController)
//
/**
 GCD Delay function
 */
func delay(delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}


/**
 Presents an alert via UIAlertController
 */
func showAlert(text : NSString, title : NSString, fn:@escaping ()->Void){
    let alert = UIAlertController(title: title as String, message: text as String, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in fn()}))
    UIApplication.shared.delegate?.window!?.rootViewController?.present(alert, animated: true, completion: nil)
}



