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

//Enumerations
///Enum for the state of the  background panel on the right side.
enum SlideOutState {
    case Collapsed
    case RightPanelExpanded
}

///View controller class containing the main view controller holding the map view as well as the beacon ranging view controller that presents a right side panel showing a custom scale for beacon ranging. Manages panel presentation, user interaction by pressing map buttons and KVO for beacon sigma proximity changes.
class LBContainerViewController: UIViewController {
    
    //The map view controller is embedded in a navigation controller showing a navigation bar
    var centerNavigationController: UINavigationController!
    var centerViewController: LBMainViewController!
    
    //State of the right panel
    var currentState: SlideOutState = .Collapsed {
        didSet {
            //Sets a shadow from the center view controller on the background right panel
            let needsShowShadow = currentState != .Collapsed
            showShadowForCenterViewController(needsShowShadow)
        }
    }
    
    var rightViewController: LBBeaconRangingViewController?
    
    //The y-axis offset of the center view controller when the right panel is expanded
    var centerPanelExpandedOffset: CGFloat = UIScreen.mainScreen().bounds.width - 100
    
    //Buttons on the main interface
    var wifiButton: LBWIFIButton!
    var boxButton: LBBoxButton!
    var mapPinButton: LBPinningButton!
    
    //State store of panel
    var rangingViewExpandedStateStore: Bool = false
    
    //Bool check if connected to a LibraryBox
    var connectedToBox: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Center view controller from the main storyboard -> private UIStoryboard extension
        self.centerViewController = UIStoryboard.centerViewController() as LBMainViewController!
        
        //Sets the delegate of the LBMainViewController instance
        self.centerViewController.delegate = self
        
        //Setup KVO for "currentFilteredBeaconSigmaDistances"
        self.centerViewController.addObserver(self, forKeyPath:"currentFilteredBeaconSigmaDistances", options: [NSKeyValueObservingOptions.Old, NSKeyValueObservingOptions.New], context: nil)
        
        //Embedding center view controller in navigation controller
        self.centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(self.centerNavigationController.view)
        addChildViewController(self.centerNavigationController)
        self.centerNavigationController.didMoveToParentViewController(self)
        
