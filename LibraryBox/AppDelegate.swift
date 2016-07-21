//
//  AppDelegate.swift
//  LibraryBox
//
//  Created by David on 23/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import UIKit
import WatchConnectivity
import AeroGearOAuth2
import AVFoundation

///The application delegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    /// The notification name for watch-related operations
    static let LBWatchNotificationName = "LBWatchNotificationName"
    
    /// The main window
    var window: UIWindow?
    var watchSession: WCSession?
    var containerViewController: LBContainerViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //set and register local notification settings
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge , .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print(error)  
        }

        
        //setup watchkit connectivity session, if supported
        if WCSession.isSupported() {
            watchSession = WCSession.defaultSession()
            watchSession!.delegate = self
            watchSession!.activateSession()
        }
        
                
        //set root view controller of app window to LBContainerViewController()
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        containerViewController = LBContainerViewController()
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()

        return true
    }
    
    
    
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        let notification = NSNotification(name: AGAppLaunchedWithURLNotification,
                                          object:nil,
                                          userInfo:[UIApplicationLaunchOptionsURLKey:url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
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
    
    // WCSessionDelegate methods
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName(AppDelegate.LBWatchNotificationName, object: self, userInfo: message)
    }

}

