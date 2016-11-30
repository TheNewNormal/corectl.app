//
//  Updates.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 11/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Foundation
import Cocoa

// App latest version checks
// check for corectl App update/change menu item text
func check_for_corectl_app_github(_ showPopUp:String?=nil, runViaUpdateMenu:String?=nil) {
    //
    let script = Bundle.main.resourcePath! + "/check_corectl_app_version.command"
    let latest_app_version = shell(script, arguments: [])
    print("Latest app version: " + latest_app_version)
    //
    if (latest_app_version == "" ) {
        NSLog("We can not check the latest version on Github. There was either an API limit reached, or Github has technical issues.")
        return
    }
    //
    let installed_app_version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")as? String
    print("installed app version: " + installed_app_version!)
    //
    if (latest_app_version == "v" + installed_app_version!){
        NSLog("App update status: '%@'", "no")
        // then show popup on the screeen
        if (runViaUpdateMenu == "yes") {
            let mText: String = "Corectl App for macOS"
            let infoText: String = "You are up-to-date!"
            displayWithMessage(mText, infoText: infoText)
        }
        else {
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 3)?.title = "Check for App updates"
        }
    }
    else {
        NSLog("App update status: '%@'", "yes")
        //
        if (showPopUp == "yes") {
            // show popup on the screen
            download_corectl_app_github()
        }
        else {
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 3)?.title = "Download App updates"
        }
    }
}
// download corectl.app updates
func download_corectl_app_github() {
    // show popup on the screen
    let alert: NSAlert = NSAlert()
    alert.messageText = "There is a new version of the Corectl App available"
    alert.informativeText = "Open download URL in your browser?"
    alert.alertStyle = NSAlertStyle.warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    if alert.runModal() == NSAlertFirstButtonReturn {
        // if OK clicked 
        // open URL in default browser
        let url: String = "https://github.com/TheNewNormal/corectl.app/releases"
        NSWorkspace.shared().open(URL(string: url)!)
    }
    else {
        let menuItem : NSStatusItem = statusItem
        menuItem.menu?.item(withTag: 3)?.title = "Download App updates..."
    }
}
////


// corectld latest version checks
// check for corectl blobs update/change menu item text
func check_for_corectl_blobs_github(_ showPopUp:String?=nil, runViaUpdateMenu:String?=nil) {
    //
    let script = Bundle.main.resourcePath! + "/check_blobs_version.command"
    let status = shell(script, arguments: [])
    NSLog("Corectld update status: '%@'",status)
    //
    if (status == "yes"){
        if (showPopUp == "yes") {
            // we run via mneu, let's pass "yes" then
            download_corectl_blobs_github("yes")
        }
        else {
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 4)?.title = "Downloading Corectl updates…"
        }
    }
    else {
        if (runViaUpdateMenu == "yes") {
            let mText: String = "Corectld for macOS"
            let infoText: String = "You are up-to-date ..."
            displayWithMessage(mText, infoText: infoText)
        }
        else {
            let menuItem : NSStatusItem = statusItem
            menuItem.menu?.item(withTag: 4)?.title = "Check for Corectl updates"
        }
    }
}

// download corectl blobs
func download_corectl_blobs_github(_ runViaUpdateMenu:String?=nil) {
    let alert: NSAlert = NSAlert()
    alert.messageText = "There is a new version of the Corectld server available"
    alert.informativeText = "Do you want to download it?"
    alert.alertStyle = NSAlertStyle.warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    if alert.runModal() == NSAlertFirstButtonReturn {
        // if OK clicked
        // run update script
        runTerminal(Bundle.main.resourcePath! + "/update_corectl_blobs.command")
        //
//        if (runViaUpdateMenu == "yes"){
            // restart corectld server if no VMs are running
//            let script = NSBundle.mainBundle().resourcePath! + "/check_active_vms.command"
//            let status: String = shell(script, arguments: [])
//            NSLog("Active VMs: '%@'",status)
            //
//            if ( status == "0" ){
//                RestartServer()
//            }
            // restore menu item
//            let menuItem : NSStatusItem = statusItem
//            menuItem.menu?.itemWithTag(4)?.title = "Check for Corectl updates"
//        }
    }
    else {
        let menuItem : NSStatusItem = statusItem
        menuItem.menu?.item(withTag: 4)?.title = "Downloading Corectl updates…"
    }
}


func download_test() {
    
    if let audioUrl = URL(string: "https://github.com/TheNewNormal/corectl/releases/download/v0.7.5/corectl-v0.7.5-macOS-amd64.tar.gz") {
        
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent )
        print(destinationUrl)
        
        // to check if it exists before downloading it
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            
            // if the file doesn't exist
        } else {
            
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location , error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager().moveItem(at: location, to: destinationUrl)
                    print("File moved to documents folder")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }

}
////
