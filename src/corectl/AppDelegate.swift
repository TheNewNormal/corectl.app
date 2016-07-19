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

var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var passwordWindow: NSWindow!
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var sudoPassword: NSSecureTextField!
    

    /////////
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "StatusItemIcon")
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // Initial checks and sets after applicationDidFinishLaunching
        
        // check if App runs from DMG
        check_for_dmg()
        
        // enable launch at login
        addToLoginItems()
        
        // check if sudo password for the App is saved in keychain
        // if successful, then run startMainFunctions()
        check_and_set_sudo_password("yes")
    }
    
    
    // menu functions //
 
    @IBAction func Server(sender: NSMenuItem) {
        // an empty funtion just to create menu item
    }
    

    // restart corectld server
    @IBAction func Restart(sender: NSMenuItem) {
        //
        let menuItem : NSStatusItem = statusItem
        //
        let script = NSBundle.mainBundle().resourcePath! + "/check_corectld_status.command"
        let status = shell(script, arguments: [])
        NSLog("corectld running status: '%@'",status)
        //
        if (status == "no") {
            menuItem.menu?.itemWithTag(1)?.title = "Server is starting"
            // start corectld server
            ServerStartShell()
            //
            menuItem.menu?.itemWithTag(3)?.title = "Check for updates"
        }
        else {
            //
            let alert: NSAlert = NSAlert()
            alert.messageText = "Restarting Corectld server will halt all your running VMs !!!"
            alert.informativeText = "Are you sure you want to do that?"
            alert.alertStyle = NSAlertStyle.WarningAlertStyle
            alert.addButtonWithTitle("OK")
            alert.addButtonWithTitle("Cancel")
            if alert.runModal() == NSAlertFirstButtonReturn {
                // if OK clicked run restart server
                RestartServer()
            }
        }
    }
    ////
    
    // check and download updates for corectld and App
    // check fo updates for App
    @IBAction func checkForAppUpdates(sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "Updates for Corectl App will be checked"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run check function
        check_for_corectl_app_github("yes", runViaUpdateMenu: "yes")
    }
    
    // check updates for corectld server
    @IBAction func checkForCorectldUpdates(sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "Updates for Corectld server will be checked"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run check function
        check_for_corectl_blobs_github("yes", runViaUpdateMenu: "yes")
        //download_test()
    }
    ////
    
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
//
    @IBAction func fetchLatestISOBeta(sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Beta ISO image will be updated"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/fetch_latest_iso_beta.command")
    }
    //
    @IBAction func fetchLatestISOStable(sender: NSMenuItem) {
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "CoreOS Stable ISO image will be updated"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/fetch_latest_iso_stable.command")
    }
    //// fetch latest ISOs

    
    // About App
    @IBAction func About(sender: NSMenuItem) {
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")as? String
        let mText: String = "Corectl for macOS v" + version!
        let infoText: String = "It is a simple wrapper around the corectld server, allows to have a control via the Status Bar App !!!"
        displayWithMessage(mText, infoText: infoText)
    }
    

    // Quit App
    @IBAction func Quit(sender: NSMenuItem) {
        //
        let alert: NSAlert = NSAlert()
        alert.messageText = "Quitting App will halt all your running VMs !!!"
        alert.informativeText = "Are you sure you want to close the App?"
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        if alert.runModal() == NSAlertFirstButtonReturn {
            // if OK clicked 
            // send a notification on to the screen
            let notification: NSUserNotification = NSUserNotification()
            notification.title = "Quitting Corectl App"
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)

            // stop corectld server
            ServerStop()
        
            // clean up - kill all corectld processes
            runScript("halt_corectld.command", arguments: "" )
            
            // exit App
            exit(0)
        }
    }
    // menu functions //
    
    
    // password functions //
    //OK button
    @IBAction func passwordOK(sender: NSButton) {
        
            // get data from sudoPassword field
            let sudo_pass: String = sudoPassword.stringValue
        
            // validate sudo password
            let script = NSBundle.mainBundle().resourcePath! + "/validate_sudo_password.command"
            let sudo_status = shell(script, arguments: [sudo_pass])
            NSLog("corectld running status: '%@'",sudo_status)
            //
            if (sudo_status == "no") {
                NSLog("sudo password is incorrect !!!")
                sudoPassword.stringValue = ""
            }
            else {
                // save sudo password to keychain
                let script2 = NSBundle.mainBundle().resourcePath! + "/set_sudo_password.command"
                shell(script2, arguments: [sudo_pass])
            
                // Hide PasswordWindow
                passwordWindow.orderOut(self)
                NSApplication.sharedApplication().mainWindow?.close()
            
                // functions to run on app start
                startMainFunctions()
            }
    }
    
    //Cancel button
    @IBAction func passwordCancel(sender: NSButton) {
        // Hide PasswordWindow
        passwordWindow.orderOut(self)
        
        // show alert message
        let mText: String = "\("Corectl App cannot function without 'sudo' password !!!")"
        let infoText: String = "The App will be closed ..."
        displayWithMessage(mText, infoText: infoText)
        
        // exiting App
        NSApplication.sharedApplication().terminate(self)
    }
    
    // check/set sudo password
    func check_and_set_sudo_password(MainFunctions:String?) {
        let script = NSBundle.mainBundle().resourcePath! + "/check_saved_sudo_password.command"
        let status = shell(script, arguments: [])
        //
        if (status == "no"){
            // show PasswordWindow
            passwordWindow.makeKeyAndOrderFront(self)
            NSApp.activateIgnoringOtherApps(true)
        }
        else {
            if (MainFunctions == "yes") {
                // functions to run on app start
                startMainFunctions()
            }
        }
    }
    // password functions //
    
    // functions to run on app start //
    
    func startMainFunctions() {
        // check if corectl blobs are in place
        check_that_corectl_blobs_are_in_place()
        
        // check for corectl blobs latest version on github
        check_for_corectl_blobs_github("yes")
        
        // start corectld server
        ServerStartShell()
        
        // check for latest corectl.app release on github
        check_for_corectl_app_github("yes")
        
        // Timer
        // check for latest app and corectl blobs on github and update menu items
        _ = NSTimer.scheduledTimerWithTimeInterval(14400.0, target: self, selector: #selector(AppDelegate.check_for_corectl_app_corectld_github), userInfo: nil, repeats: true)
        
        // check for server status
        _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(AppDelegate.server_status), userInfo: nil, repeats: true)
        
        // check for active VMs and update menu item
        _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(AppDelegate.active_vms), userInfo: nil, repeats: true)
    }
    
    ////
    
    
    // Other funtions //
    
    // check if app runs from dmg
    func check_for_dmg() {
        // get the App's main bundle path
        let resoucesPathFromApp = NSBundle.mainBundle().resourcePath!
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
            NSApplication.sharedApplication().terminate(self)
        }
    }
    ////
    
    // Timer functions
    // Check/Update menu items
    // check server status and update menu
    func server_status() {
        let script = NSBundle.mainBundle().resourcePath! + "/check_corectld_status.command"
        let status = shell(script, arguments: [])
        // NSLog("corectld running status: '%@'",status)
        //
        if (status == "yes"){
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.itemWithTag(1)?.title = "Server is running"
        }
        else {
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.itemWithTag(1)?.title = "Server is Off"
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
        let script = NSBundle.mainBundle().resourcePath! + "/check_active_vms.command"
        let status: String = shell(script, arguments: [])
        //NSLog("Active VMs: '%@'",status)
        
        //
        if ( status != "0" ){
            // update menu item
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.itemWithTag(10)?.title = " Active VMs: " + status
        }
        else {
            // update menu item
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.itemWithTag(10)?.title = " Active VMs: 0"
        }
    }

}

