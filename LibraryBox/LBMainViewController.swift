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

/**
Delegate protocol for the main view controller. "toggleRightPanel()" is called from the delegate, when the NavigationItem for bluetooth ranging is pressed. "startScanningAnimation()" is called from the delegate, when monitoring or ranging for beacons started successfully.
 */
protocol LBMainViewControllerDelegate {
    /**
     Triggered when button is pressed to show the iBeacon ranging view.
     */
    func toggleRightPanel()
    
    /**
    Triggered when iBeacon monitoring or ranging started successfully.
     */
    func startScanningAnimation()
}

///Main view controller class holding the map view.
class LBMainViewController: UIViewController {

    //Outlet to the map view
    @IBOutlet weak var mapView: MKMapView!
    
    //Array holding current iBeacons, sorted by accuracy
    var currentBeacons = [CLBeacon]()
    
    //The currently closest iBeacon based on accuracy
    var closestBeacon: CLBeacon?
    
    //Sigma distances of up to 20 close iBeacons based on accuracy
    dynamic var currentFilteredBeaconSigmaDistances = [Double](count: 20, repeatedValue: 0.0)
    
    //Cached sigma distances for low pass filtering of iBeacon proximity based on accuracy
    var _beaconFilteredSigmaDistances = [Double](count: 20, repeatedValue: 0.0)
    
    //The KML parser (an external objective-c class from an Apple sample project)
    var myKMLParser: KMLParser!
    
    //The location service instance - including the location manager
    private var locationService = LBLocationService()
    
    //The delegate
    var delegate: LBMainViewControllerDelegate?
    
    //Boolean variables that signify if monitoring, ranging is active or if reauthorization is necessary
    var monitoring: Bool = false
    var ranging: Bool = false
    var reauthorizationNecessary:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Map setup
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        
        //Navigation bar items: Title and left bar button item
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
        
        //Location service setup
        locationService.delegate = self
        locationService.authorize()
        locationService.startUpdatingUserLocation()
        locationService.startMonitoringForBeacons()
        locationService.startBeaconRanging()
        
        //Map user interface updating - sets KML annotation pins
        self.updateMapUI()
        
