//
//  AppNavigationController.swift
//  Night Mode
//
//  Created by Michael on 01/04/2018.
//  Copyright © 2018 Late Night Swift. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {
	private var themedStatusBarStyle: UIStatusBarStyle?

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return themedStatusBarStyle ?? super.preferredStatusBarStyle
	}

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

extension AppNavigationController: Themed {
	func applyTheme(_ theme: AppTheme) {
		themedStatusBarStyle = theme.statusBarStyle
		setNeedsStatusBarAppearanceUpdate()

		navigationBar.barTintColor = theme.barBackgroundColor
		navigationBar.tintColor = theme.barForegroundColor
		navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: theme.barForegroundColor
		]
	}
}
