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
    let centerPanelExpandedOffset: CGFloat = UIScreen.mainScreen().bounds.width - 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        //WiFi-Button Implementation
        let button   = UIButton(type: UIButtonType.System) as UIButton
        //right position for button: x, y, width, height!!!
        button.frame = CGRectMake(screenSize.width - 150, screenSize.height - 300, 100, 50)
        button.backgroundColor = UIColor.greenColor()
        button.setTitle("Test Button", forState: UIControlState.Normal)
        button.addTarget(self, action:#selector(wifiButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func showShadowForCenterViewController(needsShowShadow: Bool) {
        if (needsShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    @IBAction func wifiButtonClicked(sender: UIButton)
    {
        
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