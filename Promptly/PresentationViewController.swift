//
//  PresentationViewController.swift
//  Promptly
//
//  Created by Cliff Panos on 3/19/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit
import CoreData

class PresentationViewController: UIViewController {

    @IBOutlet weak var presTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var presentButton: UIStackView!
    @IBOutlet weak var presentStackView: UIStackView!
    
    var presentation: Presentation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.already3DTouchedVC = self
        presTitle.text = presentation.title?.uppercased()
        subTitle.text = presentation.details
        timeLabel.text = "\(presentation.durationMinutes):\(presentation.durationSeconds)"
                
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Edit", style: .plain, target: #selector(editPressed), action: #selector(editPressed)), animated: true)
        

    }
    
    
    func editPressed() {
        print("edit pressed!")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "newPresViewController") as! NewPresViewController
        AppDelegate.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    static func present(for presentation: Presentation,
                        in navigationController: UINavigationController) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "presentationViewController") as! PresentationViewController
        
        controller.presentation = presentation
        
        navigationController.pushViewController(controller, animated: true)
        
    }
    
    
    
    
    // MARK: - Navigation

    @IBAction func unwindToViewController(sender: UIStoryboardSegue){
        //Must exist
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
