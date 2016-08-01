//
//  HelpingFunctions.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 06/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Foundation
import Cocoa

// check if corectl blobs exist
func check_that_corectl_blobs_are_in_place() {
    let resoucesPathFromApp = NSBundle.mainBundle().resourcePath!
    let bin_folder = resoucesPathFromApp + "/bin"
    
    //
    let filePath1 = "~/bin/corectl"
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
    let filePath2 = "~/bin/corectld"
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
    let filePath3 = "~/bin/corectld.runner"
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
    let filePath4 = "~/bin/qcow-tool"
    if (NSFileManager.defaultManager().fileExistsAtPath(filePath4))
    {
        print("qcow-tool available");
    }
    else
    {
        print("qcow-tool not available");
        runScript("copy_corectl_blobs.command", arguments: bin_folder )
    }

}

// start local docker registry
func startDockerRegistry() {
    let resoucesPathFromApp = NSBundle.mainBundle().resourcePath!
    runScript("start_docker_registry.command", arguments: resoucesPathFromApp )
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

