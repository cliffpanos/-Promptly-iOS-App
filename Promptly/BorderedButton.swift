//
//  BorderedButton.swift
//  Promptly
//
//  Created by Cliff Panos on 4/5/17.
//  Copyright © 2017 Clifford Panos. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        
        didSet {
            self.layer.borderWidth = self.borderWidth
            self.layer.masksToBounds = true
        }
    
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.layer.masksToBounds = true
        }
        
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        
        didSet {
            self.layer.cornerRadius = CGFloat(self.cornerRadius)
            self.layer.masksToBounds = true
        }
    }
    
}
