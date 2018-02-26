//
//  LBBoxContentNavigationController.swift
//  LibraryBox
//
//  Created by David Haselberger on 15/07/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation
import UIKit

///Navigation controller for the box content web view controller
class LBBoxContentNavigationController: UINavigationController
{
    /**
     Dismisses the view controller.
    */
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        print("dismissing")
        if((self.presentedViewController) != nil)
        {
            super.dismiss(animated: flag, completion: completion)
        }
    } 
}
