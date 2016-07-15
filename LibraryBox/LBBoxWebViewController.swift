//
//  LBBoxWebViewController.swift
//  LibraryBox
//
//  Created by David on 30/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit


///View controller class for the box content web view
//modified from http://rshankar.com/swift-webview-demo/
class LBBoxWebViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView! = UIWebView()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Box"
        let wifiNavBarButton = UIBarButtonItem(title: "< Wi-Fi Settings", style: .Plain, target: self, action:#selector(gotoWifiSettings(_:)))
        self.navigationItem.leftBarButtonItem = wifiNavBarButton
        webView.delegate = self
        activityIndicator.hidden = true
        //the librarybox URL that is opened (can be any address as LibraryBox redirects)
        let url = NSURL(string: "http://www.librarybox.us")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func gotoWifiSettings(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=WIFI")!)
    }
    
    @IBAction func doRefresh(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func goForward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func stop(sender: UIBarButtonItem) {
        webView.stopLoading()
    }
    
    deinit
    {
        webView.stopLoading()
        webView.delegate = nil
    }

}

//MARK: Delegate methods
extension LBBoxWebViewController: UIWebViewDelegate
{
    func webViewDidStartLoad(webView: UIWebView){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    func webView(webView: UIWebView,
                 didFailLoadWithError error: NSError?){
        let alert:UIAlertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        activityIndicator.hidden = true
    }

}