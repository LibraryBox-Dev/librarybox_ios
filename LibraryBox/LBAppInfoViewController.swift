//
//  LBAppInfoViewController.swift
//  LibraryBox
//
//  Created by David Haselberger on 08/08/16.
//  Copyright © 2016 Evenly Distributed LLC. All rights reserved.
//

import Foundation

///Application info class. Presents a text view with infos about the LibraryBox project.
class LBAppInfoViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneViewing))
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.title = "LibraryBox Info"

    }
    
    @IBAction func doneViewing()
    {
        self.dismiss(animated: true, completion:{
            
        })
        
    }
    
}
