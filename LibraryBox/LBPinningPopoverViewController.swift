//
//  LBPinningPopoverViewController.swift
//  LibraryBox
//
//  Created by David on 13/07/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AeroGearHttp
import AeroGearOAuth2
import PKHUD

protocol LBPinningPopoverDelegate
{
    func pinAddress()
    func currentLocation() -> CLLocation
    func locationPinningSuccessful()
}

class LBPinningPopoverViewController: UIViewController {

    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var pinCloseBoxButton: UIButton!
    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var boxTypeSelection: UISegmentedControl!
    
    var delegate: LBPinningPopoverDelegate?
    var http: Http!
    //The current box map annotations (received through "prepareForSegue" in LBMainViewController)
    var currentBoxLocations: [MKAnnotation] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updatePopoverUI(_:)), name: "LBCurrentClosestBeacon", object: nil)
        pinCloseBoxButton.userInteractionEnabled = false
        addAddressButton.selected = true
        http = Http()
    }

    func updatePopoverUI(notification: NSNotification)
    {
        let theBeacon: CLBeacon = notification.object as! CLBeacon
        var proximityString: String = "NOT IN RANGE"
        switch theBeacon.proximity {
        case .Far:
            proximityString = "FAR"
        case .Near:
            proximityString = "NEAR"
        case .Immediate:
            proximityString = "CLOSE"
        case .Unknown:
            proximityString = "NOT IN RANGE"
        }
        let beaconAccuracy = Int(theBeacon.accuracy)
        let proximityStringAppearance = proximityString + " (~" + String(beaconAccuracy) + "m)"
        proximityLabel.text = proximityStringAppearance
        if(proximityString == "NEAR")
        {
            pinCloseBoxButton.userInteractionEnabled = true
            pinCloseBoxButton.selected = true
        }
        else if(proximityString == "CLOSE")
        {
            pinCloseBoxButton.userInteractionEnabled = true
            pinCloseBoxButton.selected = true
        }
        else
        {
            pinCloseBoxButton.userInteractionEnabled = false
            pinCloseBoxButton.selected = false
        }
        pinCloseBoxButton.setNeedsDisplay()
    }
    
    @IBAction func pinCloseBox(sender: AnyObject!)
    {
        if let locationForPinning = self.delegate?.currentLocation()
        {
            HUD.show(.Progress)
            //LBGoogleAPIAccessService.clientId() returns the client ID of the service for the app in the scope
            let googleConfig = GoogleConfig(
                clientId: LBGoogleAPIAccessService.clientId(),
                scopes:["https://www.googleapis.com/auth/fusiontables"])
            let gdModule =  OAuth2Module(config: googleConfig)
            self.http.authzModule = gdModule
            
            //If access is granted, a new row is set in the Fusion Table associated with LibraryBox locations
            gdModule.requestAccess { (response:AnyObject?, error:NSError?) -> Void in
                
                //The acces API key of the app to the service
                let accessKey:String = LBGoogleAPIAccessService.accessKey()
                
                //The content of the Description column in the Fusion Table row
                let addressTitle:String = ""
                
                //The content of the type column in the Fusion Table row
                let type:String = self.boxTypeSelection.titleForSegmentAtIndex(self.boxTypeSelection.selectedSegmentIndex)!
                
                //The SQL query to add the new row in Fusion Table (INSERT INTO table-id (Column, *) VALUES (Value for column, *)
                let sqlQuery:String = "INSERT INTO 1ICTFk4jdIZIneeHOvhWOcvsZxma_jSqcAWNwuRlK (Description, Latitude, Longitude, Type) VALUES ('\(addressTitle)',\(locationForPinning.coordinate.latitude),\(locationForPinning.coordinate.longitude),'\(type)');"
                
                //Transfer sqlQuery string to a URL query string
                let queryURL: String = sqlQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                
                //The complete URL path string for the Fusion Table query
                let pathString:String = "https://www.googleapis.com/fusiontables/v2/query?sql=INSERT INTO 1ICTFk4jdIZIneeHOvhWOcvsZxma_jSqcAWNwuRlK (Description, Location, Type) VALUES ('\(addressTitle)', '\(locationForPinning.coordinate.latitude), \(locationForPinning.coordinate.longitude)', '\(type)');&key=\(accessKey)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                
                //The http request to the REST API of the Fusion Table service
                self.http.request(.POST, path: pathString, parameters: ["sql":queryURL, "key":accessKey], credential: nil, responseSerializer: StringResponseSerializer(), completionHandler: {(response, error) in
                    
                    //Error checking for http request
                    if (error != nil) {
                        HUD.hide()
                        let alert:UIAlertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        print("Error uploading file: \(error)")
                    } else {
                        HUD.flash(.Success, delay: 1.0)
                        self.delegate?.locationPinningSuccessful()
                        delay(2.0)
                        {
                            HUD.hide()
                            print("Successfully posted: " + response!.description)
                            self.dismissViewControllerAnimated(true, completion:{
                            })
                        }
                    }
                })
            }
        }

    }
    
    @IBAction func addAddress(sender: AnyObject!)
    {
        self.dismissViewControllerAnimated(true, completion:{
            self.delegate?.pinAddress()
        })
    }
    
}