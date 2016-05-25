//
//  LBContainerViewController.swift
//  LibraryBox
//
//  Created by David on 24/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

enum SlideOutState {
    case Collapsed
    case RightPanelExpanded
}

class LBContainerViewController: UIViewController {
    
    var centerNavigationController: UINavigationController!
    var centerViewController: LBMainViewController!
    var currentState: SlideOutState = .Collapsed {
        didSet {
            let needsShowShadow = currentState != .Collapsed
            showShadowForCenterViewController(needsShowShadow)
        }
    }
    var rightViewController: LBBeaconRangingViewController?
    var centerPanelExpandedOffset: CGFloat = UIScreen.mainScreen().bounds.width - 300
    var wifiButton: LBWIFIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        //WiFi-Button Implementation
        self.wifiButton = LBWIFIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.wifiButton.translatesAutoresizingMaskIntoConstraints = false
        self.wifiButton.lineWidth = 5.0
        self.wifiButton.connectionColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        self.wifiButton.scanningColor = self.view.tintColor
        self.wifiButton.readyToConnect = false
        self.wifiButton.setTitle("Connect", forState: UIControlState.Normal)
        self.wifiButton.setTitleColor(self.view.tintColor, forState: UIControlState.Normal)
        self.wifiButton.addTarget(self, action:#selector(wifiButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.wifiButton)
        
        let buttonDict = ["button":self.wifiButton]
        let buttonHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[button]-50-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttonDict)
        let buttonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[button]-100-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttonDict)
        self.view.addConstraints(buttonVerticalConstraint)
        self.view.addConstraints(buttonHorizontalConstraint)
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func viewWillTransitionToSize(size: CGSize,
                                           withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        // Code here will execute before the rotation begins.
        // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
        coordinator.animateAlongsideTransition({ (context) -> Void in
            
            },
            completion: { (context) -> Void in
                self.centerPanelExpandedOffset = UIScreen.mainScreen().bounds.width - 300
                                                // Code here will execute after the rotation has finished.
                                                // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        }) }
    
    func showShadowForCenterViewController(needsShowShadow: Bool) {
        if (needsShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    @IBAction func wifiButtonClicked(sender: UIButton)
    {
        //To be tested
        //UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=WIFI")!)
        self.wifiButton.readyToConnect = true
    }
    
}

extension LBContainerViewController: LBMainViewControllerDelegate {
    
    func toggleRightPanel() {
        let notExpanded = (currentState != .RightPanelExpanded)
        if notExpanded {
            addRightPanelViewController()
        }
        animateRightPanel(notExpanded)
    }
    
    func collapseSidePanel() {
        switch (currentState) {
        case .RightPanelExpanded:
            toggleRightPanel()
        default:
            break
        }
    }
    
    func addChildSidePanelController(sidePanelController: LBBeaconRangingViewController) {
        sidePanelController.delegate = centerViewController
        view.insertSubview(sidePanelController.view, atIndex: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func addRightPanelViewController() {
        if (rightViewController == nil) {
            rightViewController = UIStoryboard.rightPanelViewController()
            addChildSidePanelController(rightViewController!)
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .RightPanelExpanded
            animateCenterPanelXPosition(-CGRectGetWidth(centerNavigationController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { _ in
                self.currentState = .Collapsed
                self.rightViewController!.view.removeFromSuperview()
                self.rightViewController = nil;
            }
        }
    }
    
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func rightPanelViewController() -> LBBeaconRangingViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("BeaconRangingViewController") as? LBBeaconRangingViewController
    }
    
    class func centerViewController() -> LBMainViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? LBMainViewController
    }
    
}