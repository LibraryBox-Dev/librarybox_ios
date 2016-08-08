//
//  LBAppInfoViewController.swift
//  LibraryBox
//
//  Created by David on 08/08/16.
//  Copyright © 2016 Berkman Center. All rights reserved.
//

import Foundation


class LBAppInfoViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(doneViewing))
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = "LibraryBox Info"

    }
    
    @IBAction func doneViewing()
    {
        self.dismissViewControllerAnimated(true, completion:{
            
        })
        
    }
    
}