//
//  LBSSIDCheckingService.swift
//  LibraryBox
//
//  Created by David on 30/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//
//Objective-C code from StackOverflow using NetworkExtension/NEHotspotHelper class to retrieve current SSID
//http://stackoverflow.com/questions/31555640/how-to-get-wifi-ssid-in-ios9-after-captivenetwork-is-depracted-and-calls-for-wif
//#import <NetworkExtension/NetworkExtension.h>
//NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
//NSLog(@"Networks %@",networkInterfaces);
//for(NEHotspotNetwork *hotspotNetwork in [NEHotspotHelper supportedNetworkInterfaces]) {
//    NSString *ssid = hotspotNetwork.SSID;
//    NSString *bssid = hotspotNetwork.BSSID;
//    BOOL secure = hotspotNetwork.secure;
//    BOOL autoJoined = hotspotNetwork.autoJoined;
//    double signalStrength = hotspotNetwork.signalStrength;
//}


import Foundation
import SystemConfiguration.CaptiveNetwork


///Class holding class function to check for SSID of the network currently connected to
class LBSSIDCheckingService {
    
    /**
     Returns the title of the network currently connected to.
     
     :returns: The SSID string.
     */
    class func fetchSSIDInfo() ->  String {
        var currentSSID = ""
        let interfaces:CFArray! = CNCopySupportedInterfaces()
        if(interfaces != nil)
        {
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)")
                if unsafeInterfaceData != nil {
                    let interfaceData = unsafeInterfaceData! as Dictionary!
                    currentSSID = interfaceData["SSID"] as! String
                }
            }
        }
        return currentSSID
    }
}


