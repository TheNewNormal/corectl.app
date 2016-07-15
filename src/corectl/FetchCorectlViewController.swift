//
//  FetchCorectlViewController.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 15/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Cocoa
import Foundation

class FetchCorectlViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("do something here ...")
    }
    
    
    @IBAction func download(sender: NSButton) {
        
        print("button got pressed")
    }
    
    @IBAction func Close(sender: NSButton) {
        
        // Hide Window
        NSApplication.sharedApplication().windows.last!.close()
        
        
        //AppDelegate.HideWindow(AppDelegate)
        
    }
}
