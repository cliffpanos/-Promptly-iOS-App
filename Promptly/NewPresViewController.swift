//
//  NewPresViewController.swift
//  Promptly
//
//  Created by Cliff Panos on 3/5/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

class NewPresViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!

    @IBOutlet weak var minuteStepper: UIStepper!
    @IBOutlet weak var secondStepper: UIStepper!
    @IBOutlet weak var timeDisplay: UILabel!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var baseline: CGFloat!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        C.NewPresVC = self
        print("initializing SettingsViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        baseline = scrollView.frame.origin.y

        setupTextFieldAccessoryViews()
        
    }
    
    
    func setupTextFieldAccessoryViews() {
        
        for textField in [titleTextField, descriptionTextField, timeTextField] {
            let numberToolbar: UIToolbar = UIToolbar()
            numberToolbar.barStyle = UIBarStyle.default
            
            numberToolbar.items = [
   
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
            ]
        
            numberToolbar.sizeToFit()
        
            textField?.inputAccessoryView = numberToolbar
        }

    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("NEXT TEXT FIELD")
        
        if textField == titleTextField {
            descriptionTextField.becomeFirstResponder()
        } else if textField == descriptionTextField {
            dismissKeyboard()
            return false
        }
        return true
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
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        guard timeTextField.isEditing else {
            return
        }

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollView.frame.origin.y == baseline {
                scrollView.frame.origin.y -= keyboardSize.height
                //scrollView.frame.size.height -= keyboardSize.height
            }
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInsets;
            scrollView.scrollIndicatorInsets = contentInsets;
            scrollView.sendSubview(toBack: self.view)
            scrollView.layer.zPosition = 10
            navigationBar.layer.zPosition = 1
            view.bringSubview(toFront: navigationBar)
            
            scrollView.setContentOffset(CGPoint(x: 0, y: keyboardSize.height), animated: true)
        }
        


        // If active text field is hidden by keyboard, scroll it so it's visible
        /* Your app might not need or want this behavior.
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
            [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
        }*/

    }
    
    func keyboardWillHide(notification: NSNotification) {
    
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if scrollView.frame.origin.y != baseline {
                scrollView.frame.origin.y += keyboardSize.height
                //scrollView.frame.size.height += keyboardSize.height

                }
            let contentInsetZero = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            scrollView.contentInset = contentInsetZero
            scrollView.scrollIndicatorInsets = contentInsetZero

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
        let minutes = Int(minuteStepper.value)
        let seconds = Int(secondStepper.value)
        
        let success = C.save(presentation: nil, title: title ?? "Title", details: description ?? "", durationMinutes: minutes, durationSeconds: seconds, alertTimesArray: [5, 10])
        
        if success {
            print("successful")
            C.VC.tableView.reloadData()
        } else {
            //TODO handle unsuccessful saving
        }
        
        self.dismiss(animated: true, completion: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

}
