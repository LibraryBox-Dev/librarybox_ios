//
//  InterfaceController.swift
//  LibraryBox Notifications Extension
//
//  Created by David Haselberger on 13/06/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//


import WatchKit
import WatchConnectivity
import Foundation

///Class to manage watch session.
class InterfaceController: WKInterfaceController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    @IBOutlet var proximityLabel: WKInterfaceLabel!
    private var defaultSession: WCSession?
    private var timer: Timer?
    let myInterval:TimeInterval = 15.0
    private var isUpdatingUI:Bool = false
    
    /**
     Sets proximity label and activates session. Calls function self.sendUIUpdateRequest().
    */
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.proximityLabel.setText("No box in range")
        if WCSession.isSupported() {
            defaultSession = WCSession.default
            defaultSession!.delegate = self
            defaultSession!.activate()
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
    
    /**
     Starts a timer to update the user interface.
    */
    func startTimer()
    {
        if(timer != nil)
        {
            if (timer!.isValid) {
                timer!.invalidate()
                timer = nil
            }
        }
        timer = Timer.scheduledTimer(timeInterval: myInterval,
                                                       target: self,
                                                       selector: #selector(InterfaceController.sendUIUpdateRequest),
                                                       userInfo: myInterval,
                                                       repeats: true)
        isUpdatingUI = true
    }
    
    /**
     Stops timer.
    */
    func endTimer(){
        if(timer != nil)
        {
            timer!.invalidate()
            timer = nil
            isUpdatingUI = !isUpdatingUI
        }
    }
    
    /**
     Sends a session message with payload "BeaconRanging".
    */
    @objc func sendUIUpdateRequest()
    {
        if defaultSession!.isReachable != true {
            return
        }
        let payload = ["BeaconRanging": NSNumber(value: true)]
        defaultSession!.sendMessage(payload, replyHandler: nil, errorHandler: nil)
    }
    
    
    ///WCSessionDelegate method
    func session(_ session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let closestBeaconState = message["ClosestBeaconProximity"] {
            //Sets proximity label text
            self.proximityLabel.setText(closestBeaconState as? String)
        }
    }

}
