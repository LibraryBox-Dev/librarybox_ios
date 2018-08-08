//
//  LBReachabilityService.swift
//  LibraryBox
//
//  Created by David Haselberger on 15/06/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation
import SystemConfiguration


///Public class holding class functions to check for network reachability
public class LBReachabilityService {
    
    /**
     Returns true if connected to a network.
     
     :returns: bool value signifying network connection status -> true if connected.
    */
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        return isReachable && !needsConnection
    }
    
    /**
     Returns true if connected to the internet. A web URL is requested - if the request doesn´t time out and the response code is 200, the function returns true, else false.
     
     :returns: bool value signifying internet connection status -> true if connected.
     */
    class func isConnectedToInternet() -> Bool {
        
        var status:Bool = false
        
        let url = NSURL(string: "https://google.com")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        var response:URLResponse?
        do {
            //deprecated function in iOS9
            let _ = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData?
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                status = true
            }
        }
        return status
    }
    
    /**
     Checks, if connected to a box by requesting the config.json file that is present at the box. If the URL can be found, a notification is posted via NSNotificationCenter that the device is connected to a box. Otherwise, a notification is sent via NSNotificationCenter that it is not connected.
     */
    class func isConnectedToBox() {
        //http://192.168.77.1/config.json
        if let url = NSURL(string: "http://librarybox.us/config.json") {
            let request = URLRequest(url: url as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 2)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            print("CHECKING BOX CONNECTION")
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if (error == nil) {
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Status code: (\(httpResponse.statusCode))")
                        let nc = NotificationCenter.default
                        if (httpResponse.statusCode == 200)
                        {
                            nc.post(name: NSNotification.Name(rawValue: "LBConnectedToBox"), object: nil)
                            print("connected")
                        }
                        else
                        {
                            nc.post(name: NSNotification.Name(rawValue: "LBNotConnectedToBox"), object: nil)
                            print("not connected")
                        }
                    }
                }else
                {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LBNotConnectedToBox"), object: nil)
                    print("Failure: %@", error!.localizedDescription);
                }
            })
            task.resume()
        }
    }
    
}
