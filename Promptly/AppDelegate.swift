//
//  AppDelegate.swift
//  Promptly
//
//  Created by Cliff Panos on 2/18/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import AudioToolbox


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    static var navigationController: UINavigationController?
    static var already3DTouchedVC: UIViewController?
    static var session: WCSession?
    var launchedShortcutItem: UIApplicationShortcutItem?
        //Optional used for the 3D-Touch Quick Actions
    static var firstLaunch = true
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if WCSession.isSupported() {
            AppDelegate.session = WCSession.default()
            AppDelegate.session?.delegate = self
            AppDelegate.session?.activate()
            C.session = AppDelegate.session
            print("session \(String(describing: AppDelegate.session)) activated on iPhone")
            C.sendMessage(with: ["Activity" : "Session Activated"])
        }
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
            as? UIApplicationShortcutItem {
            launchedShortcutItem = shortcutItem
        }

        AppDelegate.navigationController = window?.rootViewController as? UINavigationController
        
        return true
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) { 
        print("received message")
        
        DispatchQueue.main.sync {
            C.SettingsVC.vibrateButton.setTitle("Message received", for: .normal)
        }
        
        switch (message["Activity"] as! String) {
        case "Session Activated" :
            DispatchQueue.main.sync {
                C.SettingsVC.statusLabel.text = "Session Activated"
            }
        case "ResignActive" :
            DispatchQueue.main.sync {
                C.SettingsVC.statusLabel.text = "Watch App inactive; session \(session.isReachable ? "Active" : "Inactive")"
            }
        case "Vibrate" :
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            DispatchQueue.main.sync {
                C.SettingsVC.statusLabel.text = "Vibrating"
            }
        default:
            DispatchQueue.main.sync {
                C.SettingsVC.statusLabel.text = "Message recieved"
            }
        }
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        C.SettingsVC.vibrateButton.setTitle("Inactive", for: .normal)
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        C.SettingsVC.vibrateButton.setTitle("Deactivated", for: .normal)
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        C.SettingsVC.vibrateButton.setTitle("Watch App Closed", for: .application)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        C.sendMessage(with: ["Activity" : "ResignActive"])
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        C.sendMessage(with: ["Activity" : "Session Activated"])
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        C.sendMessage(with: ["Activity" : "Session Activated"])
        
        guard let shortcut = launchedShortcutItem else { return }
        //guard unwraps launchedShortcutItem and checks if it is not null
        
        let _ = handleShortcutItem(shortcutItem: shortcut)
        launchedShortcutItem = nil
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    
    // MARK: - Handle 3D-Touch Home Screen Quick Actions
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        //Handles the 3D Touch Quick Actions from the home screen
        
        let handledShortcutItem: Bool = handleShortcutItem(shortcutItem: shortcutItem)
        completionHandler(handledShortcutItem)
        
    }

    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var handled = false
        guard let shortcutType = shortcutItem.type as String? //See info.plist
            else { return false }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let vc = AppDelegate.already3DTouchedVC, AppDelegate.firstLaunch {
            if shortcutType == "NewPresentation" && vc is NewPresViewController {
                return false
            }
            if shortcutType == "Settings" && vc is SettingsViewController {
                return false
            }
            AppDelegate.firstLaunch = false
        }
        
        if let touchedVC = AppDelegate.already3DTouchedVC {
            print("dismissing")
            if touchedVC is PresentationViewController {
                touchedVC.navigationController?.popViewController(animated: true)
            } else {
                touchedVC.dismiss(animated: false, completion: nil)
            }
        }

        switch(shortcutType) {
            
        case "NewPresentation" :
            
            let controller = storyboard.instantiateViewController(withIdentifier: "newPresViewController") as! NewPresViewController
            AppDelegate.already3DTouchedVC = controller
            AppDelegate.navigationController?.present(controller, animated: true, completion: {
                handled = true
            })
        
        case "Settings" :
            
            let controller = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
            AppDelegate.already3DTouchedVC = controller
            AppDelegate.navigationController?.present(controller, animated: true, completion: {
                handled = true
            })
            
        default: break
        }
        
        return handled
    }
    
    
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Promptly")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

