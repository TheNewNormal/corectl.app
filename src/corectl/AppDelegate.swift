//
//  AppDelegate.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 28/06/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "StatusItemIcon")
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        ServerStart()
        
        // create menu programmaticly
        //        let Quit : NSMenuItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.Quit(_:)), keyEquivalent: "")
        //        statusItem.menu!.addItem(Quit)
        //        statusItem.menu!.addItem(NSMenuItem.separatorItem())
    }
    
    
    func ServerStart() {
        let menuItem : NSStatusItem = statusItem
        
        // start corectld server
        let task = NSTask()
        task.launchPath = "/usr/local/sbin/corectld"
        task.arguments = ["start"]
        task.launch()
        
        menuItem.menu?.itemWithTag(1)?.title = "Server is running"
        menuItem.menu?.itemWithTag(1)?.state = NSOnState
    }
    
    
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
    

    @IBAction func Server(sender: NSMenuItem) {
        // an empty funtion just to create a menu item
    }
    

    @IBAction func Restart(sender: NSMenuItem) {
        let menuItem : NSStatusItem = statusItem
        menuItem.menu?.itemWithTag(1)?.title = "Server is stopping"
        
        // stop corectld server
        ServerStop()

        sleep(5)

        menuItem.menu?.itemWithTag(1)?.title = "Server is starting"
        // start corectld server
        ServerStart()
    }
    
    
    // fetch latest ISOs
    
    @IBAction func fetchLatestISOAlpha(sender: NSMenuItem) {
        
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Alpha ISO image will be updated"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/fetch_latest_iso_alpha.command")

    }

    
    @IBAction func fetchLatestISOBeta(sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Beta ISO image will be updated"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/fetch_latest_iso_beta.command")
    }
    
    
    @IBAction func fetchLatestISOStable(sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Stable ISO image will be updated"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/fetch_latest_iso_stable.command")
    }
    //
    

    @IBAction func Quit(sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Quitting Corectl App"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)

        // stop corectld server
        ServerStop()
        
        // exit App
        exit(0)
    }
    
    
    // helping functions
    
    func runScript(scriptName: String, arguments: String) {
        let task: NSTask = NSTask()
        task.launchPath = "\(NSBundle.mainBundle().pathForResource(scriptName, ofType: "command")!)"
        task.arguments = [arguments]
        task.launch()
        task.waitUntilExit()
    }
    
    
    func runTerminal(arguments: String) {
        let fileManager = NSFileManager.defaultManager()
        // Check if file exists, given its path
        if fileManager.fileExistsAtPath("/Applications/iTerm.app") {
            // lunch iTerm App
            NSWorkspace.sharedWorkspace().openFile(arguments, withApplication: "iTerm")
        } else {
            // lunch Terminal App
            NSWorkspace.sharedWorkspace().openFile(arguments, withApplication: "Terminal")
        }
    }
    
    
    func runApp(appName: String, arguments: String) {
        // lunch an external App
        NSWorkspace.sharedWorkspace().openFile(arguments, withApplication: appName)
    }
    
    // notifications
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    
    func displayWithMessage(mText: String, infoText: String) {
        let alert: NSAlert = NSAlert()
        // alert.alertStyle = NSInformationalAlertStyle
        // alert.icon = NSImage(named: "coreos-wordmark-vert-color")
        alert.messageText = mText
        alert.informativeText = infoText
        alert.runModal()
    }
    
}

