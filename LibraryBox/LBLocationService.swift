//
//  LocationService.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import CoreLocation

protocol LBLocationServiceDelegate
{
    func userLocationServiceFailedToStartDueToAuthorization()
    func userLocationChangedTo(location:CLLocation)
    func monitoringStartedSuccessfully()
    func monitoringStoppedSuccessfully()
    func monitoringFailedToStart()
    func monitoringFailedToStartDueToAuthorization()
    func monitoringDetectedEnteringRegion(region: CLBeaconRegion)
    func rangingStartedSuccessfully()
    func rangingFailedToStart()
    func rangingFailedToStartDueToAuthorization()
    func rangingStoppedSuccessfully()
    func rangingBeaconsInRange(beacons: [CLBeacon]!, inRegion region: CLBeaconRegion!)
}


class LBLocationService: NSObject, CLLocationManagerDelegate
{
    var delegate: LBLocationServiceDelegate?
    lazy var locationManager: CLLocationManager = CLLocationManager()
    var currentLoc: CLLocation!
    let beaconRegion: CLBeaconRegion = {
        let theRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!, identifier: "Identifier")
        theRegion.notifyEntryStateOnDisplay = true
        return theRegion
    }()
    
    func useLocationManagerNotifications() {
        locationManager.delegate = self
    }
    
    func startUpdatingUserLocation()
    {
        useLocationManagerNotifications()
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        case .AuthorizedWhenInUse, .Denied, .Restricted:
            print("Couldn't turn on user location: Required Location Access (Always) missing.")
            delegate?.userLocationServiceFailedToStartDueToAuthorization()
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        }
        
        
        
    }
    
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

    
    func startMonitoring() {
        locationManager.startMonitoringForRegion(beaconRegion)
        print("Monitoring turned on for region: \(beaconRegion)")
        delegate?.monitoringStartedSuccessfully()
    }
    
    func stopMonitoringForBeacons() {
        locationManager.stopMonitoringForRegion(beaconRegion)
        print("Turned off monitoring")
        delegate?.monitoringStoppedSuccessfully()
    }
    
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
    
    func startRanging() {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        print("Ranging turned on for beacons in region: \(beaconRegion)")
        delegate?.rangingStartedSuccessfully()
    }
    
    func stopBeaconRanging() {
        if locationManager.rangedRegions.isEmpty {
            print("Didn't turn off ranging: Ranging already off.")
            return
        }
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
        delegate?.rangingStoppedSuccessfully()
        print("Turned off ranging.")
    }
    
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



//extension LBLocationService
//{
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .AuthorizedAlways {
//            print("Location Access (Always) granted!")
//            delegate?.monitoringStartedSuccessfully()
//            startMonitoring()
//            delegate?.rangingStartedSuccessfully()
//            startRanging()
//        } else if status == .AuthorizedWhenInUse || status == .Denied || status == .Restricted {
//            print("Location Access (Always) denied!")
//            delegate?.monitoringFailedToStart()
//            delegate?.rangingFailedToStart()
//        }
//    }
//}

extension LBLocationService
{
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region: \(region)")
        delegate?.monitoringDetectedEnteringRegion(region as! CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region)")
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        var stateString: String
        
        switch state {
        case .Inside:
            stateString = "inside"
        case .Outside:
            stateString = "outside"
        case .Unknown:
            stateString = "unknown"
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