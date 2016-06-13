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
    var closestBeacon: CLBeacon?
    dynamic var currentFilteredBeaconSigmaDistances = [Double](count: 20, repeatedValue: 0.0)
    var _beaconFilteredSigmaDistances = [Double](count: 20, repeatedValue: 0.0)
    var myKMLParser: KMLParser!
    private var locationService = LBLocationService()
    var delegate: LBMainViewControllerDelegate?
    var monitoring: Bool = false
    var ranging: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        let userLocationButton = MKUserTrackingBarButtonItem(mapView:self.mapView)
        self.navigationItem.leftBarButtonItem = userLocationButton
        self.navigationItem.title = "LibraryBox"
        let radar = UIImage(named: "bluetoothsearching")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
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
        locationService.startMonitoringForBeacons()
        locationService.startBeaconRanging()
        self.updateMapUI()
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(activateMapRelatedServices), name:UIApplicationDidBecomeActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(deactivateRangingService), name:UIApplicationWillResignActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(deactivateMapRelatedServices), name:UIApplicationWillTerminateNotification, object: nil)
        nc.addObserver(self, selector: #selector(updateMapUI), name: "LBDownloadSuccess", object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //self.mapView.frame = self.view.bounds
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("LBMainViewControllerAppeared", object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showPinningInfo") {
            
            let yourNextNavigationController = (segue.destinationViewController as! UINavigationController)
            let yourNextViewController = yourNextNavigationController.topViewController as! LBMapPinningTableViewController
            yourNextViewController.currentLocationOfUser = self.locationService.currentLoc
            if let currentPoints = myKMLParser.points as? [MKAnnotation]
            {
                yourNextViewController.currentBoxLocations = currentPoints
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func triggerBeaconRangingView(sender: UITabBarItem)
    {
        delegate?.toggleRightPanel()
    }
    
    func activateMapRelatedServices()
    {
        locationService.startMonitoringForBeacons()
        locationService.startBeaconRanging()
        self.updateMapUI()
    }
    
    func deactivateRangingService()
    {
        locationService.stopBeaconRanging()
    }
    
    func deactivateMapRelatedServices()
    {
        locationService.stopBeaconRanging()
        locationService.stopMonitoringForBeacons()
    }
    
    func updateMapUI()
    {
        let kmlURL = self.libraryBoxKMLDataCheckAndPath()
        myKMLParser = KMLParser.init(URL:NSURL(string: kmlURL))
        myKMLParser.parseKML()
        //self.addOverlays()
        self.addAnnotations()
    }
    
    func libraryBoxKMLDataCheckAndPath() -> String
    {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.URLByAppendingPathComponent("LibBox_Locations.kml")
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath.path!) {
            do {
                let attributes = try fileManager.attributesOfItemAtPath(filePath.path!)
                let creationDate = attributes["NSFileCreationDate"]
                if let created = creationDate where fabs(created.timeIntervalSinceNow) > 300 {
                    try fileManager.removeItemAtPath(filePath.path!)
                    if let URL = NSURL(string: "http://www.google.com/maps/d/kml?forcekml=1&mid=11WhHwTW0VYR-ToW7XtwS0OGiu4o") {
                        LBURLDownloadService.load(URL)
                    }
                }
            }
            catch let error as NSError {
                print("Something went wrong: \(error)")
            }
        } else {
            if let URL = NSURL(string: "http://www.google.com/maps/d/kml?forcekml=1&mid=11WhHwTW0VYR-ToW7XtwS0OGiu4o") {
                LBURLDownloadService.load(URL)
            }
        }
        return filePath.absoluteString
    }
    
//    func addOverlays()
//    {
//        //let myKMLOverlayArray = myKMLParser.overlays as! [MKOverlay]
//        //self.mapView.addOverlays(myKMLOverlayArray)
//    }
    
    func addAnnotations()
    {
        let myKMLAnnotationArray = myKMLParser.points as! [MKAnnotation]
        self.mapView.addAnnotations(myKMLAnnotationArray)
    }
    
}


//mapView delegate
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
        } else if overlay is LBBoxProximityCircleOverlay {
            let circle = MKCircleRenderer(overlay: overlay)
            var fillColoring: UIColor = UIColor.clearColor()
            var strokeColoring:UIColor = UIColor.clearColor()
            if let myBeacon:CLBeacon = closestBeacon
            {
                switch myBeacon.proximity {
                case .Far:
                    fillColoring = UIColor.cyanColor()
                    strokeColoring = UIColor.darkGrayColor()
                case .Near:
                    fillColoring = UIColor.orangeColor()
                    strokeColoring = UIColor.darkGrayColor()
                case .Immediate:
                    fillColoring = UIColor.redColor()
                    strokeColoring = UIColor.darkGrayColor()
                case .Unknown:
                    fillColoring = UIColor.clearColor()
                    strokeColoring = UIColor.clearColor()
                }
            }
            circle.fillColor = fillColoring
            circle.strokeColor = strokeColoring
            circle.lineWidth = 1
            return circle
        }
        let myOverlayRenderer: MKOverlayRenderer? = nil
        return myOverlayRenderer!
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        return nil
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
        monitoring = true
        delegate?.startScanningAnimation()
        

    }
    
    func monitoringStoppedSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //UI updates
        }
        monitoring = false
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
        monitoring = false
    }
    
    func monitoringFailedToStartDueToAuthorization() {
        monitoring = false
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
    
    func rangingStartedSuccessfully() {
        currentBeacons = []
        print("Ranging started successfully.")
        ranging = true
        delegate?.startScanningAnimation()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
           // UI updates
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
        ranging = false
    }
    
    func rangingFailedToStartDueToAuthorization() {
        ranging = false
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
            //UI updates
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
            self.currentBeacons = beacons.sort({ $0.accuracy < $1.accuracy})
            if(self.currentBeacons.count > 0)
            {
                self.closestBeacon = self.currentBeacons[0]
            }
            let sortedBeacons = self.currentBeacons
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
    
    func userLocationChangedTo(location:CLLocation)
    {
        var distanceRadius: Double = 0.0
        if let myBeacon:CLBeacon = closestBeacon
        {
            switch myBeacon.proximity {
            case .Far:
                distanceRadius = 80.0
            case .Near:
                distanceRadius = 15.0
            case .Immediate:
                distanceRadius = 5.0
            case .Unknown:
                distanceRadius = 5.0
            }
            let circle = LBBoxProximityCircleOverlay(centerCoordinate: location.coordinate, radius: distanceRadius as CLLocationDistance)
            self.mapView.addOverlay(circle)
        }
    }

}



    

