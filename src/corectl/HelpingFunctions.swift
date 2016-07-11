//
//  HelpingFunctions.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 06/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Foundation
import Cocoa

// check sudo password via shell
func check_sudo_password() {
    let script = NSBundle.mainBundle().resourcePath! + "/check_sudo_password.command"
    let status = shell(script, arguments: [])
    //
    if (status == "no"){
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/set_sudo_password.command")
    }
}
// check sudo password via swift
func check_sudo_password2() {
    let app_keychain_value = Keychain.get("coreosctl-app")
    
    if ( app_keychain_value == nil )
    {
        print("there is no such keychain value ...")
        // run the script
        runTerminal(NSBundle.mainBundle().resourcePath! + "/set_sudo_password.command")
    }
}
//


// check if corectl blobs exist
func check_that_corectl_blobs_are_in_place() {
    let resoucesPathFromApp = NSBundle.mainBundle().resourcePath!
    let bin_folder = resoucesPathFromApp + "/bin"
    
    //
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
    //
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
    //
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
    //
    let filePath4 = "/usr/local/sbin/corectld.nameserver"
    if (NSFileManager.defaultManager().fileExistsAtPath(filePath4))
    {
        print("corectld.nameserver available");
    }
    else
    {
        print("corectld.nameserver not available");
        runScript("copy_corectl_blobs.command", arguments: bin_folder )
    }
    //
    let filePath5 = "/usr/local/sbin/corectld.store"
    if (NSFileManager.defaultManager().fileExistsAtPath(filePath5))
    {
        print("corectld.store available");
    }
    else
    {
        print("corectld.store not available");
        runScript("copy_corectl_blobs.command", arguments: bin_folder )
    }
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

