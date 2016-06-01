//
//  LBBoxWebViewController.swift
//  LibraryBox
//
//  Created by David on 30/05/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation
import UIKit

class LBBoxWebViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView! = UIWebView()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidden = true
        let url = NSURL(string: "http://www.librarybox.us")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}

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