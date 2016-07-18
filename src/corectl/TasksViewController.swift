//
//  TasksViewController.swift
//  corectl
//
//  Created by Rimantas Mocevicius on 18/07/2016.
//  Copyright © 2016 The New Normal. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
    
    // Controller Outlets
   
    @IBOutlet var taskOutputText: NSTextView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var downloadButton: NSButton!

    dynamic var isRunning = false
    var outputPipe:NSPipe!
    var shellTask:NSTask!
    var scriptName:String = ""
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //
        switch pass_to_TasksViewController {
            case "os_alpha" :
                print(pass_to_TasksViewController)
                scriptName = "fetch_latest_iso_alpha"
            case "os_beta" :
                print(pass_to_TasksViewController)
                scriptName = "fetch_latest_iso_beta"
            case "os_stable" :
                print(pass_to_TasksViewController)
                scriptName = "fetch_latest_iso_stable"
            default :
                print(pass_to_TasksViewController)
                scriptName = "update_corectl_blobs"
        }
        
        //
        taskOutputText.string = ""
        
        //
        downloadButton.enabled = false
        spinner.startAnimation(self)
        
        //
        runShellScript(scriptName)
    }
    
    
    
    @IBAction func Close(sender: NSButton) {
        
        isRunning = false
        
        self.view.window?.releasedWhenClosed
        
        // Hide Main Window
        NSApplication.sharedApplication().mainWindow?.close()
        //self.view.window?.close()
        
        // reset wait queue
        wait_queue = 0
    }

    
    @IBAction func downloadTask(sender: AnyObject) {
        //
        taskOutputText.string = ""
            
        //
        downloadButton.enabled = false
        spinner.startAnimation(self)
        
        //
        runShellScript(scriptName)
    }


    @IBAction func stopDownloadTask(sender: AnyObject) {
        
        if isRunning {
            shellTask.terminate()
        }
    }

    
    //
    func runShellScript(scriptName:String) {
        
        //
        isRunning = true
        
        let taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        
        //
        dispatch_async(taskQueue) {
            
            //
            guard let path = NSBundle.mainBundle().pathForResource(scriptName, ofType:"command") else {
                print("Unable to locate script: " + scriptName )
                return
            }
            
            //
            self.shellTask = NSTask()
            self.shellTask.launchPath = path
            //self.shellTask.arguments = arguments
            
            //
            self.shellTask.terminationHandler = {
                
                task in
                dispatch_async(dispatch_get_main_queue(), {
                    self.downloadButton.enabled = true
                    self.spinner.stopAnimation(self)
                    self.isRunning = false
                })
                
            }
            
            self.captureStandardOutputAndRouteToTextView(self.shellTask)
            
            //
            self.shellTask.launch()
            
            //
            self.shellTask.waitUntilExit()
        }

    }
        
    
    
    //
    func captureStandardOutputAndRouteToTextView(task:NSTask) {
            
            //
            outputPipe = NSPipe()
            task.standardOutput = outputPipe
            
            //
            outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            
            //
            NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: outputPipe.fileHandleForReading , queue: nil) {
                notification in
                
                //
                let output = self.outputPipe.fileHandleForReading.availableData
                let outputString = String(data: output, encoding: NSUTF8StringEncoding) ?? ""
                
                //
                dispatch_async(dispatch_get_main_queue(), {
                    let previousOutput = self.taskOutputText.string ?? ""
                    let nextOutput = previousOutput + "\n" + outputString
                    self.taskOutputText.string = nextOutput
                    
                    let range = NSRange(location:nextOutput.characters.count,length:0)
                    self.taskOutputText.scrollRangeToVisible(range)
                })
                
                //
                self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
                
            }
    }
        
        
}

