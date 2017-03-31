//
//  C.swift
//  Promptly
//
//  Created by Cliff Panos on 3/3/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

//  Controller class to hold class instances and static methods

import UIKit
import CoreData
import WatchConnectivity
import AudioToolbox

class C {
    
    static var VC: HomeViewController!
    static var NewPresVC: NewPresViewController!
    static var SettingsVC: SettingsViewController!
    static var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    static var session: WCSession?
    
    static func sendMessage(with type: [String : Any]) {
     
        print("Sending message")
        
        guard (C.session?.isReachable)! else {
            return
        }
        
        session?.sendMessage(type, replyHandler: {(reply: [String : Any]) -> Void in
            print(reply)
        }, errorHandler: {error in print(error)})
    
    }
    
    static func save(presentation: Presentation?, title: String, details: String,
            durationMinutes: Int, durationSeconds: Int, alertTimesArray: [Int]) -> Bool {
        
        guard let appDelegate = C.appDelegate else {
            print("no appDelegate")
            return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let newPres: Bool = presentation == nil
        let pres = presentation ?? Presentation(context: managedContext)
        
        let alertTimesString: String = alertTimesToString(from: alertTimesArray)
        
        pres.title = title
        pres.details = details
        pres.durationMinutes = Int16(durationMinutes)
        pres.durationSeconds = Int16(durationSeconds)
        pres.alertTimes = alertTimesString
        
        do {
            try managedContext.save()
            if newPres {
                C.VC.presentations.append(pres)
            }
            print("PRESENTATION SAVED / UPDATED\n\n")
            return true
        } catch let error as NSError {
            print("Could not save: \(error.localizedDescription)")
            return false
        }
        
    }
    
    static func delete(presentation: Presentation) -> Bool {
        
        let managedContext = C.appDelegate?.persistentContainer.viewContext
        
        managedContext?.delete(presentation)
        do {
            try managedContext?.save()
            print("DELETED\n")
            return true
        } catch let error as NSError {
            print(error.localizedDescription)
            return false
        }
    }
    
    static func alertTimesToString(from array: [Int]) -> String {
        
        return ""
    }

}
