//
//  HelpingFunctions.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 05/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Foundation
import Security


// helping functions

// check for updates every hour
func check_for_corectl_blobs_github()
{
    let script = NSBundle.mainBundle().resourcePath! + "/check_blobs_version.command"
    let status = shell(script, arguments: [])
    //
    if (status == "no"){
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
