//
//  AppDelegate.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 28/06/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Cocoa

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
    

    @IBAction func Quit(sender: NSMenuItem) {
        // stop corectld server
        ServerStop()
        
        // exit App
        exit(0)
    }
}

