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
    @IBOutlet weak var boxTypeSelection: UISegmentedControl!
    @IBOutlet weak var pinButton: UIButton!
    var currentLocationOfUser: CLLocation!
    
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
                    if self.getAddressFromPlaceMark(pm[0]) != nil
                    {
                        if !self.checkForDublicatePinning(pm[0])
                        {
                            self.updateAddressFooter("'Address' valid")
                            self.pinButton.enabled = true
                            
                        } else
                        {
                            self.updateAddressFooter("'Address' already on map")
                            self.pinButton.enabled = false
                        }
                    }else
                    {
                        self.updateAddressFooter("No valid address found")
                        self.pinButton.enabled = false
                    }
                }
            })
        }
    }
    
    func checkForDublicatePinning(place: CLPlacemark) -> Bool
    {
        //check lat and long values with kml (not translated into clplacemark due to performance
        return true
    }
    
    func updateAddressFooter(text: String)
    {
        //TODO Update line height and string font
        let myTable = self.view as? UITableView
        let footerView: UITableViewHeaderFooterView = myTable!.footerViewForSection(0)!
        let animation: CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = 0.35;
        footerView.textLabel?.layer.addAnimation(animation, forKey: "kCATransitionFade")
        footerView.textLabel?.text=text
        footerView.textLabel?.sizeToFit()
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
}