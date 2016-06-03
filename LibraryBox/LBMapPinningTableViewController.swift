//
//  LBMapPinningTableViewController.swift
//  LibraryBox
//
//  Created by David on 03/06/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AddressBookUI

class LBMapPinningTableViewController: UITableViewController
{
    @IBOutlet weak var boxAddress: UITextView!
    //@IBOutlet weak var latitudeField: UITextField!
    //@IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var boxTypeSelection: UISegmentedControl!
    var currentLocationOfUser: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(cancelPinning))
        self.navigationItem.rightBarButtonItem = cancelButton
        self.navigationItem.title = "Add Box Location"
        
        if currentLocationOfUser != nil
        {
            self.getPlacemarkFromLocation(currentLocationOfUser)
            //latitudeField.text = String(currentLocationOfUser.coordinate.latitude)
            //longitudeField.text = String(currentLocationOfUser.coordinate.longitude)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPlacemarkFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {print("reverse geodcode fail: \(error!.localizedDescription)")}
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let addressString = self.getAddressFromPlaceMark(pm[0])
                    self.boxAddress.text = addressString
                }
        })
    }
    
    func getAddressFromPlaceMark(unsafePlaceMark: CLPlacemark? )->String?{
        if let placeMark = unsafePlaceMark{
            if let address=placeMark.addressDictionary?["FormattedAddressLines"] as? [String]
            {
                let addressString = address.joinWithSeparator(",")
                return addressString
            }
        }
        return nil
    }
    
    @IBAction func pinBox(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion:{
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.googleapis.com/fusiontables/v1/query")!)
            request.HTTPMethod = "POST"
            let accessKey:String = LBGoogleAPIAccessService.accessKey()
            let sqlQuery:String = "INSERT INTO 1ICTFk4jdIZIneeHOvhWOcvsZxma_jSqcAWNwuRlK (Description, Latitude, Longitude, Type) VALUES ('Blue Shoes', 50);"
            let postString = "sql=\(sqlQuery)&key=\(accessKey)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                guard error == nil && data != nil else {                                                          // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("responseString = \(responseString)")
            }
            task.resume()
        })
    }
    
    
    @IBAction func cancelPinning()
    {
        self.dismissViewControllerAnimated(true, completion:{
            
        })

    }
}