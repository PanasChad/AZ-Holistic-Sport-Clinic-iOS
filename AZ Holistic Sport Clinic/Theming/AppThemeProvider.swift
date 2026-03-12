//
//  AppThemeProvider.swift
//  Night Mode
//
//  Created by Michael on 01/04/2018.
//  Copyright © 2018 Late Night Swift. All rights reserved.
//

import UIKit

final class AppThemeProvider: ThemeProvider {
    static let shared: AppThemeProvider = .init()

    private var theme: SubscribableValue<AppTheme>
    private var availableThemes: [AppTheme] = [.light, .dark]
    private var automaticThemeEnabled = true
    private var traitObserver: NSObjectProtocol?

    var currentTheme: AppTheme {
        get {
            return theme.value
        }
        set {
            setNewTheme(newValue)
        }
    }

    init() {
        // Initialize theme with a default value first
        theme = SubscribableValue<AppTheme>(value: .light)
        
        // Now we can safely call methods on self
        let initialTheme = getCurrentSystemTheme()
        theme.value = initialTheme
        
        // Apply the initial navigation bar appearance
        updateNavigationBarAppearance(for: initialTheme)
        
        // Set up automatic theme switching
        setupAutomaticThemeDetection()
    }
    
    // MARK: - Helpers
    private func activeWindows() -> [UIWindow] {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
        } else {
            // keyWindow is deprecated on iOS 13+, safe for earlier
            return [UIApplication.shared.keyWindow].compactMap { $0 }
        }
    }
    
    private func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return activeWindows().first(where: { $0.isKeyWindow }) ?? activeWindows().first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    private func getCurrentSystemTheme() -> AppTheme {
        if #available(iOS 13.0, *) {
            // Prefer the key window's trait collection
            let style = keyWindow()?.traitCollection.userInterfaceStyle
                ?? UIScreen.main.traitCollection.userInterfaceStyle
            return style == .dark ? .dark : .light
        }
        return .light
    }
    
    private func setupAutomaticThemeDetection() {
        if #available(iOS 13.0, *) {
            // Remove any existing observer
            if let observer = traitObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            
            // Listen for app-activation changes (covers Settings toggles)
            traitObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateThemeFromSystem()
            }
            
            // Also check when the app will enter foreground
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateThemeFromSystem),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        }
    }
    
    @objc func updateThemeFromSystem() {
        guard automaticThemeEnabled else { return }
        
        let systemTheme = getCurrentSystemTheme()
        if systemTheme.statusBarStyle != currentTheme.statusBarStyle {
            currentTheme = systemTheme
        }
    }
    
    deinit {
        if let observer = traitObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self)
    }

    private func setNewTheme(_ newTheme: AppTheme) {
        // Try to animate on the key window if available, else just apply
        if let window = keyWindow() {
            UIView.transition(
                with: window,
                duration: 0.3,
                options: [.transitionCrossDissolve],
                animations: {
                    self.updateNavigationBarAppearance(for: newTheme)
                    self.theme.value = newTheme
                },
                completion: nil
            )
        } else {
            self.updateNavigationBarAppearance(for: newTheme)
            self.theme.value = newTheme
        }
    }
    
    private func updateNavigationBarAppearance(for theme: AppTheme) {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            
            let attrs = [
                NSAttributedString.Key.foregroundColor: theme.barForegroundColor
            ]
            
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = theme.barBackgroundColor
            appearance.titleTextAttributes = attrs
            
            // Apply proxy defaults for any bars created later
            UINavigationBar.appearance().tintColor = theme.barForegroundColor
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // Immediately update any existing navigation bars
            let windows = activeWindows()
            windows.forEach { window in
                // Update bars in root nav controllers
                func updateRecursively(_ vc: UIViewController?) {
                    guard let vc = vc else { return }
                    if let nav = vc as? UINavigationController {
                        // Skip Home screen as it has its own branding
                        if !(nav.topViewController is HomeViewController) {
                            nav.navigationBar.tintColor = theme.barForegroundColor
                            nav.navigationBar.standardAppearance = appearance
                            nav.navigationBar.compactAppearance = appearance
                            nav.navigationBar.scrollEdgeAppearance = appearance
                            nav.navigationBar.setNeedsLayout()
                            nav.navigationBar.layoutIfNeeded()
                        }
                    }
                    vc.children.forEach { updateRecursively($0) }
                    updateRecursively(vc.presentedViewController)
                }
                updateRecursively(window.rootViewController)
            }
        }
        
        // Also update the title text attributes for older iOS versions
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: theme.barForegroundColor]
    }

    func subscribeToChanges(_ object: AnyObject, handler: @escaping (AppTheme) -> Void) {
        theme.subscribe(object, using: handler)
    }

    func nextTheme() {
        guard let nextTheme = availableThemes.rotate() else {
            return
        }
        currentTheme = nextTheme
    }
}

extension Themed where Self: AnyObject {
    var themeProvider: AppThemeProvider {
        return AppThemeProvider.shared
    }
}
