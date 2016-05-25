//
//  AppDelegate.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    static let LBWatchNotificationName = "LBWatchNotificationName"
    var window: UIWindow?
    var watchSession: WCSession?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if WCSession.isSupported() {
            watchSession = WCSession.defaultSession()
            watchSession!.delegate = self
            watchSession!.activateSession()
        }
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let containerViewController = LBContainerViewController()
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()

        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(AppDelegate.LBWatchNotificationName, object: self, userInfo: message)
    }

}

