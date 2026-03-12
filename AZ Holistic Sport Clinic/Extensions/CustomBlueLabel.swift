//
//  CustomLabel.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 23/04/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit

@IBDesignable  class CustomBlueLabel: UILabel {
    
    func setup() {
        setUpTheming()
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
}

extension CustomBlueLabel: Themed {
    func applyTheme(_ theme: AppTheme) {
        self.textColor = theme.textBlueColor
    }
}

