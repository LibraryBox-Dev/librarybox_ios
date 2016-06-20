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
import AeroGearHttp
import AeroGearOAuth2

class LBMapPinningTableViewController: UITableViewController
{
    @IBOutlet weak var boxAddress: UITextView!
    @IBOutlet weak var boxTypeSelection: UISegmentedControl!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var boxAddressFeedback: UILabel!
    var currentLocationOfUser: CLLocation!
    var currentBoxLocations: [MKAnnotation] = []
    var placemarkForPinning: CLPlacemark!
    var http: Http!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(cancelPinning))
        self.navigationItem.rightBarButtonItem = cancelButton
        self.navigationItem.title = "Add Box Location"
        let gestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.tableView.addGestureRecognizer(gestureRecognizer)
        self.pinButton.enabled = false
        self.boxAddress.delegate = self
        if currentLocationOfUser != nil
        {
            self.getPlacemarkFromLocation(currentLocationOfUser)
        }
        http = Http()
        
//        self.terms.delegate = self
//        let str = "By using this app you agree to our Terms and Conditions and Privacy Policy"
//        let attributedString = NSMutableAttributedString(string: str)
//        var foundRange = attributedString.mutableString.rangeOfString("Terms and Conditions")
//        attributedString.addAttribute(NSLinkAttributeName, value: termsAndConditionsURL, range: foundRange)
//        foundRange = attributedString.mutableString.rangeOfString("Privacy Policy")
//        attributedString.addAttribute(NSLinkAttributeName, value: privacyURL, range: foundRange)
//        terms.attributedText = attributedString
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboard()
    {
        self.boxAddress.resignFirstResponder()
    }
    
    func getPlacemarkFromLocation(location: CLLocation){
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {print("reverse geodcode fail: \(error!.localizedDescription)")}
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let addressString = self.getAddressFromPlaceMark(pm[0])
                    self.boxAddress.text = addressString
                    self.validateAddressText()
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
            if let locationForPinning = self.placemarkForPinning.location
            {
                let googleConfig = GoogleConfig(
                    clientId: LBGoogleAPIAccessService.clientId(),
                    scopes:["https://www.googleapis.com/auth/fusiontables"])
                let gdModule =  OAuth2Module(config: googleConfig)
                self.http.authzModule = gdModule
                gdModule.requestAccess { (response:AnyObject?, error:NSError?) -> Void in
                    let accessKey:String = LBGoogleAPIAccessService.accessKey()
                    let addressTitle:String = self.getAddressFromPlaceMark(self.placemarkForPinning)!
                    let type:String = self.boxTypeSelection.titleForSegmentAtIndex(self.boxTypeSelection.selectedSegmentIndex)!
                    let sqlQuery:String = "INSERT INTO 1ICTFk4jdIZIneeHOvhWOcvsZxma_jSqcAWNwuRlK (Description, Latitude, Longitude, Type) VALUES ('\(addressTitle)',\(locationForPinning.coordinate.latitude),\(locationForPinning.coordinate.longitude),'\(type)');"
                    let queryURL: String = sqlQuery.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    let pathString:String = "https://www.googleapis.com/fusiontables/v2/query?sql=INSERT INTO 1ICTFk4jdIZIneeHOvhWOcvsZxma_jSqcAWNwuRlK (Description, Location, Type) VALUES ('\(addressTitle)', '\(locationForPinning.coordinate.latitude), \(locationForPinning.coordinate.longitude)', '\(type)');&key=\(accessKey)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! 
                    self.http.request(.POST, path: pathString, parameters: ["sql":queryURL, "key":accessKey], credential: nil, responseSerializer: StringResponseSerializer(), completionHandler: {(response, error) in
                        if (error != nil) {
                            print("Error uploading file: \(error)")
                        } else {
                            print("Successfully posted: " + response!.description)
                        }
                    })
                }
            }
        })
    }
    
    
    @IBAction func cancelPinning()
    {
        self.dismissViewControllerAnimated(true, completion:{
            
        })

    }
    
    func validateAddressText()
    {
        let addressText = self.boxAddress.text
        let types: NSTextCheckingType = [.Address]
        let detector = try? NSDataDetector(types: types.rawValue)
        var addresses: [[String:String]] = []
        detector?.enumerateMatchesInString(addressText, options: [], range: NSMakeRange(0, (addressText as NSString).length)) { (result, flags, _) in
            addresses.append((result?.addressComponents)!)
            print(result?.addressComponents)
        }
        if(addresses.count > 0)
        {
            CLGeocoder().geocodeAddressDictionary(addresses[0], completionHandler: {(placemarks, error) in
                if (error != nil) {print("forward geodcode fail: \(error!.localizedDescription)")}
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    if let currentAddress = self.getAddressFromPlaceMark(pm[0])
                    {
                        if !self.checkForDublicatePinning(pm[0])
                        {
                            self.updateAddressFeedback("\u{2705} '\(currentAddress)' valid")
                            self.placemarkForPinning = pm[0]
                            self.pinButton.enabled = true
                            
                        } else
                        {
                            self.updateAddressFeedback("\u{274C} '\(currentAddress)' already on map")
                            self.pinButton.enabled = false
                        }
                    }else
                    {
                        self.updateAddressFeedback("\u{274C} No valid address found")
                        self.pinButton.enabled = false
                    }
                }
            })
        }else
        {
            self.updateAddressFeedback("\u{274C} No valid address found")
            self.pinButton.enabled = false
        }
    }
    
    func checkForDublicatePinning(place: CLPlacemark) -> Bool
    {
        var isDublicate: Bool = true
        for boxLoc in currentBoxLocations
        {
            let locationOfPlace = place.location
            let pinLoc = CLLocation(latitude: boxLoc.coordinate.latitude, longitude: boxLoc.coordinate.longitude)
            let distance = locationOfPlace?.distanceFromLocation(pinLoc)
            if (distance < 15)
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
    
    func updateAddressFeedback(text: String)
    {
        boxAddressFeedback.text=text
    }
    
}




extension LBMapPinningTableViewController: UITextViewDelegate
{

    func textViewDidBeginEditing(textView: UITextView) {
        self.pinButton.enabled = false
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        self.validateAddressText()
    }
    
//    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
//        if (URL.absoluteString == termsAndConditionsURL) {
//            let myAlert = UIAlertController(title: "Terms", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(myAlert, animated: true, completion: nil)
//        } else if (URL.absoluteString == privacyURL) {
//            let myAlert = UIAlertController(title: "Conditions", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(myAlert, animated: true, completion: nil)
//        }
//        return false
//    }
}