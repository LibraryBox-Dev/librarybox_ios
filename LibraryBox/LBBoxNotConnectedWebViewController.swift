//
//  LBBoxNotConnectedWebViewController.swift
//  LibraryBox
//
//  Created by David Haselberger on 30/06/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation


class LBBoxNotConnectedWebViewController: UIViewController
{
    @IBOutlet weak var webView: UIWebView! = UIWebView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //NSURL *url = [[NSBundle mainBundle] URLForResource:@"my" withExtension:@"html"];
        //[webView loadRequest:[NSURLRequest requestWithURL:url]];
        
        let url = NSBundle.mainBundle().URLForResource("notConnected", withExtension: "html")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}