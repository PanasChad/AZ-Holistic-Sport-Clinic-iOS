//
//  AppDelegate.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 18/10/2018.
//  Copyright © 2018 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = UserDefaults.standard
    var wasInBackground : Bool?
    
    func checkForAppUpdate() {
        var parameters_arr: [String:AnyObject] = [:]
        
        do{
                HTTP.POST(GlobalVar.URL+"check_version.php", parameters:parameters_arr) { response in
                //do things...
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                Swift.debugPrint(response.text)
                
                if let err = response.error {
                    Swift.debugPrint("Error: \(err.localizedDescription)")
                    
                    return //also notify app of failure as needed
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                GlobalVar.serverVersion = Double(json_response.value(forKey: "version") as! String)
                
                Swift.debugPrint("Result: \(json_response.value(forKey: "version"))")
                
                if (GlobalVar.runningVersion < GlobalVar.serverVersion)
                {
                    let alert = UIAlertController(title: NSLocalizedString("NEWVERSIONAVAILABLE", comment: "New Version"), message: NSLocalizedString("NEWVERSIONAVAILABLEDESC", comment:  "There is a newer version available for download! Please update the app by visiting the Apple Store."), preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { alertAction in
                        
                        UIApplication.shared.openURL(NSURL(string : GlobalVar.appURL) as! URL)
                        
                        //alert.dismiss(animated: true, completion: nil)
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.window!.rootViewController?.present(alert, animated: true, completion: nil)
                        })
                    }))
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.window!.rootViewController?.present(alert, animated: true, completion: nil)
                    })
                    
                }
                
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func registerForPushNotifications() {
        // Request user's permission to send notifications.
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        HTTP.globalRequest { req in
            req.timeoutInterval = 10
        }
    
        registerForPushNotifications()
        
        if (Util.existFile("az.sqlite")){
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController : MainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.wasInBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.wasInBackground = false
        
        //self.checkForAppUpdate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenParts.joined()
        
        GlobalVar.deviceTokenString=deviceTokenString
        
        defaults.setValue(deviceTokenString, forKey: Constants.KEY_DEVICE_TOKEN)
        
        print("Device Token: \(deviceTokenString)")
    }
        
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }


}

