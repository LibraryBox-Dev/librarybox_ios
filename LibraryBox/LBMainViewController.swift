//
//  ViewController.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol LBMainViewControllerDelegate {
    func toggleRightPanel()
    func collapseSidePanel()
    func startScanningAnimation()
}

class LBMainViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    //@IBOutlet weak var mapContainerView: UIView!
    
    var currentBeacons = [CLBeacon]()
    dynamic var currentFilteredBeaconSigmaDistances = [Double](count: 20, repeatedValue: 0.0)
    var _beaconFilteredSigmaDistances = [Double](count: 20, repeatedValue: 0.0)
    private var locationService = LBLocationService()
    var delegate: LBMainViewControllerDelegate?
    let beaconKeyPath = "currentBeaconDistanceSigmaKeyPath"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        let userLocationButton = MKUserTrackingBarButtonItem(mapView:self.mapView)
        self.navigationItem.leftBarButtonItem = userLocationButton
        self.navigationItem.title = "LibraryBox"
        let radar = UIImage(named: "online")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let radarButton = UIButton()
        radarButton.frame = CGRectMake(0, 0, 22, 22)
        radarButton.setImage(radar, forState: .Normal)
        radarButton.addTarget(self, action: #selector(LBMainViewController.triggerBeaconRangingView), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = radarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        locationService.delegate = self
        locationService.authorize()
        locationService.startUpdatingUserLocation()
        locationService.startBeaconRanging()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //self.mapView.frame = self.view.bounds
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("MainViewControllerAppeared", object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func triggerBeaconRangingView(sender: UITabBarItem)
    {
        delegate?.toggleRightPanel()
    }
}

extension LBMainViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.greenColor()
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = UIColor.whiteColor()
            polygonView.lineWidth = 0.4
            polygonView.strokeColor = UIColor.blackColor()
            return polygonView
        }
        let myOverlayRenderer: MKOverlayRenderer? = nil
        return myOverlayRenderer!
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView()
        annotationView.rightCalloutAccessoryView = UIButton.init(type:UIButtonType.DetailDisclosure)
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
    }
}


extension LBMainViewController: LBLocationServiceDelegate
{
    func userLocationServiceFailedToStartDueToAuthorization()
    {
        self.reAuthorize()
    }
    
    func monitoringStartedSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in

        }
        delegate?.startScanningAnimation()

    }
    
    func monitoringStoppedSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //custom wifi-connection view monitoringAnimation
            //self.monitoringActivityIndicator.stopAnimating()
        }
    }
    
    func monitoringFailedToStart() {
        let title = "No beacon monitoring possible"
        let message = "No beacon monitoring is available on this device at the moment."
        let okButtonTitle = "OK"
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: okButtonTitle, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
           
        }
    }
    
    func monitoringFailedToStartDueToAuthorization() {
            self.reAuthorize()
    }
    
    func monitoringDetectedEnteringRegion(region: CLBeaconRegion) {
        sendLocalNotificationForBeaconRegion(region)
    }
    
    func sendLocalNotificationForBeaconRegion(region: CLBeaconRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "Entered beacon region for UUID: " + region.proximityUUID.UUIDString
        notification.alertAction = "View Details"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

    // RANGING API MAY NOT BE USED IN THE BACKGROUND => frontmost and the user is interacting with your app
    
    func rangingStartedSuccessfully() {
        currentBeacons = []
        print("Ranging started successfully.")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
           // self.rangingSwitch.on = true
        }
    }
    
    func rangingFailedToStart() {
        let title = "No beacon ranging possible"
        let message = "No beacon ranging is available on this device at the moment."
        let okButtonTitle = "OK"
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction.init(title: okButtonTitle, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
        }
    }
    
    func rangingFailedToStartDueToAuthorization() {
        self.reAuthorize()
    }
    
    func reAuthorize()
    {
        let title = "Missing Location Access"
        let message = "Location Access (Always) is required. Click Settings to update the location access settings."
        let cancelButtonTitle = "Cancel"
        let settingsButtonTitle = "Settings"
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction.init(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: settingsButtonTitle, style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(cancelAction);
        alertController.addAction(settingsAction);
        self.presentViewController(alertController, animated: true, completion: nil)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            // self.monitoringSwitch.on = false
        }

    }
    
    func rangingStoppedSuccessfully() {
        self.currentBeacons = []
        self.currentFilteredBeaconSigmaDistances  = [Double](count: 20, repeatedValue: 0.0)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
        }
    }
    
    func rangingBeaconsInRange(beacons: [CLBeacon]!, inRegion region: CLBeaconRegion!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.currentBeacons = beacons
            let sortedBeacons = self.currentBeacons.sort({ $0.accuracy < $1.accuracy})
            let filterFactor: Double = 0.2
            for (index, value) in sortedBeacons.enumerate()
            {
                if (index < 20)
                {
                    let beacon: CLBeacon = value
                    var previousFilteredAccuracy = self._beaconFilteredSigmaDistances[index]
                    if(previousFilteredAccuracy < 0.1)
                    {
                        previousFilteredAccuracy = beacon.accuracy
                    }
                    let _filteredAccuracy: Double = (beacon.accuracy * filterFactor) + (previousFilteredAccuracy * (1.0 - filterFactor))
                    self.currentFilteredBeaconSigmaDistances[index] = _filteredAccuracy
                }
            }
            //self.setValue(self.currentFilteredBeaconSigmaDistances, forKeyPath: self.beaconKeyPath)
        }
    }

}



    

