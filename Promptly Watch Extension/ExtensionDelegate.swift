//
//  ExtensionDelegate.swift
//  Promptly Watch Extension
//
//  Created by Cliff Panos on 2/18/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    static var session: WCSession?
    static var firstScreen: InterfaceController?
    
    func setSession() {
        if WCSession.isSupported() {
            ExtensionDelegate.session = WCSession.default()
            ExtensionDelegate.session?.delegate = self
            ExtensionDelegate.session?.activate()
            print("session \(String(describing: ExtensionDelegate.session)) activated on Watch")
        }
        print("Nil session?: \(ExtensionDelegate.session == nil)")
        print("WATCH Session is reachable: \(String(describing: ExtensionDelegate.session?.isReachable))")
        ExtensionDelegate.session?.sendMessage(["Activity" : "Session Activated"], replyHandler: nil, errorHandler: nil)
    }


    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setSession()
        WC.ext = self
        
    }


    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ExtensionDelegate.session?.sendMessage(["Activity" : "Session Activated"], replyHandler: nil, errorHandler: nil)
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        print("Going inactive")
        do {
            try ExtensionDelegate.session?.updateApplicationContext(["Activity" : "ResignActive"])
        } catch let error as NSError {
            print("ERROR from Watch: \(error.localizedDescription)")
        }
        ExtensionDelegate.session?.sendMessage(["Activity" : "ResignActive"], replyHandler: nil, errorHandler: nil)
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
            ExtensionDelegate.firstScreen?.label.setText("Activation Comp.")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        ExtensionDelegate.firstScreen?.label.setText("Messaged!")
        
        switch (message["Activity"] as! String) {
        case "Session Activated" :
            ExtensionDelegate.firstScreen?.label.setText("Session Activated")
        case "ResignActive" :
            ExtensionDelegate.firstScreen?.label.setText("\(session.isReachable ? "Active" : "Inactive")")
        case "Vibrate" :
            ExtensionDelegate.vibrate()
        default:
            ExtensionDelegate.firstScreen?.label.setText("Message Received")
        }
        sleep(1)

        ExtensionDelegate.firstScreen?.label.setText("\(session.isReachable ? "Reachable" : "Inactive")")
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        ExtensionDelegate.firstScreen?.label.setText("Context updated!")
    }
    
    static func vibrate() {
        print("Vibrating Watch")
        WKInterfaceDevice.current().play(.notification)
        //firstScreen?.label.setText("Session is \(ExtensionDelegate.session)")
    }

}
