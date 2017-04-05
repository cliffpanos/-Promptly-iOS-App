//
//  SettingsViewController.swift
//  Promptly
//
//  Created by Cliff Panos on 3/18/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData
import AudioToolbox
import UserNotifications


class SettingsViewController: UIViewController {

    @IBOutlet weak var vibrateButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var session: WCSession!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        C.SettingsVC = self
        print("initializing SettingsViewController")
    }
    
    @IBAction func onVibrateButtonPressed(_ sender: Any) {
        print("Vibrating iPhone")
        self.session = AppDelegate.session
        
        vibrateButton.setTitle("Session active: \(AppDelegate.session != nil) \(session.activationState.rawValue)", for: .normal)
        
        print("Session is reachable?: \(session.isReachable)")
        do {
            try session?.updateApplicationContext(["Activity" : "Vibration"])
        } catch _ as NSError {
            vibrateButton.setTitle("Context update failed", for: .normal)
        }
        
        if (session?.activationState == .activated
            && (session?.isPaired)! && (session?.isWatchAppInstalled)!) {
            session?.sendMessage(["Activity" : "Vibrate"], replyHandler: {action in
                print("action handler sent to iPhone")
            }, errorHandler: {error in
                print("error handler")}
            )
            print("sending message from iPhone")
            
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Alert!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Rise and shine! It's morning time!",                                            arguments: nil)
        
        // Configure the trigger for a wakeup.
        var dateInfo = DateComponents()
        dateInfo.hour = 0
        dateInfo.minute = 29
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "MorningAlarm", content: content, trigger: trigger)
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }

    }
    
    
    @IBAction func unwindToViewController (sender: UIStoryboardSegue){
        _ = self.navigationController?.popViewController(animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
