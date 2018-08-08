//
//  AppDelegate.swift
//  LibraryBox
//
//  Created by David Haselberger on 23/05/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import UIKit
import WatchConnectivity
import AeroGearOAuth2
import AVFoundation

///The application delegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    

    /// The notification name for watch-related operations
    static let LBWatchNotificationName = "LBWatchNotificationName"
    
    /// The main window
    var window: UIWindow?
    var watchSession: WCSession?
    
    ///Container view controller
    var containerViewController: LBContainerViewController?
    
    ///Box content navigation controller
    var nav: LBBoxContentNavigationController?

    
    /**
     Registers user notification settings. Setup of navigation bar appearance (orange color), AVAudioSession playback, Watchkit session if available. Sets root view controller for switching between LBContainerViewController and LBBoxWebViewController navigation controller.
    */
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //set and register local notification settings
        let settings = UIUserNotificationSettings(types: [.alert, .badge , .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 255.0/255.0, green: 140.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        
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
        //self.setUserAgent()

        
        //setup watchkit connectivity session, if supported
        if WCSession.isSupported() {
            watchSession = WCSession.default
            watchSession!.delegate = self
            watchSession!.activate()
        }
        
        containerViewController = LBContainerViewController()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        nav = storyboard.instantiateViewController(withIdentifier: "BoxContentNavigationController") as? LBBoxContentNavigationController
                
        //set root view controller of app window to LBContainerViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        self.switchToMainViewController()
        
        return true
    }
    
    /**
     Switches to LBContainerViewController
    */
    func switchToMainViewController() {
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
    }
    
    /**
     Switches to Box Content Navigation Controller
     */
    func switchToBoxViewController() {
        window!.rootViewController = nav
        window!.makeKeyAndVisible()        
    }
    
    /**
     Posts application launch options url key notification. Returns true.
     
     - returns: true
    */
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        let notification = NSNotification(name: NSNotification.Name(rawValue: AGAppLaunchedWithURLNotification),
                                          object:nil,
                                          userInfo:[UIApplicationLaunchOptionsKey.url:url])
        NotificationCenter.default.post(notification as Notification)
        return true
    }

//    func setUserAgent(){
//        let userAgent = NSDictionary(object:  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A",forKey: "UserAgent")
//        NSUserDefaults.standardUserDefaults().registerDefaults(userAgent as! [String : AnyObject])
//    }
    
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
    
    ///WCSessionDelegate session notification
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: AppDelegate.LBWatchNotificationName), object: self)
    }

}