        //Listening to notifications on map view appearance as well as box connection and disconnection
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(handleMainViewAppearance), name: "LBMainViewControllerAppeared", object: nil)
        nc.addObserver(self, selector: #selector(setConnectedToBoxBool), name: "LBConnectedToBox", object: nil)
        nc.addObserver(self, selector: #selector(setNotConnectedToBoxBool), name: "LBNotConnectedToBox", object: nil)
        
        //WiFi-Button Implementation
        self.wifiButton = LBWIFIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.wifiButton.translatesAutoresizingMaskIntoConstraints = false
        self.wifiButton.lineWidth = 1.5
        self.wifiButton.activeColor = self.view.tintColor
        self.wifiButton.inactiveColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        self.wifiButton.addTarget(self, action:#selector(wifiButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.wifiButton)
        
        //Autolayout
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
        self.boxButton = LBBoxButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        self.boxButton.translatesAutoresizingMaskIntoConstraints = false
        self.boxButton.lineWidth = 1.5
        self.boxButton.activeColor = self.view.tintColor
        self.boxButton.inactiveColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        self.boxButton.addTarget(self, action:#selector(boxButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.boxButton)
        let secondButtonDict = ["superview":self.view, "secondButton":self.boxButton]
        let boxButtonHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[superview]-(<=1)-[secondButton]", options:NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: secondButtonDict)
        let boxButtonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[secondButton]-25-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: secondButtonDict)
        let boxButtonWidthConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[secondButton(80)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: secondButtonDict)
        let boxButtonHeightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[secondButton(80)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: secondButtonDict)
        self.view.addConstraints(boxButtonVerticalConstraint)
        self.view.addConstraints(boxButtonHorizontalConstraint)
        self.view.addConstraints(boxButtonWidthConstraint)
        self.view.addConstraints(boxButtonHeightConstraint)
        self.view.setNeedsUpdateConstraints()
        
        //Pinning-Button Implementation
        self.mapPinButton = LBPinningButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.mapPinButton.translatesAutoresizingMaskIntoConstraints = false
        self.mapPinButton.lineWidth = 1.5
        self.mapPinButton.activeColor = self.view.tintColor
        self.mapPinButton.inactiveColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        self.mapPinButton.addTarget(self, action:#selector(pinningButtonClicked), forControlEvents: UIControlEvents.TouchUpInside)
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
        
        //Main interface setup
        self.handleMainViewAppearance()
        
        //Check for connection to a LibraryBox
        LBReachabilityService.isConnectedToBox()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /**
     Key-value observation for "currentFilteredBeaconSigmaDistances". If right panel is expanded, set iBeacon distances on beacon ranging view and call UI update drawing function setNeedsDisplay(), send distances to watchkit, if session is active
    */
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentFilteredBeaconSigmaDistances" {
            //set beacon distances in beaconRangingView
            if (self.rightViewController != nil) {
                if(self.currentState == .RightPanelExpanded)
                {
                    if let beaconRangingView = self.rightViewController!.view as? LBBeaconRangingView
                    {
                        beaconRangingView.beaconSigmaDistances = self.centerViewController.currentFilteredBeaconSigmaDistances
                        beaconRangingView.setNeedsDisplay()
                    }
                }
            }
            //send beacon array to watchkit with watchkit connectivity through the watch session in the app delegate
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if (self.centerViewController.currentFilteredBeaconSigmaDistances.count > 0)
            {
                let payload = ["beaconProximities": self.centerViewController.currentFilteredBeaconSigmaDistances]
                if(appDelegate.watchSession!.activationState == .Activated && appDelegate.watchSession!.reachable == true)
                {
                    appDelegate.watchSession!.sendMessage(payload, replyHandler: nil, errorHandler: nil)
                }
            }
        }
    }
    
    /**
     Set y-axis offset on device rotation.
    */
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
    
    /**
     Show shadow when panel is expanded.
    */
    func showShadowForCenterViewController(needsToShowShadow: Bool) {
        if (needsToShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    /**
    Open the Wifi Settings URL when Wifi-Button is clicked.
    */
    @IBAction func wifiButtonClicked(sender: UIButton)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=WIFI")!)
        self.wifiButton.readyToActivate = true
    }
    
    /**
     On button click, check connection to box. If connected, present Web View Controller associated with the storyboard segue "boxContent", otherwise present a sheet informing the user that they are not connected to a LibraryBox and how they can connect to one.
    */
    @IBAction func boxButtonClicked(sender: UIButton)
    {
        if(self.connectedToBox)
        {
            self.centerViewController.performSegueWithIdentifier("boxContent", sender: self)
            self.wifiButton.hidden = true
            self.boxButton.hidden = true
            self.mapPinButton.hidden = true
            if(currentState == .RightPanelExpanded)
            {
                rangingViewExpandedStateStore = true
                self.toggleRightPanel()
            }
        }
        else{
            self.centerViewController.performSegueWithIdentifier("showBoxNotConnected", sender: self)
            self.wifiButton.hidden = true
            self.boxButton.hidden = true
            self.mapPinButton.hidden = true
            if(currentState == .RightPanelExpanded)
            {
                rangingViewExpandedStateStore = true
                self.toggleRightPanel()
            }
        }
    }
    
    /**
    On button click, check connection to a box. If connected, present a sheet informing the user that they need to be connected to the internet if they want to annotate a map location, otherwise present the map pinning view associated with the storyboard segue "showPinningInfo".
    */
    @IBAction func pinningButtonClicked(sender: UIButton)
    {
        if(!self.connectedToBox)
        {
            self.centerViewController.performSegueWithIdentifier("showPinningInfo", sender: self)
        }
        else{
            self.centerViewController.performSegueWithIdentifier("showPinningInfoNotConnected", sender: self)
        }
    }
    
    /**
     Sets boolean connectedToBox to true.
    */
    func setConnectedToBoxBool()
    {
        self.connectedToBox = true
    }

    /**
     Sets boolean connectedToBox to false.
     */
    func setNotConnectedToBoxBool()
    {
        self.connectedToBox = false
    }
    
    /**
     Sets button appearance and panel appearance. Starts Wifi-button animation.
     */
    func handleMainViewAppearance()
    {
        self.wifiButton.hidden = false
        self.boxButton.hidden = false
        self.mapPinButton.hidden = false
        if(rangingViewExpandedStateStore == true)
        {
            self.toggleRightPanel()
            rangingViewExpandedStateStore = false
        }
        if self.centerViewController.ranging
        {
            self.startScanningAnimation()
        }
    }
    
    /**
     Removes KVO on deinit.
    */
    deinit {
        self.centerViewController.removeObserver(self, forKeyPath:"currentFilteredBeaconSigmaDistances")
    }
    
}

//MARK: Extension dealing with showing and hiding the right panel in the main interface.
extension LBContainerViewController: LBMainViewControllerDelegate {
    
    func toggleRightPanel() {
        let notExpanded = (currentState != .RightPanelExpanded)
        if notExpanded {
            self.addRightPanelViewController()
            
            //turn off opacity of wifibutton, if panel is expanded
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
    
    /**
     Add view and view controller of panel to container view.
    */
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
    
    /**
     Animates panel presentation.
    */
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
    
    /**
     Starts Wifi-Button color-fade animation.
     */
    func startScanningAnimation()
    {
        self.wifiButton.readyToActivate = false
    }
    
}

//MARK: UIStoryboard extension to retrieve view controllers
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func rightPanelViewController() -> LBBeaconRangingViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("BeaconRangingViewController") as? LBBeaconRangingViewController
    }
    
    class func centerViewController() -> LBMainViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? LBMainViewController
    }
    
    
}