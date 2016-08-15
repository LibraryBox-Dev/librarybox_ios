//
//  LBURLDownloader.swift
//  LibraryBox
//
//  Created by David Haselberger on 04/05/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation


///Class holding a class function for downloading the KML file from the LibraryBox MyMaps environment.
class LBURLDownloadService {
    
    /**
     Downloads the KML file from the LibraryBox MyMaps environment and stores it on the device. On successful completion, a notification is sent via NSNotificationCenter.
     */
    class func load(URL: NSURL) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("Success: \(statusCode)")
                let filename = "LibBox_Locations.kml"
                guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
                    print("directory is nil")
                    return
                }
                guard let path = directoryURL.URLByAppendingPathComponent(filename).path else {
                    print("path is nil")
                    return
                }
                data!.writeToFile(path, atomically: true)
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName("LBDownloadSuccess", object: nil)
            }
            else {
                print("Failure: %@", error!.localizedDescription);
            }
        })
        task.resume()
    }
}