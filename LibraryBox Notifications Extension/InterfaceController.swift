//
//  InterfaceController.swift
//  LibraryBox Notifications Extension
//
//  Created by David on 13/06/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//


import WatchKit
import WatchConnectivity
import Foundation

///Class to manage watch session.
class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var proximityLabel: WKInterfaceLabel!
    private var defaultSession: WCSession?
    private var timer: NSTimer?
    let myInterval:NSTimeInterval = 15.0
    private var isUpdatingUI:Bool = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.proximityLabel.setText("No box in range")
        if WCSession.isSupported() {
            defaultSession = WCSession.defaultSession()
            defaultSession!.delegate = self
            defaultSession!.activateSession()
        }
        self.sendUIUpdateRequest()
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        self.startTimer()
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        self.endTimer()
        super.didDeactivate()
    }
    
    
    func startTimer()
    {
        if(timer != nil)
        {
            if (timer!.valid) {
                timer!.invalidate()
                timer = nil
            }
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(myInterval,
                                                       target: self,
                                                       selector: #selector(InterfaceController.sendUIUpdateRequest),
                                                       userInfo: myInterval,
                                                       repeats: true)
        isUpdatingUI = true
    }
    
    func endTimer(){
        if(timer != nil)
        {
            timer!.invalidate()
            timer = nil
            isUpdatingUI = !isUpdatingUI
        }
    }
    
    func sendUIUpdateRequest()
    {
        if defaultSession!.reachable != true {
            return
        }
        let payload = ["BeaconRanging": NSNumber(bool: true)]
        defaultSession!.sendMessage(payload, replyHandler: nil, errorHandler: nil)
    }
    
    
    // WCSessionDelegate methods
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let closestBeaconState = message["ClosestBeaconProximity"] {
            self.proximityLabel.setText(closestBeaconState as? String)
        }
    }

}
