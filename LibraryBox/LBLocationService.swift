//
//  LocationService.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import CoreLocation

//The delegate protocol of the location service. Lists the methods that a delegate should implement to be notified for all location service related operation events.
protocol LBLocationServiceDelegate
{
    /**
     Triggered when the user location update operation has failed to start due to the last authorization denial.
     */
    func userLocationServiceFailedToStartDueToAuthorization()
    
    /**
     Triggered when the user location update operation has started successfully.
     */
    func userLocationServiceStartedSuccessfully()
    /**
     Triggered when the users' location changed.
     
     :param: location The CLLocation of the users' current location.
     */
    func userLocationChangedTo(location:CLLocation)
    
    /**
     Triggered when the monitoring operation has started successfully.
     */
    func monitoringStartedSuccessfully()
    
    /**
     Triggered by the monitoring operation when it has stopped successfully.
     */
    func monitoringStoppedSuccessfully()
    
    /**
     Triggered when the monitoring operation has failed to start.
     */
    func monitoringFailedToStart()
    
    /**
     Triggered when the monitoring operation has failed to start due to the last authorization denial.
     */
    func monitoringFailedToStartDueToAuthorization()
    
    /**
     Triggered when the monitoring operation has detected entering the given region.
     
     :param: region The region that the monitoring operation detected.
     */
    func monitoringDetectedEnteringRegion(region: CLBeaconRegion)
    
    /**
     Triggered when the ranging operation has started successfully.
     */
    func rangingStartedSuccessfully()
    
    /**
     Triggered when the ranging operation has failed to start.
     */
    func rangingFailedToStart()
    
    /**
     Triggered when the ranging operation has failed to start due to the last authorization denial.
     */
    func rangingFailedToStartDueToAuthorization()
    
    /**
     Triggered when the ranging operation has stopped successfully.
     */
    func rangingStoppedSuccessfully()
    
    /**
     Triggered when the ranging operation has detected beacons belonging to a specific given beacon region.
     
     :param: beacons An array of provided beacons that the ranging operation detected.
     :param: region A provided region whose beacons the operation is trying to range.
     */
    func rangingBeaconsInRange(beacons: [CLBeacon]!, inRegion region: CLBeaconRegion!)
}

///The core class for operations related to core location
class LBLocationService: NSObject, CLLocationManagerDelegate
{
    var delegate: LBLocationServiceDelegate?
    
    //The CLLocationManager object
    lazy var locationManager: CLLocationManager = CLLocationManager()
    
    //A variable holding the users' current location
    var currentLoc: CLLocation!
    
