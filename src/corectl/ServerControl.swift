//
//  ServerControl.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 06/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Foundation
import Cocoa


// start corectld server
func ServerStart() {
    
    // send an alert about the user password
    let mText: String = "Corectl for macOS"
    let infoText: String = "You will be asked to type your \"user\" password to start the \"Corectld\" server."
    displayWithMessage(mText, infoText: infoText)
    
    //
    let menuItem : NSStatusItem = statusItem
    
    // start corectld server
    let task: Process = Process()
    let launchPath = "~/bin/corectld"
    task.launchPath = launchPath
    task.arguments = ["start", "--user", "$(whoami)"]
    task.launch()
    task.waitUntilExit()
    
    //
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
        //
        let script = Bundle.main.resourcePath! + "/check_corectld_status.command"
        let status = shell(script, arguments: [])
        NSLog("corectld running status: '%@'",status)
        //
        if (status == "no"){
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 1)?.title = "Server status: Off"
            // display the error message
            let mText: String = "Corectl for macOS"
            let infoText: String = "Can not start the \"Corectl server\"."
            displayWithMessage(mText, infoText: infoText)
        }
        else {
            menuItem.menu?.item(withTag: 1)?.title = "Server status: Running"
            menuItem.menu?.item(withTag: 1)?.state = NSOnState
            //
            let script = Bundle.main.resourcePath! + "/check_corectld_version.command"
            let version = shell(script, arguments: [])
            NSLog("corectld version: '%@'",version)
            menuItem.menu?.item(withTag: 11)?.title = " Server version: " + version
        }
    }
}


// stop corectld server
func ServerStop() {
    //
    let menuItem : NSStatusItem = statusItem
    
    // show notification on to screen
    //notifyUserWithTitle("Corectl App", text: "All running VMs will be stopped.")
    
    // stop corectld server
    let task = Process()
    task.launchPath = "~/bin/corectld"
    task.arguments = ["stop"]
    task.launch()
    task.waitUntilExit()
    
    //
    menuItem.menu?.item(withTag: 1)?.title = "Server status: Off"
    menuItem.menu?.item(withTag: 1)?.state = NSOffState
}


// restart corectld server
func RestartServer() {
    //
    let menuItem : NSStatusItem = statusItem
    
    // send a notification on to the screen
    print("Restarting Corectl server")
    let notification: NSUserNotification = NSUserNotification()
    notification.title = "Restarting corectld server"
    NSUserNotificationCenter.default.deliver(notification)
    
    // stop corectld server
    menuItem.menu?.item(withTag: 1)?.title = "Server is stopping…"
    ServerStop()
    
    // start corectld server
    menuItem.menu?.item(withTag: 1)?.title = "Server is starting…"
    ServerStart()
    
    //
    menuItem.menu?.item(withTag: 3)?.title = "Check for App updates"
    menuItem.menu?.item(withTag: 4)?.title = "Check for Corectl updates"
}


//
func appDelegate () -> AppDelegate
{
    return NSApplication.shared().delegate as! AppDelegate
}

