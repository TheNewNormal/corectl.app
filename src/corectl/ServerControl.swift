//
//  ServerControl.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 06/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Foundation
import Cocoa


// server control //

// start corectld server
func ServerStart() {
    // send stop to corectld just in case it was left running
    ServerStop()
    
    let menuItem : NSStatusItem = statusItem
    
    // start corectld server
    let task = NSTask()
    task.launchPath = "/usr/local/sbin/corectld"
    task.arguments = ["start"]
    task.launch()
    
    menuItem.menu?.itemWithTag(1)?.title = "Server is running"
    menuItem.menu?.itemWithTag(1)?.state = NSOnState
}


func ServerStartShell() {
    // send stop to corectld just in case it was left running
    ServerStop()
    
    let menuItem : NSStatusItem = statusItem
    
    // start corectld server
    let task: NSTask = NSTask()
    let launchPath = NSBundle.mainBundle().resourcePath! + "/start_corectld.command"
    task.launchPath = launchPath
    task.launch()
    //
    menuItem.menu?.itemWithTag(1)?.title = "Server is running"
    menuItem.menu?.itemWithTag(1)?.state = NSOnState
}


// stop corectld server
func ServerStop() {
    let menuItem : NSStatusItem = statusItem
    
    // stop corectld server
    let task = NSTask()
    task.launchPath = "/usr/local/sbin/corectld"
    task.arguments = ["stop"]
    task.launch()
    
    menuItem.menu?.itemWithTag(1)?.title = "Server is off"
    menuItem.menu?.itemWithTag(1)?.state = NSOffState
}

