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
        webView.userInteractionEnabled = true
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackAllowsAirPlay = true
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
    
//    deinit
//    {
//        webView.stopLoading()
//        webView.delegate = nil
//    }
    
    func checkBoxConnection()
    {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        LBReachabilityService.isConnectedToBox()
    }
    
    
}

//ACTIVITY VIEW CONTROLLER
//let activityViewController = UIActivityViewController (
//    activityItems: [(webView.request?.URL.absoluteString)! as NSString],
//    applicationActivities: nil
//)
//
//presentViewController(activityViewController, animated: true, completion: nil)

//MARK: Delegate methods
extension LBBoxWebViewController: UIWebViewDelegate
{
//    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        
//        let url: NSURL = request.URL!
//        let req: NSURLRequest = NSURLRequest(URL:url)
//        let conn: NSURLConnection = NSURLConnection(request: req, delegate: self)!
//        conn.start()
//        return true
//    }
    
    
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
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        let alert:UIAlertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.checkBoxConnection()}))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}

//extension LBBoxWebViewController: NSURLConnectionDelegate
//{
//    func connection(connection: NSURLConnection,
//                    didReceiveResponse response: NSURLResponse)
//    {
//        print(response.MIMEType)
//    }
//
//}