//
//  ThemeTraitObserver.swift
//  AZ Holistic Sport Clinic
//
//  Created by Assistant on 2025.
//

import UIKit

@available(iOS 13.0, *)
class ThemeTraitObserver: NSObject {
    private weak var themeProvider: AppThemeProvider?
    
    init(themeProvider: AppThemeProvider) {
        self.themeProvider = themeProvider
        super.init()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "traitCollection" {
            DispatchQueue.main.async { [weak self] in
                self?.themeProvider?.updateThemeFromSystem()
            }
        }
    }
}

extension AppThemeProvider {
    func updateThemeFromSystem() {
        guard automaticThemeEnabled else { return }
        
        let systemTheme = getCurrentSystemTheme()
        if systemTheme.statusBarStyle != currentTheme.statusBarStyle {
            currentTheme = systemTheme
        }
    }
}