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
    var centerPanelExpandedOffset: CGFloat = UIScreen.mainScreen().bounds.width - 100
    var wifiButton: LBWIFIButton!
    var boxButton: LBBoxButton!
    var mapPinButton: LBPinningButton!
    let beaconKeyPath = "currentBeaconKeyPath"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centerViewController = UIStoryboard.centerViewController()
        self.centerViewController.delegate = self
        self.centerViewController.addObserver(self, forKeyPath: beaconKeyPath, options: [NSKeyValueObservingOptions.Old, NSKeyValueObservingOptions.New], context: nil)
        self.centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(self.centerNavigationController.view)
        addChildViewController(self.centerNavigationController)
        self.centerNavigationController.didMoveToParentViewController(self)
        
//        TESTING BUTTON
//        let button   = UIButton(type: UIButtonType.System) as UIButton
//        button.frame = CGRectMake(100, 100, 100, 50)
//        button.backgroundColor = UIColor.greenColor()
//        button.setTitle("Test Button", forState: UIControlState.Normal)
//        button.addTarget(self, action: #selector(testAction), forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(button)
        
        //WiFi-Button Implementation
        self.wifiButton = LBWIFIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.wifiButton.translatesAutoresizingMaskIntoConstraints = false
        self.wifiButton.lineWidth = 3.0
        self.wifiButton.activeColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        self.wifiButton.inactiveColor = self.view.tintColor
        self.wifiButton.addTarget(self, action:#selector(wifiButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.wifiButton)
        let buttonDict = ["button":self.wifiButton]
        let buttonHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[button]-25-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttonDict)
        let buttonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[button]-25-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttonDict)
        let buttonWidthConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[button(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttonDict)
        let buttonHeightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[button(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttonDict)
        self.view.addConstraints(buttonVerticalConstraint)
        self.view.addConstraints(buttonHorizontalConstraint)
        self.view.addConstraints(buttonWidthConstraint)
        self.view.addConstraints(buttonHeightConstraint)
        self.view.setNeedsUpdateConstraints()
        
        //Box-Button Implementation
        self.boxButton = LBBoxButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.boxButton.translatesAutoresizingMaskIntoConstraints = false
        self.boxButton.lineWidth = 3.0
        self.boxButton.activeColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        self.boxButton.inactiveColor = self.view.tintColor
        //self.boxButton.addTarget(self, action:#selector(wifiButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.boxButton)
        let secondButtonDict = ["superview":self.view, "secondButton":self.boxButton]
        let boxButtonHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[superview]-(<=1)-[secondButton]", options:NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: secondButtonDict)
        let boxButtonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[secondButton]-25-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: secondButtonDict)
        let boxButtonWidthConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[secondButton(100)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: secondButtonDict)
        let boxButtonHeightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[secondButton(100)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: secondButtonDict)
        self.view.addConstraints(boxButtonVerticalConstraint)
        self.view.addConstraints(boxButtonHorizontalConstraint)
        self.view.addConstraints(boxButtonWidthConstraint)
        self.view.addConstraints(boxButtonHeightConstraint)
        self.view.setNeedsUpdateConstraints()
        
        //Pinning-Button Implementation
        self.mapPinButton = LBPinningButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.mapPinButton.translatesAutoresizingMaskIntoConstraints = false
        self.mapPinButton.lineWidth = 3.0
        self.mapPinButton.activeColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        self.mapPinButton.inactiveColor = self.view.tintColor
        //self.mapPinButton.addTarget(self, action:#selector(wifiButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.mapPinButton)
        let thirdButtonDict = ["pinningButton":self.mapPinButton]
        let pinButtonHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-25-[pinningButton]", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: thirdButtonDict)
        let pinButtonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[pinningButton]-25-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: thirdButtonDict)
        let pinButtonWidthConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[pinningButton(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: thirdButtonDict)
        let pinButtonHeightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[pinningButton(50)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: thirdButtonDict)
        self.view.addConstraints(pinButtonVerticalConstraint)
        self.view.addConstraints(pinButtonHorizontalConstraint)
        self.view.addConstraints(pinButtonWidthConstraint)
        self.view.addConstraints(pinButtonHeightConstraint)
        self.view.setNeedsUpdateConstraints()
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == beaconKeyPath {
            if (self.rightViewController != nil) {
                if let beaconRangingView = self.rightViewController!.view as? LBBeaconRangingView
                {
                    beaconRangingView.beacons = self.centerViewController.currentBeacons
                    beaconRangingView.setNeedsDisplay()
                }
            }
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize,
                                           withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        // Code here will execute before the rotation begins.
        // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
        coordinator.animateAlongsideTransition({ (context) -> Void in
            
            },
            completion: { (context) -> Void in
                self.centerPanelExpandedOffset = UIScreen.mainScreen().bounds.width - 100
                                                // Code here will execute after the rotation has finished.
                                                // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        }) }
    
    func showShadowForCenterViewController(needsToShowShadow: Bool) {
        if (needsToShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    @IBAction func wifiButtonClicked(sender: UIButton)
    {
        //To be tested
        //UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=WIFI")!)
        self.wifiButton.readyToActivate = true
    }
    
//    @IBAction func testAction(sender: UIButton)
//    {
//        self.wifiButton.readyToConnect = false
//    }
    
    deinit {
        self.centerViewController.removeObserver(self, forKeyPath: beaconKeyPath)
    }
    
}

extension LBContainerViewController: LBMainViewControllerDelegate {
    
    func toggleRightPanel() {
        let notExpanded = (currentState != .RightPanelExpanded)
        if notExpanded {
            addRightPanelViewController()
            self.wifiButton.turnOffBGOpacity()
        }
        else{
            self.wifiButton.turnOnBGOpacity()
        }
        self.animateRightPanel(notExpanded)
    }
    
    func collapseSidePanel() {
        switch (currentState) {
        case .RightPanelExpanded:
            self.toggleRightPanel()
        default:
            break
        }
    }
    
    func addChildSidePanelController(sidePanelController: LBBeaconRangingViewController) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        self.addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func addRightPanelViewController() {
        if (self.rightViewController == nil) {
            self.rightViewController = UIStoryboard.rightPanelViewController()
            self.addChildSidePanelController(self.rightViewController!)
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
    
    func startScanningAnimation()
    {
        self.wifiButton.readyToActivate = false
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