        //Notifications for app status: active, background, terminating - to turn location services on or off, updating UI based on KML file, start ranging services based on notification from watchkit
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(activateMapRelatedServices), name:UIApplicationDidBecomeActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(deactivateRangingService), name:UIApplicationWillResignActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(deactivateMapRelatedServices), name:UIApplicationWillTerminateNotification, object: nil)
        nc.addObserver(self, selector: #selector(updateMapUI), name: "LBDownloadSuccess", object: nil)
        nc.addObserver(self, selector: #selector(operateOnWatchNotification), name: "LBWatchNotificationName", object: nil)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //send notification when view is loaded
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("LBMainViewControllerAppeared", object: nil)
        
        //check for authorization, iBeacon ranging and monitoring and present a sheet from a UIAlertController, if something is not working.
        self.presentErrors()
    }
    
    /**
     Transmits current user location and current box locations to LBMapPinningTableViewController associated with the storyboard segue "showPinningInfo".
    */
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
    }
    
    /**
     Presents error messages using UIAlertController, first checks if authorization is necessary, then if ranging or monitoring is not active.
    */
    func presentErrors()
    {
        if(reauthorizationNecessary)
        {
            let title = "Missing Location Access"
            let message = "Location Access (Always) is required. User location is updated when the app is active. Beacon ranging is activated when the app is active. Beacon monitoring is running when the app is active, inactive or in the background. Click Settings to update the location access settings."
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
            //"delay" function that enables a delay on Grand Central Dispatch - from LBUtilities
            delay(0.4){
                    UIApplication.sharedApplication().delegate?.window!?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else if(!ranging || !monitoring)
        {
            delay(0.4){
                //"showAlert" function that creates an alert message with an "OK" button - from LBUtilities
                showAlert("No beacon sensing is available on this device at the moment.", title: "iBeacon sensing currently not possible.", fn: {})
            }
        }
    }
    
    /**
     Called from the left navigation item - to toggle the right panel showing or hiding the iBeacon ranging view
    */
    @IBAction func triggerBeaconRangingView(sender: UITabBarItem)
    {
        delegate?.toggleRightPanel()
    }
    
    /**
     Called when app is activated.
    */
    func activateMapRelatedServices()
    {
        locationService.startUpdatingUserLocation()
        locationService.startMonitoringForBeacons()
        locationService.startBeaconRanging()
        LBReachabilityService.isConnectedToBox()
        self.updateMapUI()
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("LBMainViewControllerAppeared", object: nil)
        self.presentErrors()
    }
    
    /**
     Called when notified by a connected watch.
     */
    func operateOnWatchNotification()
    {
        //TODO: if notification object message is to start ranging:
        locationService.startUpdatingUserLocation()
        locationService.startBeaconRanging()
    }
    
    /**
     Called when app goes to background.
     */
    func deactivateRangingService()
    {
        locationService.stopBeaconRanging()
        locationService.stopUpdatingUserLocation()
    }
    
    /**
     Called when app is terminating.
     */
    func deactivateMapRelatedServices()
    {
        locationService.stopBeaconRanging()
        locationService.stopMonitoringForBeacons()
        locationService.stopUpdatingUserLocation()
    }
    
    /**
     Retrieves KML from LibraryBox Google MyMaps environment, parses the KML and calls a function to add annotations to the map view.
    */
    func updateMapUI()
    {
        let kmlURL = self.libraryBoxKMLDataCheckAndPath()
        myKMLParser = KMLParser.init(URL:NSURL(string: kmlURL))
        myKMLParser.parseKML()
        //self.addOverlays()
        self.addAnnotations()
    }
    
    
    /**
     Retrieves KML from LibraryBox Google MyMaps environment by checking if a KML file exists, if it needs to be updated and if so, downloading a new KML file using the LBURLDownloadService.
     Returns the path to the KML file.
     
     :returns: file path to KML file as string.
     */
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
//    }
    
    /**
     Removes all overlays from the map that are of the class "LBBoxProximityCircleOverlay"
    */
    func removeOverlays()
    {
        let overlays = self.mapView.overlays
        overlays.forEach {
            if ($0 is LBBoxProximityCircleOverlay) {
                self.mapView.removeOverlay($0)
            }
        }
    }
    
    /**
     Adds annotations from the parsed KML file to the map view.
    */
    func addAnnotations()
    {
        let myKMLAnnotationArray = myKMLParser.points as! [MKAnnotation]
        self.mapView.addAnnotations(myKMLAnnotationArray)
    }
    
}


//MARK: mapView delegate
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
        
        //creates the circular map overlay renderer at the users' location based on proximity of the closest iBeacon
        } else if overlay is LBBoxProximityCircleOverlay {
            let circle = MKCircleRenderer(overlay: overlay)
            var fillColoring: UIColor = UIColor.clearColor()
            var strokeColoring:UIColor = UIColor.clearColor()
            if let myBeacon:CLBeacon = closestBeacon
            {
                //coloring the circle based on iBeacon proximity attribute
                switch myBeacon.proximity {
                case .Far:
                    fillColoring = UIColor.cyanColor().colorWithAlphaComponent(0.2)
                    strokeColoring = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
                case .Near:
                    fillColoring = UIColor.orangeColor().colorWithAlphaComponent(0.2)
                    strokeColoring = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
                case .Immediate:
                    fillColoring = UIColor.redColor().colorWithAlphaComponent(0.2)
                    strokeColoring = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
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
    
    /**
     For custom annotations
    */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        return nil
    }
    
    /**
     For accessory views to annotations
     */
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
    }
}


//MARK: location service delegate functions
extension LBMainViewController: LBLocationServiceDelegate
{
    /**
     Sets the boolean reauthorizationNecessary to true.
     */
    func userLocationServiceFailedToStartDueToAuthorization()
    {
        self.reauthorizationNecessary = true
    }
    
