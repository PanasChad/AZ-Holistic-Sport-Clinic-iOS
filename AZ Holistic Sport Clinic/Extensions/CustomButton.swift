//
//  CustomButton.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 23/04/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

//
//  CustomLabel.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 23/04/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit

@IBDesignable  class CustomButton: UIButton {
    
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

extension CustomButton: Themed {
    func applyTheme(_ theme: AppTheme) {
        self.setTitleColor(theme.buttonBlueColor, for: .normal)
    }
}


