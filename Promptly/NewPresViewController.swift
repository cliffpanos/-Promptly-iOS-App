//
//  NewPresViewController.swift
//  Promptly
//
//  Created by Cliff Panos on 3/5/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class NewPresViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var minuteStepper: UIStepper!
    @IBOutlet weak var secondStepper: UIStepper!
    @IBOutlet weak var timeDisplay: UILabel!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    
    var baseline: CGFloat!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        C.NewPresVC = self
        print("initializing SettingsViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.already3DTouchedVC = self
        print("NewPresViewController")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        baseline = scrollView.frame.origin.y
        
    }
    
    @IBAction func minuteStepperChanged(_ sender: Any) {
        updateTimeDisplay()
    }
    @IBAction func secondStepperChanged(_ sender: Any) {
        updateTimeDisplay()
    }
    
    func updateTimeDisplay() {
        
        let minutes = Int(minuteStepper.value)
        let seconds = Int(secondStepper.value)

        let mm = String(format:"%02d", minutes)
        let ss = String(format:"%02d", seconds)

        timeDisplay.text = "\(mm):\(ss)"
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollView.frame.origin.y == baseline {
                scrollView.frame.origin.y -= keyboardSize.height
            }
        }

        print(scrollView.frame.origin.y)
        //scrollView.setContentOffset(CGPoint(x: 0, y: keyboardRectangle.height), animated: true)
    }
    
    func keyboardWillHide(notification: NSNotification) {
    
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if scrollView.frame.origin.y != baseline {
                    scrollView.frame.origin.y += keyboardSize.height
                }
        }

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func onCreatePressed(_ sender: Any) {
        
        let title = titleTextField.text
        let description = descriptionTextField.text
        let duration = 20
        
        let success = C.save(presentation: nil, title: title ?? "Presentation Title", details: description ?? "Presentation Details", durationMinutes: duration, durationSeconds: 30, alertTimesArray: [5, 10])
        
        if success {
            print("successful")
            C.VC.tableView.reloadData()
        } else {
            //TODO handle unsuccessful saving
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}
