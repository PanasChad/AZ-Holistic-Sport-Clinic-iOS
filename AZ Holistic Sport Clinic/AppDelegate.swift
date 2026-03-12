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
import DropDown
import ANLoader

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
    
    func registerForPushNotifications(_ application: UIApplication) {
        // Request user's permission to send notifications.
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                
                self?.getNotificationSettings()
        }
        
        application.registerForRemoteNotifications()
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
        
        // Initialize automatic theme switching (applies and manages UINavigationBar appearance)
        _ = AppThemeProvider.shared
        
        GlobalVar.deviceLang = NSLocale.current.languageCode
        
        DropDown.startListeningToKeyboard()
        
        registerForPushNotifications(application)
        
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
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable : Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        let aps = userInfo["aps"] as! [AnyHashable : Any]
        let type:String = userInfo["type"] as! String
        
        //debugPrint(userInfo)
        //debugPrint(userInfo["type"])
        //debugPrint(userInfo["no"])
        //debugPrint(aps["alert"])
        
        //debugPrint(application.applicationState)
        if (type == "news" || type == "questionnaire"){
            ANLoader.showLoading("Loading", disableUI: true)
            
            var parameters_arr: [String:AnyObject] = [:]
            
            parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
            parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
            
            do{
                HTTP.POST(GlobalVar.URL+"synch.php", parameters:parameters_arr) { response in
                    //do things...
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    if let err = response.error {
                        ANLoader.hide()
                        
                        Swift.debugPrint("Error: \(err.localizedDescription)")
                        
                        let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        return //also notify app of failure as needed
                    }
                    
                    let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                    
                    if (json_response.value(forKey: "error") as! String == "true"){
                        ANLoader.hide()
                        
                        let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                            
                        }
                        
                        return //also notify app of failure as needed
                    }
                    
                    DispatchQueue.main.async {
                        let date = Date()
                        let formatter = DateFormatter()
                        let dateFormatterPrint = DateFormatter()
                        
                        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                        dateFormatterPrint.dateFormat = "dd MMMM yyyy, HH:mm:ss"
                        //dateFormatterPrint.string(from: date!)
                        
                        //Get Date
                        let today = formatter.string(from: date)
                        
                        self.defaults.set(today, forKey: "synch_date")
                        
                        let values : NSMutableDictionary = NSMutableDictionary()
                        
                        values.setValue(json_response.value(forKey: "customer_fullname"), forKey: "customer_fullname")
                        values.setValue(json_response.value(forKey: "customer_end_of_subscription"), forKey: "customer_end_of_subscription")
                        values.setValue(json_response.value(forKey: "customer_remaining_amount"), forKey: "customer_remaining_amount")
                        values.setValue(json_response.value(forKey: "customer_next_appointment"), forKey: "customer_next_appointment")
                        values.setValue(json_response.value(forKey: "customer_questionnaire_exists"), forKey: "customer_questionnaire_exists")
                        values.setValue(json_response.value(forKey: "customer_questionnaire_already_answer"), forKey: "customer_questionnaire_already_answer")
                        
                        ModelManager.getInstance().updateAll("customer", valuesDictionary: values)
                        
                        //Check Ins
                        
                        ModelManager.getInstance().deleteAll("week")
                        
                        let values_week : NSMutableDictionary = NSMutableDictionary()
                        values_week.setValue(json_response.value(forKey: "week_name_5") as! String, forKey: "week_name_5")
                        values_week.setValue(json_response.value(forKey: "week_name_4") as! String, forKey: "week_name_4")
                        values_week.setValue(json_response.value(forKey: "week_name_3") as! String, forKey: "week_name_3")
                        values_week.setValue(json_response.value(forKey: "week_name_2") as! String, forKey: "week_name_2")
                        values_week.setValue(json_response.value(forKey: "week_name_1") as! String, forKey: "week_name_1")
                        
                        values_week.setValue(json_response.value(forKey: "week_value_5") as! String, forKey: "week_value_5")
                        values_week.setValue(json_response.value(forKey: "week_value_4") as! String, forKey: "week_value_4")
                        values_week.setValue(json_response.value(forKey: "week_value_3") as! String, forKey: "week_value_3")
                        values_week.setValue(json_response.value(forKey: "week_value_2") as! String, forKey: "week_value_2")
                        values_week.setValue(json_response.value(forKey: "week_value_1") as! String, forKey: "week_value_1")
                        
                          if let latest_checkin = json_response.value(forKey: "latest_checkin") as? String {
                                            values_week.setValue(latest_checkin, forKey: "latest_checkin")
                                        }
                        
                        ModelManager.getInstance().insert("week", valuesDictionary: values_week)
                        
                        //Questions
                        ModelManager.getInstance().deleteAll("question")
                        
                        //News
                        ModelManager.getInstance().deleteAll("news")
                        
                        //Getting the JSON array teams from the response
                        var data: NSArray = (json_response.value(forKey: "news")as! NSDictionary).value(forKey: "data") as! NSArray
                        
                        //looping through all the json objects in the array teams
                        for i in 0 ..< data.count{
                            let values : NSMutableDictionary = NSMutableDictionary()
                            let data_rec : NSDictionary = data[i] as! NSDictionary
                            var isRead = 0

                            if let rawDateStr = data_rec.value(forKey: "news_date") as? String {
                                let df = DateFormatter()
                                df.dateFormat = "yyyy-MM-dd"
                                let dateStr = String(rawDateStr.prefix(10))
                                if let d = df.date(from: dateStr),
                                   let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()),
                                   d < thirtyDaysAgo {
                                    isRead = 1
                                }
                            }
                            
                            values.setValue(data_rec.value(forKey: "news_id"), forKey: "news_id")
                            values.setValue(data_rec.value(forKey: "news_title_en"), forKey: "news_title_en")
                            values.setValue(data_rec.value(forKey: "news_title_el"), forKey: "news_title_el")
                            values.setValue(data_rec.value(forKey: "news_text_en"), forKey: "news_text_en")
                            values.setValue(data_rec.value(forKey: "news_text_el"), forKey: "news_text_el")
                            values.setValue(data_rec.value(forKey: "news_date"), forKey: "news_date")
                            values.setValue(isRead, forKey: "news_read")
                            
                            ModelManager.getInstance().insert("news", valuesDictionary: values)
                            
                        }
                        
                        //Getting the JSON array teams from the response
                        data = (json_response.value(forKey: "questions")as! NSDictionary).value(forKey: "data") as! NSArray
                        
                        //looping through all the json objects in the array teams
                        for i in 0 ..< data.count{
                            let values : NSMutableDictionary = NSMutableDictionary()
                            let data_rec : NSDictionary = data[i] as! NSDictionary
                            
                            values.setValue(data_rec.value(forKey: "question_id"), forKey: "question_id")
                            values.setValue(data_rec.value(forKey: "question_en"), forKey: "question_en")
                            values.setValue(data_rec.value(forKey: "question_el"), forKey: "question_el")
                            
                            
                            ModelManager.getInstance().insert("question", valuesDictionary: values)
                            
                        }
                        
                        //Diet
                        ModelManager.getInstance().deleteAll("diet_customer")
                        
                        //Getting the JSON array teams from the response
                        data = (json_response.value(forKey: "diet")as! NSDictionary).value(forKey: "data") as! NSArray
                        
                        //looping through all the json objects in the array teams
                        for i in 0 ..< data.count{
                            let values : NSMutableDictionary = NSMutableDictionary()
                            let data_rec : NSDictionary = data[i] as! NSDictionary
                            
                            values.setValue(data_rec.value(forKey: "diet_customer_time"), forKey: "diet_customer_time")
                            values.setValue(data_rec.value(forKey: "diet_customer_title_en"), forKey: "diet_customer_title_en")
                            values.setValue(data_rec.value(forKey: "diet_customer_title_el"), forKey: "diet_customer_title_el")
                            values.setValue(data_rec.value(forKey: "diet_customer_monday_text"), forKey: "diet_customer_monday_text")
                            values.setValue(data_rec.value(forKey: "diet_customer_monday_calories"), forKey: "diet_customer_monday_calories")
                            values.setValue(data_rec.value(forKey: "diet_customer_tuesday_text"), forKey: "diet_customer_tuesday_text")
                            values.setValue(data_rec.value(forKey: "diet_customer_tuesday_calories"), forKey: "diet_customer_tuesday_calories")
                            values.setValue(data_rec.value(forKey: "diet_customer_wednesday_text"), forKey: "diet_customer_wednesday_text")
                            values.setValue(data_rec.value(forKey: "diet_customer_wednesday_calories"), forKey: "diet_customer_wednesday_calories")
                            values.setValue(data_rec.value(forKey: "diet_customer_thirsday_text"), forKey: "diet_customer_thirsday_text")
                            values.setValue(data_rec.value(forKey: "diet_customer_thirsday_calories"), forKey: "diet_customer_thirsday_calories")
                            values.setValue(data_rec.value(forKey: "diet_customer_friday_text"), forKey: "diet_customer_friday_text")
                            values.setValue(data_rec.value(forKey: "diet_customer_friday_calories"), forKey: "diet_customer_friday_calories")
                            values.setValue(data_rec.value(forKey: "diet_customer_saturday_text"), forKey: "diet_customer_saturday_text")
                            values.setValue(data_rec.value(forKey: "diet_customer_saturday_calories"), forKey: "diet_customer_saturday_calories")
                            values.setValue(data_rec.value(forKey: "diet_customer_sunday_text"), forKey: "diet_customer_sunday_text")
                            values.setValue(data_rec.value(forKey: "diet_customer_sunday_calories"), forKey: "diet_customer_sunday_calories")
                            values.setValue(data_rec.value(forKey: "diet_customer_note"), forKey: "diet_customer_note")
                            values.setValue(data_rec.value(forKey: "diet_customer_target"), forKey: "diet_customer_target")
                            values.setValue(data_rec.value(forKey: "diet_customer_supplements"), forKey: "diet_customer_supplements")
                            
                            
                            ModelManager.getInstance().insert("diet_customer", valuesDictionary: values)
                        }
                        
                        DietTableViewController.readData = true
                        MeasuresViewController.readData = true
                        
                        let alertController = UIAlertController(title: NSLocalizedString("SUCCESS",comment: "Attention"), message:NSLocalizedString("SUCCESSSYNCH", comment: "SUCCESSSYNCH"), preferredStyle: .alert)
                        
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                            
                        }
                        alertController.addAction(OKAction)
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                            ANLoader.hide()
                            
                            if self.window!.rootViewController as? UITabBarController != nil {
                                let tababarController = self.window!.rootViewController as? UITabBarController
                                
                                tababarController?.selectedIndex = 3
                                let hc = tababarController?.viewControllers?[3] as? UINavigationController
                                
                                let viewController: InformationViewController = hc?.viewControllers.first as! InformationViewController
                                
                                //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                //let viewController: InformationViewController = storyboard.instantiateViewController(withIdentifier: "InformationViewController") as! InformationViewController
                                
                                if (type == "news"){
                                    viewController.show_news = true
                                    viewController.showNews()
                                }else{
                                    viewController.show_questionnaire = true
                                    viewController.showQuestionnaire()
                                }
                                
                                //hc?.pushViewController(viewController, animated: true)
                            }
                            
                        }
                    }
                }
            } catch let error {
                ANLoader.hide()
                
                Swift.debugPrint("Got an error creating the request: \(error)")
                
                let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    
                }
                alertController.addAction(OKAction)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
            
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
        let aps = userInfo["aps"] as! [AnyHashable : Any]
        
        debugPrint(userInfo["type"])
        debugPrint(aps["alert"])
        
        if (identifier == "SHOW"){
            if self.window!.rootViewController as? UITabBarController != nil {
                let tababarController = self.window!.rootViewController as? UITabBarController
                
                tababarController?.selectedIndex = 1
                let hc = tababarController?.viewControllers?[1] as? UINavigationController
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                //let viewController: OrderRequestDetails = storyboard.instantiateViewController(withIdentifier: "OrderRequestDetails") as! OrderRequestDetails
                
                //viewController.order_or_request = userInfo["table"] as! String
                //viewController.no = Int(userInfo["no"] as! String)
                
                //hc?.pushViewController(viewController, animated: true)
            }
        }
        
        completionHandler()
        
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenParts.joined()
        
        let deviceToken = defaults.string(forKey: Constants.KEY_DEVICE_TOKEN)
        
        if (deviceToken != deviceTokenString){
            defaults.setValue(false, forKey: "launchedBefore")
        }

        GlobalVar.deviceTokenString=deviceTokenString
        
        defaults.setValue(deviceTokenString, forKey: Constants.KEY_DEVICE_TOKEN)
        
        print("Device Token: \(deviceTokenString)")
    }
        
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }


}
