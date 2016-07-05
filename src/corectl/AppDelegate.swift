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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "StatusItemIcon")
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // check if App runs from DMG
        check_for_dmg()
        
        check_sudo_password()
        
        // check if corectl blobs are in place
        check_for_corectl_blobs()
        
        // check for latest corectl blobs on github
        check_for_corectl_blobs_github()

        // enable launch at login
        addToLoginItems()
        
        // start corectld server
        ServerStartShell()
        
        // check for latest blobs on github
        _ = NSTimer.scheduledTimerWithTimeInterval(3600.0, target: self, selector: #selector(AppDelegate.check_for_corectl_blobs_github), userInfo: nil, repeats: true)
        
        // create menu programmaticly
        //        let Quit : NSMenuItem = NSMenuItem(title: "Quit", action: #selector(AppDelegate.Quit(_:)), keyEquivalent: "")
        //        statusItem.menu!.addItem(Quit)
        //        statusItem.menu!.addItem(NSMenuItem.separatorItem())
    }
    
    
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
    

    @IBAction func Server(sender: NSMenuItem) {
        // an empty funtion just to create a menu item
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
        notification.informativeText = "corectl binaries will be updated"
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/update_corectl_blobs.command")
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
    
    
    // helping functions
    
    // check for updates every hour
    func check_for_corectl_blobs_github()
    {        
        let script = NSBundle.mainBundle().resourcePath! + "/check_blobs_version.command"
        let status = shell(script, arguments: [])
        //
        if (status == "yes"){
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.itemWithTag(3)?.title = "Download updates..."
            let mText: String = "Corectl for macOS "
            let infoText: String = "There is an update available, please run via menu Download updates... !!!"
            displayWithMessage(mText, infoText: infoText)
        }

    }
    
    // check sudo password
    func check_sudo_password() {
        let app_keychain_value = Keychain.get("coreosctl-app")
        
        if ( app_keychain_value == nil )
        {
            print("there is no such keychain value ...")
            // run the script
            runTerminal(NSBundle.mainBundle().resourcePath! + "/sudo_password.command")
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
    
    
    // check if corectl blobs exist
    func check_for_corectl_blobs() {
        let resoucesPathFromApp = NSBundle.mainBundle().resourcePath!
        let bin_folder = resoucesPathFromApp + "/bin"
        
        print(bin_folder)
        
        let filePath1 = "/usr/local/sbin/corectl"
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath1))
        {
            print("corectl available");
        }
        else
        {
            print("corectl not available");
            runScript("copy_corectl_blobs.command", arguments: bin_folder )
        }
        
        let filePath2 = "/usr/local/sbin/corectld"
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath2))
        {
            print("corectld available");
        }
        else
        {
            print("corectld not available");
            runScript("copy_corectl_blobs.command", arguments: bin_folder )
        }
        
        let filePath3 = "/usr/local/sbin/corectld.runner"
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath3))
        {
            print("corectld.runner available");
        }
        else
        {
            print("corectld.runner not available");
            runScript("copy_corectl_blobs.command", arguments: bin_folder )
        }
    }
    
    
    // run script
    func runScript(scriptName: String, arguments: String) {
        let task: NSTask = NSTask()
        let launchPath = NSBundle.mainBundle().resourcePath! + "/" + scriptName
        task.launchPath = launchPath
        task.arguments = [arguments]
        task.launch()
        task.waitUntilExit()
    }
    
    
    // terminal/iterm app
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
    
    
    // run an app
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
    
    
    // Adds the app to the system's list of login items.
    // NOTE: This is a relatively janky way of doing this. Using a
    // bundled helper app is Apple's recommended approach, but that
    // has a lot of configuration overhead to get right.
    func addToLoginItems() {
        NSTask.launchedTaskWithLaunchPath(
            "/usr/bin/osascript",
            arguments: [
                 "-e",
                 "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/corectl.app\", hidden:false, name:\"Corectl\"}"
            ]
        )
    }
    
    
    // shell commands to run
    func shell(launchPath: String, arguments: [String]) -> String
    {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: NSUTF8StringEncoding)!
        if output.characters.count > 0 {
            return output.substringToIndex(output.endIndex.advancedBy(-1))
        }
        return output
    }
    
}

