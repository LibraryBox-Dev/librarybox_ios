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
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(url: URL as URL)
        request.httpMethod = "GET"
        let nc = NotificationCenter.default
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
            if (error == nil) {
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Success: \(statusCode)")
                let filename = "LibBox_Locations.kml"
                guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    print("directory is nil")
                    return
                }
                let path = directoryURL.appendingPathComponent(filename).path
                
                if path == ""
                {
                    print("path is nil")
                    return
                }
                try data!.write(to:NSURL(string:path)! as URL)
                nc.post(name: NSNotification.Name(rawValue: "LBDownloadSuccess"), object: nil)
                nc.post(name: NSNotification.Name(rawValue: "LBDownloadTaskFinished"), object: nil)
            }
            else {
                print("Failure: %@", error!.localizedDescription)
                nc.post(name: NSNotification.Name(rawValue: "LBDownloadTaskFinished"), object: nil)
            }
            } as! (Data?, URLResponse?, Error?) -> Void)
        task.resume()
    }
}
