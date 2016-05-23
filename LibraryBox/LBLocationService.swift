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
        let uuidString = "01122334-4556-6778-899A-ABBCCDDEEFF0"
        let beaconIdentifier = "Apple-iBeacon"
        let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)!
        let theRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
                                                         identifier: beaconIdentifier)
        theRegion.notifyEntryStateOnDisplay = true
        return theRegion
    }()
    
    func useLocationManagerNotifications() {
        locationManager.delegate = self
    }
    
    func startUpdatingUserLocation()
    {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
        self.authorizeAndStartService()
        
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
        self.authorizeAndStartService()
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
        self.authorizeAndStartService()
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
    
    private func authorizeAndStartService()
    {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
            startMonitoring()
            startRanging()
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



extension LBLocationService
{
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            print("Location Access (Always) granted!")
            delegate?.monitoringStartedSuccessfully()
            startMonitoring()
            delegate?.rangingStartedSuccessfully()
            startRanging()
        } else if status == .AuthorizedWhenInUse || status == .Denied || status == .Restricted {
            print("Location Access (Always) denied!")
            delegate?.monitoringFailedToStart()
            delegate?.rangingFailedToStart()
        }
    }
}

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
    }
}