//
//  InterfaceController.swift
//  LibraryBox Notifications Extension
//
//  Created by David on 13/06/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//


import WatchKit
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    private var defaultSession: WCSession?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        if WCSession.isSupported() {
            defaultSession = WCSession.defaultSession()
            defaultSession!.delegate = self
            defaultSession!.activateSession()
        }
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    // MARK: WCSessionDelegate methods
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        //let notificationCenter = NSNotificationCenter.defaultCenter()
        //notificationCenter.postNotificationName(NATHiBeaconsDelegate.NATHiBeaconsWatchNotificationName, object: self, userInfo: message)
    }

}
