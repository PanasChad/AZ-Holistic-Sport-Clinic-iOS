//
//  AppTabBarController.swift
//  Night Mode
//
//  Created by Michael on 01/04/2018.
//  Copyright © 2018 Late Night Swift. All rights reserved.
//

import UIKit

class AppTabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		setUpTheming()
	}

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                AppThemeProvider.shared.updateThemeFromSystem()
            }
        }
    }
}

extension AppTabBarController: Themed {
	func applyTheme(_ theme: AppTheme) {
		tabBar.barTintColor = theme.barBackgroundColor
		tabBar.tintColor = theme.barForegroundColor
        if #available (iOS 26.0, *) {
            tabBar.backgroundColor = .clear
        }
	}
}
