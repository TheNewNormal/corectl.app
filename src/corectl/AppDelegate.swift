//
//  AppDelegate.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 28/06/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Cocoa
import Foundation
import Security

var statusItem = NSStatusBar.system().statusItem(withLength: -1)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var statusMenu: NSMenu!
    

    /////////
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = NSImage(named: "StatusItemIcon")
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // Initial checks and sets after applicationDidFinishLaunching
        
        // check if App runs from DMG
        check_for_dmg()
        
        // enable launch at login
        addToLoginItems()
        
        // run startMainFunctions()
        startMainFunctions()
    }
    
    
    // menu functions //
 
    @IBAction func Server(_ sender: NSMenuItem) {
        // an empty funtion just to create menu item
    }
    

    // restart corectld server
    @IBAction func Restart(_ sender: NSMenuItem) {
        //
        let menuItem : NSStatusItem = statusItem
        //
        let script = Bundle.main.resourcePath! + "/check_corectld_status.command"
        let status = shell(script, arguments: [])
        NSLog("corectld running status: '%@'",status)
        //
        if (status == "no") {
            menuItem.menu?.item(withTag: 1)?.title = "Server is starting"
            // start corectld server
            ServerStart()
            //
            menuItem.menu?.item(withTag: 3)?.title = "Check for updates"
        }
        else {
            //
            let alert: NSAlert = NSAlert()
            alert.messageText = "Restarting Corectld server will halt all your running VMs !!!"
            alert.informativeText = "Are you sure you want to do that?"
            alert.alertStyle = NSAlertStyle.warning
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == NSAlertFirstButtonReturn {
                // if OK clicked run restart server
                RestartServer()
            }
        }
    }
    ////
    
    // check and download updates for corectl and App
    // check fo updates for App
    @IBAction func checkForAppUpdates(_ sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "Updates for Corectl App will be checked"
        NSUserNotificationCenter.default.deliver(notification)
        
        // run check function
        check_for_corectl_app_github("yes", runViaUpdateMenu: "yes")
    }
    
    // check updates for corectl server
    @IBAction func checkForCorectldUpdates(_ sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "Updates for Corectl tools will be checked"
        NSUserNotificationCenter.default.deliver(notification)
        
        // run check function
        check_for_corectl_blobs_github("yes", runViaUpdateMenu: "yes")
        //download_test()
    }
    ////
    
    // fetch latest ISOs
    @IBAction func fetchLatestISOAlpha(_ sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Alpha ISO image will be updated"
        NSUserNotificationCenter.default.deliver(notification)
        
        // run the script
        runTerminal(Bundle.main.resourcePath! + "/fetch_latest_iso_alpha.command")
    }
//
    @IBAction func fetchLatestISOBeta(_ sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Beta ISO image will be updated"
        NSUserNotificationCenter.default.deliver(notification)
        
        // run the script
        runTerminal(Bundle.main.resourcePath! + "/fetch_latest_iso_beta.command")
    }
    //
    @IBAction func fetchLatestISOStable(_ sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Stable ISO image will be updated"
        NSUserNotificationCenter.default.deliver(notification)
        
        // run the script
        runTerminal(Bundle.main.resourcePath! + "/fetch_latest_iso_stable.command")
    }
    //// fetch latest ISOs

    
    // About App
    @IBAction func About(_ sender: NSMenuItem) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")as? String
        let mText: String = "Corectl for macOS v" + version!
        let infoText: String = "It is a simple wrapper around the \"corectld\" server, allows to have a control via the Status Bar App !!!"
        displayWithMessage(mText, infoText: infoText)
    }
    

    // Quit App
    @IBAction func Quit(_ sender: NSMenuItem) {
        //
        let alert: NSAlert = NSAlert()
        alert.messageText = "Quitting App will halt all your running VMs !!!"
        alert.informativeText = "Are you sure you want to close the App?"
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == NSAlertFirstButtonReturn {
            // if OK clicked 
            // send a notification on to the screen
            let notification: NSUserNotification = NSUserNotification()
            notification.title = "Quitting Corectl App"
            NSUserNotificationCenter.default.deliver(notification)

            // stop corectld server
            ServerStop()
        
            // stop docker registry
            runScript("stop_docker_registry.command", arguments: "" )
            
            // exit App
            exit(0)
        }
    }
    // menu functions //
    
    

    
    // functions to run on app start //
    
    func startMainFunctions() {
        // check if corectl blobs are in place
        check_that_corectl_blobs_are_in_place()
        
        // send stop to corectld just in case it was left running
        ServerStop()
        
        // start corectld server
        ServerStart()
        
        // start local docker registry
        startDockerRegistry()
        
        // check for corectl blobs latest version on github
        check_for_corectl_blobs_github("yes")
        
        // check for latest corectl.app release on github
        check_for_corectl_app_github("yes")
        
        // Timer
        // check for latest app and corectl blobs on github and update menu items
        _ = Timer.scheduledTimer(timeInterval: 14400.0, target: self, selector: #selector(AppDelegate.check_for_corectl_app_corectld_github), userInfo: nil, repeats: true)
        
        // check for server status
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(AppDelegate.server_status), userInfo: nil, repeats: true)
        
        // check for active VMs and update menu item
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(AppDelegate.active_vms), userInfo: nil, repeats: true)
    }
    
    ////
    
    
    // Other funtions //
    
    // check if app runs from dmg
    func check_for_dmg() {
        // get the App's main bundle path
        let resoucesPathFromApp = Bundle.main.resourcePath!
        NSLog("applicationDirectory: '%@'", resoucesPathFromApp)
        //
        let dmgPath: String = "/Volumes/corectl/corectl.app/Contents/Resources"
        NSLog("DMG resource path: '%@'", dmgPath)
        // check resourcePath and exit the App if it runs from the dmg
        if resoucesPathFromApp.isEqual(dmgPath) {
            // show alert message
            let mText: String = "\("Corectl App cannot be started from DMG !!!")"
            let infoText: String = "Please copy App to your Applications folder ..."
            displayWithMessage(mText, infoText: infoText)
            // exiting App
            NSApplication.shared().terminate(self)
        }
    }
    ////
    
    // Timer functions
    // Check/Update menu items
    // check server status and update menu
    func server_status() {
        let script = Bundle.main.resourcePath! + "/check_corectld_status.command"
        let status = shell(script, arguments: [])
        // NSLog("corectld running status: '%@'",status)
        //
        if (status == "yes"){
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 1)?.title = "Server is running"
        }
        else {
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 1)?.title = "Server is Off"
        }
    }
    
    
    // App latest version checks
    func check_for_corectl_app_corectld_github() {
        // check for corectl App update every hour
        check_for_corectl_app_github()
        // check for corectl blobs update every hour
        check_for_corectl_blobs_github()
    }
    
    
    // show active vms in the menu
    func active_vms() {
        let script = Bundle.main.resourcePath! + "/check_active_vms.command"
        let status: String = shell(script, arguments: [])
        //NSLog("Active VMs: '%@'",status)
        
        //
        if ( status != "0" ){
            // update menu item
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 10)?.title = " Active VMs: " + status
        }
        else {
            // update menu item
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 10)?.title = " Active VMs: 0"
        }
    }

}

