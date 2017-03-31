//
//  InterfaceController.swift
//  Promptly Watch Extension
//
//  Created by Cliff Panos on 2/18/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet var vibrateButton: WKInterfaceButton!
    @IBOutlet var label: WKInterfaceLabel!
    
    var session: WCSession?

    static var instance: InterfaceController!
    	
    /*override init() {
        super.init()
        InterfaceController.instance = self
    }*/
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        ExtensionDelegate.firstScreen = self
        session = ExtensionDelegate.instance.session

    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func onVibrateButtonPressed() {
        print("Vibration button pressed")
        ExtensionDelegate.vibrate()
        session?.sendMessage(["Activity" : "Vibrate"], replyHandler: nil, errorHandler: nil)
    }


}
