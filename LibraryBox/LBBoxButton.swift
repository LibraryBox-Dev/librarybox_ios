//
//  LBBoxButton.swift
//  LibraryBox
//
//  Created by David on 29/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LBBoxButton: LBRoundedButton {

    override func layoutSubviews()
    {
        super.layoutSubviews()
        if let image = UIImage(named: "LibraryBox_box") {
            self.setImage(image, forState: .Normal)
        }
    }
    
}