//
//  LBBeaconRangingViewController.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit

protocol LBBeaconRangingViewControllerDelegate {
    //func animalSelected(animal: Animal)
}

class LBBeaconRangingViewController: UIViewController
{

    var delegate: LBBeaconRangingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkOrientation()
    }
    
    override func viewWillTransitionToSize(size: CGSize,
                                           withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        // Code here will execute before the rotation begins.
        // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
        coordinator.animateAlongsideTransition({ (context) -> Void in
        },
        completion: { (context) -> Void in
            self.checkOrientation()
            // Code here will execute after the rotation has finished.
                                                // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        }) }

        private func checkOrientation()
        {
            let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            switch orientation
            {
            case UIInterfaceOrientation.Portrait:
                let aView = self.view as? LBBeaconRangingView
                aView!.yOffset = 80.0
            case UIInterfaceOrientation.LandscapeLeft:
                let aView = self.view as? LBBeaconRangingView
                aView!.yOffset = 40.0
            case UIInterfaceOrientation.LandscapeRight:
                let aView = self.view as? LBBeaconRangingView
                aView!.yOffset = 40.0
            default:
                let aView = self.view as? LBBeaconRangingView
                aView!.yOffset = 80.0
            }
            self.view.setNeedsDisplay()

        }
    
}