    func userLocationServiceStartedSuccessfully()
    {
        self.reauthorizationNecessary = false
    }
    
    /**
     Sets the bool monitoring to true. Starts the color-fade scanning animation on the Wifi-Button.
    */
    func monitoringStartedSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in

        }
        monitoring = true
        self.reauthorizationNecessary = false
        delegate?.startScanningAnimation()
    }
    
    /**
     Sets the bool monitoring to false.
     */
    func monitoringStoppedSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //UI updates
        }
        monitoring = false
    }
    
    /**
     Opens the app settings URL.
     */
    func openAppSettings()
    {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
    
    /**
     Sets the boolean monitoring to false.
     */
    func monitoringFailedToStart() {
        monitoring = false
    }
    
    /**
     Sets the booleans monitoring to false and reauthorizationNecessary to true.
     */
    func monitoringFailedToStartDueToAuthorization() {
        monitoring = false
        self.reauthorizationNecessary = true
    }
    
    /**
     Called on entering an iBeacon region.
     */
    func monitoringDetectedEnteringRegion(region: CLBeaconRegion) {
        
        sendLocalNotificationForBeaconRegion(region)
    }
    
    /**
     Sends a local notification that the iOS device is close to a LibraryBox iBeacon.
     */
    func sendLocalNotificationForBeaconRegion(region: CLBeaconRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "Close to librarybox with UUID: " + region.proximityUUID.UUIDString
        notification.alertAction = "View Details"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    /**
     Called if ranging started successfully. Sets the array of current beacons to an empty array, sets the boolean ranging to true, calls the delegate method to start the scanning animation on the Wifi button.
    */
    func rangingStartedSuccessfully() {
        currentBeacons = []
        print("Ranging started successfully.")
        ranging = true
        self.reauthorizationNecessary = false
        delegate?.startScanningAnimation()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
           // UI updates can be implemented here
        }
    }
    
    /**
     Sets the boolean ranging to false.
    */
    func rangingFailedToStart() {
        ranging = false
    }
    
    /**
     Sets the booleans ranging to false and reauthorizationNecessary to true.
     */
    func rangingFailedToStartDueToAuthorization() {
        ranging = false
        self.reauthorizationNecessary = true
    }
    
    /**
     Called when iBeacon ranging is stopped. Resets the currentBeacons array to an empty beacon and the currentFilteredBeaconSigmaDistances array holding 20 double values representing the accuracy attribute of CLBeacons in the area to 0.0 for each array element.
    */
    func rangingStoppedSuccessfully() {
        self.currentBeacons = []
        self.currentFilteredBeaconSigmaDistances  = [Double](count: 20, repeatedValue: 0.0)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
        }
    }
    
    /**
     Called when ranging beacons. Sets the currentFilteredBeaconSigmaDistances array based on a low-pass filter algorithm applied on CLBeacon accuracies. The currentFilteredBeaconSigmaDistances array is KVO compliant and observed in LBContainerViewController.
    */
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
                    if(self._beaconFilteredSigmaDistances[index] < 0.1)
                    {
                        self._beaconFilteredSigmaDistances[index] = beacon.accuracy
                    }
                    let previousFilteredAccuracy = self._beaconFilteredSigmaDistances[index]
                    let _filteredAccuracy: Double = (beacon.accuracy * filterFactor) + (previousFilteredAccuracy * (1.0 - filterFactor))
                    self.currentFilteredBeaconSigmaDistances[index] = _filteredAccuracy
                }
            }
        }
    }
    
    /**
     Called when the user location changes. Updates the circular iBeacon proximity map overlay.
     */
    func userLocationChangedTo(location:CLLocation)
    {
        var distanceRadius: Double = 0.0
        if let myBeacon:CLBeacon = closestBeacon
        {
            //Set distance radius of circular user location overlay in meters
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
            
            //Update overlay
            self.removeOverlays()
            let circle = LBBoxProximityCircleOverlay(centerCoordinate: location.coordinate, radius: distanceRadius as CLLocationDistance)
            self.mapView.addOverlay(circle)
        }
    }
}



    

