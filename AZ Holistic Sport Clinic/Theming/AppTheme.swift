//
//  AppTheme.swift
//  Night Mode
//
//  Created by Michael on 01/04/2018.
//  Copyright © 2018 Late Night Swift. All rights reserved.
//

import UIKit

struct AppTheme {
	var statusBarStyle: UIStatusBarStyle
	var barBackgroundColor: UIColor
	var barForegroundColor: UIColor
	var backgroundColor: UIColor
	var textColor: UIColor
    var textBlueColor: UIColor
    var buttonBlueColor: UIColor
    var buttonRedColor: UIColor
}

extension AppTheme {
	static let light = AppTheme(
		statusBarStyle: .`default`,
		barBackgroundColor: .white,
		barForegroundColor: UIColor().convertHexStringToColor(GlobalVar.blueColor),
		backgroundColor: UIColor(white: 1.0, alpha: 1),
		textColor: .darkText,
        textBlueColor : UIColor().convertHexStringToColor(GlobalVar.blueColor),
        buttonBlueColor : UIColor().convertHexStringToColor(GlobalVar.blueColor),
        buttonRedColor: UIColor().convertHexStringToColor(GlobalVar.redColor)
	)

	static let dark = AppTheme(
		statusBarStyle: .lightContent,
		barBackgroundColor: UIColor(white: 0, alpha: 1),
		barForegroundColor: .white,
		backgroundColor: UIColor(white: 0.0, alpha: 1),
        textColor: .white,
        textBlueColor : .white,
        buttonBlueColor: .white,
        buttonRedColor: UIColor().convertHexStringToColor(GlobalVar.redColor)
	)
}
