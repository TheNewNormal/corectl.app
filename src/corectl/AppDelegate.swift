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
    @IBOutlet weak var statusMenu: NSMenu!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "StatusItemIcon")
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // check if App runs from DMG
        check_for_dmg()
        
        // enable launch at login
        addToLoginItems()
        
        // check if sudo password for the App is saved in keychain
        check_sudo_password()
        
        // check if corectl blobs are in place
        check_for_corectl_blobs()
        
        // check for latest corectl blobs on github
        check_for_corectl_blobs_github()
        
        // start corectld server
        ServerStartShell()
        
        // check for latest blobs on github
        _ = NSTimer.scheduledTimerWithTimeInterval(3600.0, target: self, selector: #selector(AppDelegate.check_for_corectl_blobs_github), userInfo: nil, repeats: true)
    }
    
    
    // menu functions //
 
    @IBAction func Server(sender: NSMenuItem) {
        // an empty funtion just to create menu item
    }
    

    // restart corectld server
    @IBAction func Restart(sender: NSMenuItem) {
        let menuItem : NSStatusItem = statusItem
        menuItem.menu?.itemWithTag(1)?.title = "Server is stopping"
        
        // stop corectld server
        ServerStop()
        ServerStop()
        
        sleep(5)

        menuItem.menu?.itemWithTag(1)?.title = "Server is starting"
        // start corectld server
        ServerStartShell()
        //
        menuItem.menu?.itemWithTag(3)?.title = "Check for updates"
    }
    
    
    // check and download updates for corectl
    @IBAction func checkForUpdates(sender: NSMenuItem) {
        
        // send a notification on to the screen
        let notification: NSUserNotification = NSUserNotification()
        notification.title = "Corectl"
        notification.informativeText = "Updates for corectl binaries will be checked"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        //
        let script = NSBundle.mainBundle().resourcePath! + "/check_blobs_version.command"
        let status = shell(script, arguments: [])
        
        if (status == "yes"){
            // send a notification on to the screen
            let notification: NSUserNotification = NSUserNotification()
            notification.title = "Corectl"
            notification.informativeText = "corectl binaries will be updated"
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
            
            // run update script
            runTerminal(NSBundle.mainBundle().resourcePath! + "/update_corectl_blobs.command")
        }
        else
        {
            let mText: String = "Corectl for macOS "
            let infoText: String = "You are up-to-date ..."
            displayWithMessage(mText, infoText: infoText)
        }
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
    // fetch latest ISOs

    
    // About App
    @IBAction func About(sender: NSMenuItem) {
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")as? String
        let mText: String = "Corectl for macOS v" + version!
        let infoText: String = "It is a simple wrapper around the corectld server, which allows to have a control via the Status Bar App !!!"
        displayWithMessage(mText, infoText: infoText)
    }
    

    // Quit App
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
    // menu functions //
    
    
    // Other funtions //
    
    // check for updates every hour
    func check_for_corectl_blobs_github()
    {
        print("Checking for blobs on github ...")
        let script = NSBundle.mainBundle().resourcePath! + "/check_blobs_version.command"
        let status = shell(script, arguments: [])
        //
        if (status == "yes"){
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.itemWithTag(3)?.title = "Download updates..."
            let mText: String = "Corectl for macOS "
            let infoText: String = "There is an update available, please run via menu - Download updates... !!!"
            displayWithMessage(mText, infoText: infoText)
        }
    }
    
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
    
}

