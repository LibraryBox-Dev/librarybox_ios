//
//  LBBoxWebViewController.swift
//  LibraryBox
//
//  Created by David Haselberger on 30/05/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation
import UIKit


///View controller class for the box content web view
//modified from http://rshankar.com/swift-webview-demo/
class LBBoxWebViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView! = UIWebView()
    var reloadButton: UIBarButtonItem?
    var backButton: UIBarButtonItem?
    var forwardButton: UIBarButtonItem?
    var interactionController: UIDocumentInteractionController?
    
    /**
     Setup of navigation bar, toolbar. Loads box content.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Box"
        reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(doRefresh(_:)))
        self.navigationItem.rightBarButtonItem = reloadButton
        
        var items = [UIBarButtonItem]()
        backButton = UIBarButtonItem(title: "◄", style: .Plain, target: self, action:#selector(goBack(_:)))
        items.append(backButton!)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        )
        forwardButton = UIBarButtonItem(title: "►", style: .Plain, target: self, action:#selector(goForward(_:)))
        items.append(forwardButton!)
        items.append(
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .Action, target: self, action:#selector(showActivityViewController(_:)))
        )
        items.append(
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        )
        let wifi = UIImage(named: "wifinotification")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let wifiButton = UIButton()
        wifiButton.frame = CGRectMake(0, 0, 22, 22)
        wifiButton.setImage(wifi, forState: .Normal)
        wifiButton.addTarget(self, action: #selector(gotoWifiSettings(_:)), forControlEvents: .TouchUpInside)
        let wifiBarButton = UIBarButtonItem()
        wifiBarButton.customView = wifiButton

        items.append(wifiBarButton)
        self.setToolbarItems(items, animated: false)
        self.navigationController?.toolbarHidden = false

        
        webView.delegate = self
        webView.userInteractionEnabled = true
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackAllowsAirPlay = true
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
    
    
    /**
     Redirects to iOS Wifi Settings
    */
    @IBAction func gotoWifiSettings(sender: UIBarButtonItem) {
        UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=WIFI")!)
    }
    
    /**
     Content refresh.
    */
    @IBAction func doRefresh(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    /**
     Back to previous http address.
    */
    @IBAction func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    /**
     Forward to http address.
     */
    @IBAction func goForward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    /**
     Stop loading content.
    */
    @IBAction func stop(sender: UIBarButtonItem) {
        webView.stopLoading()
    }
    
    /**
     Presents activity view controller.
    */
    @IBAction func showActivityViewController(sender: UIBarButtonItem)
    {
        let activityViewController = UIActivityViewController (
            activityItems: [(webView.request?.URL!.absoluteString)! as NSString],
            applicationActivities: nil
        )
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    /**
     Checks box connection.
    */
    func checkBoxConnection()
    {
        LBReachabilityService.isConnectedToBox()
    }
    
    /**
     Set navigation bar title.
    */
    func updateTitle()
    {
        if let pageTitle: String = webView.stringByEvaluatingJavaScriptFromString("document.title")
        {
            self.navigationItem.title = pageTitle
        }
        else
        {
            self.navigationItem.title = "Box"
        }
    }
    
    /**
     Enable or disable to go back and forward if possible.
    */
    func updateButtons()
    {
        self.forwardButton!.enabled = self.webView.canGoForward
        self.backButton!.enabled = self.webView.canGoBack
    }
    
}


///Delegate methods
extension LBBoxWebViewController: UIWebViewDelegate
{
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
    
    
    func webViewDidStartLoad(webView: UIWebView){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.updateButtons()
        reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(stop(_:)))
         self.navigationItem.rightBarButtonItem = reloadButton
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(doRefresh(_:)))
         self.navigationItem.rightBarButtonItem = reloadButton
        self.updateTitle()
        self.updateButtons()
    }
    
    /**
     Error handling.
     If content is not loaded, checks for content type. If content type is epub.zip, deletes extension .zip. Data is stored on the device and a UIDocumentInteractionController is presented. Else, an alert is presented to the user showing the error description.
    */
    func webView(webView: UIWebView,
                 didFailLoadWithError error: NSError?){

        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.updateButtons()
        reloadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(doRefresh(_:)))
         self.navigationItem.rightBarButtonItem = reloadButton
        if(error!.code == 204)
        {
            
        }
        else if(error!.code == 102)
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let urlString: String = (error?.userInfo["NSErrorFailingURLStringKey"])! as! String
            print(urlString)
            let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!) {
                data, response, error in
                if let httpResponse = response as? NSHTTPURLResponse {
                    if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
                        print(contentType)
                        
                        var filePath = NSURL(string: urlString)!.lastPathComponent!
                        if (filePath.rangeOfString(".epub.zip") != nil)
                        {
                            filePath = (NSURL(string: urlString)!.URLByDeletingPathExtension?.lastPathComponent)!
                        }
                        let filename = self.getDocumentsDirectory().stringByAppendingPathComponent(filePath)
                        
                        data?.writeToFile(filename, atomically: true)
                        
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.interactionController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: filename))
                        delay(0.1)
                        {
                            self.interactionController!.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
                        }
                    }
                }
            }
            task.resume()
        }
        else
        {
            delay(0.1)
            {
                let alert:UIAlertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.checkBoxConnection()}))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    /**
     Returns user documents directory.
     
     - returns: User documents directory
    */
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