    //SETUP OF BEACON REGION FOR MONITORING AND RANGING
    let beaconRegion: CLBeaconRegion = {
        let beaconIdentifierUserDefault: Bool = NSUserDefaults.standardUserDefaults().boolForKey("customIdentifier")
        if(!beaconIdentifierUserDefault)
        {
            let theRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, identifier: "Identifier")
            theRegion.notifyEntryStateOnDisplay = true
            //UNLocationNotificationTrigger(region: region, repeats: false);
            return theRegion
        }
        else
        {
            if let idString: String = NSUserDefaults.standardUserDefaults().stringForKey("beaconIdentifier")
            {
                if let uuidString = NSUUID(UUIDString: idString)
                {
                    let aRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: uuidString, identifier: "Identifier")
                    aRegion.notifyEntryStateOnDisplay = true
                    //UNLocationNotificationTrigger(region: region, repeats: false);
                    return aRegion
                }
                else
                {
                    let theRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, identifier: "Identifier")
                    theRegion.notifyEntryStateOnDisplay = true
                    //UNLocationNotificationTrigger(region: region, repeats: false);
                    return theRegion
                }
            }
            else
            {
                let theRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, identifier: "Identifier")
                theRegion.notifyEntryStateOnDisplay = true
                //UNLocationNotificationTrigger(region: region, repeats: false);
                return theRegion
            }
        }
    }()
    
    /**
     Sets the location manager delegate to self.  It gets called when an instance is ready to process location
     manager delegate calls.
    */
    func useLocationManagerNotifications() {
        locationManager.delegate = self
    }
    
    /**
     Checks, if user wants to use location services. If location services are enabled, user location is being updated.
     */
    func startUpdatingUserLocation()
    {
        useLocationManagerNotifications()
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
            delegate?.userLocationServiceStartedSuccessfully()
        case .AuthorizedWhenInUse, .Denied, .Restricted:
            print("Couldn't turn on user location: Required Location Access (Always) missing.")
            delegate?.userLocationServiceFailedToStartDueToAuthorization()
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    /**
     Stops updating users' location.
     */
    func stopUpdatingUserLocation()
    {
        useLocationManagerNotifications()
        locationManager.stopUpdatingLocation()
    }
    
    /**
     Starts the beacon region monitoring process.
     */
    func startMonitoringForBeacons() {
        useLocationManagerNotifications()
        
        print("Turning on monitoring...")
        if !CLLocationManager.locationServicesEnabled() {
            print("Couldn't turn on monitoring: Location services are not enabled.")
            delegate?.monitoringFailedToStart()
            return
        }
        
        if !(CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion)) {
            print("Couldn't turn on region monitoring: Region monitoring is not available for CLBeaconRegion class.")
            delegate?.monitoringFailedToStart()
            return
        }
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            startMonitoring()
        case .AuthorizedWhenInUse, .Denied, .Restricted:
            print("Couldn't turn on monitoring: Required Location Access (Always) missing.")
            delegate?.monitoringFailedToStartDueToAuthorization()
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        }
    }

    /**
     Turns on monitoring (after all the checks have been passed).
     */
    func startMonitoring() {
        locationManager.startMonitoringForRegion(beaconRegion)
        print("Monitoring turned on for region: \(beaconRegion)")
        delegate?.monitoringStartedSuccessfully()
    }
    
    /**
     Stops the monitoring process.
     */
    func stopMonitoringForBeacons() {
        locationManager.stopMonitoringForRegion(beaconRegion)
        print("Turned off monitoring")
        delegate?.monitoringStoppedSuccessfully()
    }
    
    /**
     Starts the beacon ranging process.
     */
    func startBeaconRanging() {
        useLocationManagerNotifications()
        print("Turning on ranging...")
        if !CLLocationManager.locationServicesEnabled() {
            print("Couldn't turn on ranging: Location services are not enabled.")
            delegate?.rangingFailedToStart()
            return
        }
        if !CLLocationManager.isRangingAvailable() {
            print("Couldn't turn on ranging: Ranging is not available.")
            delegate?.rangingFailedToStart()
            return
        }
        if !locationManager.rangedRegions.isEmpty {
            print("Didn't turn on ranging: Ranging already on.")
            return
        }
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            startRanging()
        case .Denied, .Restricted:
            print("Couldn't turn on ranging: Required Location Access (When In Use) missing.")
            delegate?.rangingFailedToStartDueToAuthorization()
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    /**
     Turns on ranging (after all the checks have been passed).
     */
    func startRanging() {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        print("Ranging turned on for beacons in region: \(beaconRegion)")
        delegate?.rangingStartedSuccessfully()
    }
    
    /**
     Stops the ranging process.
     */
    func stopBeaconRanging() {
        if locationManager.rangedRegions.isEmpty {
            print("Didn't turn off ranging: Ranging already off.")
            return
        }
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
        delegate?.rangingStoppedSuccessfully()
        print("Turned off ranging.")
    }
    
    /**
     Checks the location services authorization status.
     */
    func authorize()
    {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            break
        case .AuthorizedWhenInUse, .Denied, .Restricted:
            print("Couldn't turn on monitoring: Required Location Access (Always) missing.")
            delegate?.monitoringFailedToStartDueToAuthorization()
        case .NotDetermined:
            if(locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization))) {
                locationManager.requestAlwaysAuthorization()
            }
            
        }
    }
}

// MARK: Location manager delegate methods
extension LBLocationService
{
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region)")
        //TODO: check region identifier if it is a librarybox before sending the delegate message
        
        /**
         Start ranging on entering beacon range
         */
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        delegate?.monitoringDetectedEnteringRegion(region as! CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        /**
         Stop ranging on exiting beacon range
         */
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
        print("Exited region: \(region)")
    }
    
    /**
     Start updating user location and beacon ranging when inside region otherwise turn off beacon ranging and updating user location
     */
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        var stateString: String
        
        switch state {
        case .Inside:
            stateString = "inside"
            self.startUpdatingUserLocation()
            self.startBeaconRanging()
        case .Outside:
            stateString = "outside"
            self.stopBeaconRanging()
            self.stopUpdatingUserLocation()
        case .Unknown:
            stateString = "unknown"
            self.stopBeaconRanging()
            self.stopUpdatingUserLocation()
        }
        
        print("State changed to " + stateString + " for region \(region).")
    }
}

extension LBLocationService
{
    func locationManager(manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                                         inRegion region: CLBeaconRegion)
    {
        delegate?.rangingBeaconsInRange(beacons, inRegion: region)
    }
}

extension LBLocationService
{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLoc = locations.last
        delegate?.userLocationChangedTo(currentLoc)
    }
}