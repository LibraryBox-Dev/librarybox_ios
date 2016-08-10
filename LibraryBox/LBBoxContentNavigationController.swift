//
//  LBBoxContentNavigationController.swift
//  LibraryBox
//
//  Created by David on 15/07/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation
import UIKit

class LBBoxContentNavigationController: UINavigationController
{
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        print("dismissing")
        if((self.presentedViewController) != nil)
        {
            super.dismissViewControllerAnimated(flag, completion: completion)
        }
    } 
}