//
//  LBReachabilityService.swift
//  LibraryBox
//
//  Created by David on 15/06/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import SystemConfiguration
import PKHUD


///Public class holding class functions to check for network reachability
public class LBReachabilityService {
    
    /**
     Returns true if connected to a network.
     
     :returns: bool value signifying network connection status -> true if connected.
    */
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = flags == .Reachable
        let needsConnection = flags == .ConnectionRequired
        return isReachable && !needsConnection
    }
    
    /**
     Returns true if connected to the internet. A web URL is requested - if the request doesn´t time out and the response code is 200, the function returns true, else false.
     
     :returns: bool value signifying internet connection status -> true if connected.
     */
    class func isConnectedToInternet() -> Bool {
        
        var status:Bool = false
        
        let url = NSURL(string: "https://google.com")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        var response:NSURLResponse?
        do {
            //deprecated function in iOS9
            let _ = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) as NSData?
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        if let httpResponse = response as? NSHTTPURLResponse {
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
        if let url = NSURL(string: "http://192.168.77.1/config.json") {
            let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if (error == nil) {
                    if let httpResponse = response as? NSHTTPURLResponse {
                        print("Status code: (\(httpResponse.statusCode))")
                        let nc = NSNotificationCenter.defaultCenter()
                        if (httpResponse.statusCode == 200)
                        {
                            nc.postNotificationName("LBConnectedToBox", object: nil)
                            print("connected")
                        }
                        else
                        {
                            nc.postNotificationName("LBNotConnectedToBox", object: nil)
                            print("not connected")
                        }
                    }
                }else
                {
                    HUD.hide()
                    NSNotificationCenter.defaultCenter().postNotificationName("LBNotConnectedToBox", object: nil)
                    print("Failure: %@", error!.localizedDescription);
                }
            })
            task.resume()
        }
    }
    
}