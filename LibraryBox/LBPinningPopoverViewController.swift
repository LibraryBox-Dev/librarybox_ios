//
//  LBPinningPopoverViewController.swift
//  LibraryBox
//
//  Created by David Haselberger on 13/07/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CloudKit
//import AeroGearHttp
//import AeroGearOAuth2
import PKHUD

///Protocol declaration for the popover delegate
protocol LBPinningPopoverDelegate
{
    func pinAddress()
    func currentLocation() -> CLLocation
    func locationPinningSuccessful()
}

///Pinning popover view controller class
class LBPinningPopoverViewController: UIViewController {

    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var pinCloseBoxButton: UIButton!
    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var boxTypeSelection: UISegmentedControl!
    
    var delegate: LBPinningPopoverDelegate?
    //var http: Http!
    
    ///The current box map annotations (received through "prepareForSegue" in LBMainViewController)
    var currentBoxLocations: [MKAnnotation] = []
    
    /**
     Adds a notification observer for the closest beacon. Initializes Http object for Google Fusion Table Rest API access.
    */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePopoverUI(notification:)), name: NSNotification.Name(rawValue: "LBCurrentClosestBeacon"), object: nil)
        pinCloseBoxButton.isUserInteractionEnabled = false
        pinCloseBoxButton.isSelected = false
        addAddressButton.isSelected = true
    //    http = Http()
    }

    /**
     Called on notification for current closest beacon. Updates the proximity string of the popover view. Button to pin close box is enabled or disabled based on beacon proximity.
    */
    @objc func updatePopoverUI(notification: NSNotification)
    {
        let theBeacon: CLBeacon = notification.object as! CLBeacon
        var proximityString: String = "NOT IN RANGE"
        switch theBeacon.proximity {
        case .far:
            proximityString = "FAR"
        case .near:
            proximityString = "NEAR"
        case .immediate:
            proximityString = "CLOSE"
        case .unknown:
            proximityString = "NOT IN RANGE"
        }
        let beaconAccuracy = Int(theBeacon.accuracy)
        let proximityStringAppearance = proximityString + " (~" + String(beaconAccuracy) + "m)"
        proximityLabel.text = proximityStringAppearance
        if(proximityString == "NEAR")
        {
            pinCloseBoxButton.isUserInteractionEnabled = true
            pinCloseBoxButton.isSelected = true
        }
        else if(proximityString == "CLOSE")
        {
            pinCloseBoxButton.isUserInteractionEnabled = true
            pinCloseBoxButton.isSelected = true
        }
        else
        {
            pinCloseBoxButton.isUserInteractionEnabled = false
            pinCloseBoxButton.isSelected = false
        }
        pinCloseBoxButton.setNeedsDisplay()
    }
    
    /**
     Called when button "Mark Close Box" is pressed. Pins box based on Google Fusion Table Rest APi access.
    */
    @IBAction func pinCloseBox(sender: AnyObject!)
    {
        if let locationForPinning = self.delegate?.currentLocation()
        {
            delay(delay: 0.1)
            {
                HUD.show(.progress)
            }
            if(!self.checkForDublicatePinning(loc: locationForPinning))
            {
                delay(delay: 0.1)
                {
                    HUD.show(.progress)
                }
                let recordType: String = "BoxLocations"
                let myRecord = CKRecord(recordType: recordType)
//                if let recordAddress: String = self.getAddressFromPlaceMark(self.placemarkForPinning)!
//                {
//                    if(!recordAddress.isEmpty)
//                    {
//                        myRecord.setObject(recordAddress, forKey:"Address")
//                    }
//                }
                if let type:String = self.boxTypeSelection.titleForSegment(at: self.boxTypeSelection.selectedSegmentIndex)!
                {
                    if(!type.isEmpty)
                    {
                        myRecord.setObject(type as CKRecordValue, forKey:"BoxType")
                    }
                }
                if let location: CLLocation = locationForPinning
                {
                    myRecord.setObject(location, forKey:"Location")
                }
                let publicDatabase = CKContainer.default().publicCloudDatabase
                publicDatabase.save(myRecord) { record, error in
                    DispatchQueue.main.async() {
                        if error == nil{
                            print("success")
                        }
                        if(error != nil)
                        {
                            if let error = error as NSError? {
                                if(error.code == 14)
                                {
                                    publicDatabase.fetch(withRecordID: myRecord.recordID) {
                                        rec, nsError  in
                                        
                                        if let rec = rec {
                                            for key in myRecord.allKeys() {
                                                rec[key] = myRecord[key]
                                                //                                rec.setObject(myRecord.objectForKey(key), forKey:"key")
                                            }
                                            //
                                            publicDatabase.save(myRecord) {
                                                record, error in
                                                
                                                self.processResult(record: rec, error: nsError! as NSError)
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            self.processResult(record: record, error: error! as NSError)
                        }
                        
                    }
                }

                
                
//                //LBGoogleAPIAccessService.clientId() returns the client ID of the service for the app in the scope
//                let googleConfig = GoogleConfig(
//                    clientId: LBGoogleAPIAccessService.clientId(),
//                    scopes:["https://www.googleapis.com/auth/fusiontables"])
//                let gdModule =  OAuth2Module(config: googleConfig)
//                self.http.authzModule = gdModule
//                
//                //If access is granted, a new row is set in the Fusion Table associated with LibraryBox locations
//                gdModule.requestAccess { (response:AnyObject?, error:NSError?) -> Void in
//                    
//                    //The acces API key of the app to the service
//                    let accessKey:String = LBGoogleAPIAccessService.accessKey()
//                    
//                    //The content of the Description column in the Fusion Table row
//                    let addressTitle:String = ""
//                    
//                    //The content of the type column in the Fusion Table row
//                    let type:String = self.boxTypeSelection.titleForSegmentAtIndex(self.boxTypeSelection.selectedSegmentIndex)!
//                    
//                    //The SQL query to add the new row in Fusion Table (INSERT INTO table-id (Column, *) VALUES (Value for column, *)
//                    let sqlQuery:String = "INSERT INTO 1ICTFk4jdIZIneeHOvhWOcvsZxma_jSqcAWNwuRlK (Description, Latitude, Longitude, Type) VALUES ('\(addressTitle)',\(locationForPinning.coordinate.latitude),\(locationForPinning.coordinate.longitude),'\(type)');"
//                    
//                    //Transfer sqlQuery string to a URL query string
//                    let queryURL: String = sqlQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
//                    
//                    //The complete URL path string for the Fusion Table query
//                    let pathString:String = "https://www.googleapis.com/fusiontables/v2/query?sql=INSERT INTO 1ICTFk4jdIZIneeHOvhWOcvsZxma_jSqcAWNwuRlK (Description, Location, Type) VALUES ('\(addressTitle)', '\(locationForPinning.coordinate.latitude), \(locationForPinning.coordinate.longitude)', '\(type)');&key=\(accessKey)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
//                    
//                    //The http request to the REST API of the Fusion Table service
//                    self.http.request(.POST, path: pathString, parameters: ["sql":queryURL, "key":accessKey], credential: nil, responseSerializer: StringResponseSerializer(), completionHandler: {(response, error) in
//                        
//                        //Error checking for http request
//                        if (error != nil) {
//                            delay(0.1)
//                            {
//                                HUD.hide()
//                            }
//                            let alert:UIAlertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
//                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//                            self.presentViewController(alert, animated: true, completion: nil)
//                            print("Error uploading file: \(error)")
//                        } else {
//                            HUD.flash(.Success, delay: 1.0)
//                            self.delegate?.locationPinningSuccessful()
//                            delay(2.0)
//                            {
//                                HUD.hide()
//                                print("Successfully posted: " + response!.description)
//                                self.dismissViewControllerAnimated(true, completion:{
//                                })
//                            }
//                        }
//                    })
//                }
            }
            else
            {
                delay(delay: 0.1)
                {
                    HUD.hide()
                }
                let alert:UIAlertController = UIAlertController(title: "Box already pinned", message: "The box is already pinned on the map.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func processResult(record: CKRecord?, error: NSError?) {
        
        HUD.flash(.success, delay: 1.0)
        self.delegate?.locationPinningSuccessful()
        delay(delay: 2.0)
        {
            HUD.hide()
            print("Successfully posted!")
            self.dismiss(animated: true, completion:{
            })
        }
    }
    
    /**
    Checks for dublicate pins based on the currentBoxLocations array
    */
    func checkForDublicatePinning(loc: CLLocation) -> Bool
    {
        var isDublicate: Bool = true
        for boxLoc in currentBoxLocations
        {
            let locationOfPlace = loc
            let pinLoc = CLLocation(latitude: boxLoc.coordinate.latitude, longitude: boxLoc.coordinate.longitude)
            let distance = locationOfPlace.distance(from: pinLoc)
            if (distance < 5)
            {
                isDublicate = true
                break
            }
            else
            {
                isDublicate = false
            }
        }
        return isDublicate
    }

    /**
    calls the delegate function pinAddress() to start pinning a box from a placemark.
    */
    @IBAction func addAddress(sender: AnyObject!)
    {
        self.dismiss(animated: true, completion:{
            self.delegate?.pinAddress()
        })
    }
    
}
