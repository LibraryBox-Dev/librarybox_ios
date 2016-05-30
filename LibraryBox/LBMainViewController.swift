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
    private var locationService = LBLocationService()
    var delegate: LBMainViewControllerDelegate?
    let beaconKeyPath = "currentBeaconKeyPath"
    
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
        locationService.startUpdatingUserLocation()
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
    func monitoringStartedSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            //custom wifi-connection view monitoringAnimation
            
            //self.monitoringActivityIndicator.startAnimating()
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
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
           // self.rangingSwitch.on = true
        }
    }
    
    func rangingFailedToStart() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
          //  self.rangingSwitch.on = false
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
        currentBeacons = []
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //Custom ranging view => update -> stop showing beacons
            
            //self.beaconTableView.beginUpdates()
            //if let deletedSections = self.deletedSections() {
            //    self.beaconTableView.deleteSections(deletedSections, withRowAnimation: UITableViewRowAnimation.Fade)
            //}
            //self.beaconTableView.endUpdates()
        }
    }
    
    func rangingBeaconsInRange(beacons: [CLBeacon]!, inRegion region: CLBeaconRegion!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.currentBeacons = beacons
            
            // instance variable _filteredAccuracy keeps the value from the last calculation.
            // filterFactor is a constant between 0 and 1.
            //float filterFactor = 0.2;
            //_filteredAccuracy = (accuracy * filterFactor) + (_filteredAccuracy * (1.0 - filterFactor));
            
            self.setValue(self.currentBeacons, forKeyPath: self.beaconKeyPath)
        }
    }

}



    

