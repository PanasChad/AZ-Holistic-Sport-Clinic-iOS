//
//  SettingsViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 08/02/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import Foundation
import UIKit
import SwiftHTTP
import ScrollableGraphView
import DropDown
import ANLoader
import UserNotifications

class SettingsViewController: UITableViewController {
    @IBOutlet weak var btnLanguage: CustomButton!
    
    @IBOutlet weak var lblTrainer: CustomLabel!
    @IBOutlet weak var lblCode: CustomLabel!
    @IBOutlet weak var lblLastSynch: CustomBlueLabel!
    
    @IBOutlet weak var btnNotification: UISwitch!
    
    let dropDown = DropDown()
    let defaults = UserDefaults.standard
    
    @objc private func changeLang(_ sender: UIButton?) {
        dropDown.show()
    }
    
    @objc func switchThemeChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        themeProvider.nextTheme()
        
        // Do something
        if (value){
            
        }else{
            
        }
        
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        if !Reachability.isConnectedToNetwork(){
            mySwitch.setOn(!mySwitch.isOn, animated: true)
            
            return;
        }
        
        ANLoader.showLoading("Loading", disableUI: true)
        
        let value = mySwitch.isOn
        let token = defaults.value(forKey: Constants.KEY_DEVICE_TOKEN)
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] =  GlobalVar.devicePassword as AnyObject
        
        parameters_arr["device_type"] = "1" as AnyObject?
        parameters_arr["device_os"] = UIDevice.current.systemVersion as AnyObject?
        parameters_arr["device_mobile"] = UIDevice.current.name as AnyObject?
        parameters_arr["device_id"] = GlobalVar.deviceID as AnyObject?
        parameters_arr["device_lang"] = GlobalVar.deviceLang as AnyObject?
        
        parameters_arr["notification_token"] = token as AnyObject?
        parameters_arr["notification"] = "true" as AnyObject?
        
        // Do something
        if (value){
            parameters_arr["notification"] = "false" as AnyObject?
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                    [weak self] granted, error in
                    
                    print("Permission granted: \(granted)")
                    
                    guard granted else { return }
            }
        }
        
        do{
            HTTP.POST(GlobalVar.URL+"set_device.php", parameters:parameters_arr) { response in
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
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    return //also notify app of failure as needed
                }
                
                DispatchQueue.main.async {
                    
                    let alertController = UIAlertController(title: NSLocalizedString("SUCCESS",comment: "Attention"), message:NSLocalizedString("SUCCESSNOTIFICATION", comment: "SUCCESSNOTIFICATION"), preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        
                    }
                    alertController.addAction(OKAction)
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        ANLoader.hide()
                        
                        self.present(alertController, animated: true, completion: nil)
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
            
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.present(alertController, animated: true, completion: nil)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    public func addNewsReadColumnIfNeeded() {
        let result = ModelManager.getInstance().q("PRAGMA table_info(news)")

        var columnExists = false
        for row in result {
            if let dict = row as? NSDictionary,
               let name = dict["name"] as? String,
               name.lowercased() == "news_read" {
                columnExists = true
                break
            }
        }

        if !columnExists {
            ModelManager.getInstance().q("ALTER TABLE news ADD COLUMN news_read INTEGER DEFAULT 0")
        }
    }

    @IBAction func synch_now(){
        ANLoader.showLoading("Loading", disableUI: true)
        
        if !Reachability.isConnectedToNetwork(){
            ANLoader.hide()
            
            return;
        }
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject
        
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
                        self.present(alertController, animated: true, completion: nil)
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
                    
                    self.lblLastSynch.text = dateFormatterPrint.string(from: date)
                    
                    self.defaults.set(json_response.value(forKey: "parking_number") as! String, forKey: "parking")
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    values.setValue(json_response.value(forKey: "customer_fullname"), forKey: "customer_fullname")
                    values.setValue(json_response.value(forKey: "customer_end_of_subscription"), forKey: "customer_end_of_subscription")
                    values.setValue(json_response.value(forKey: "customer_remaining_amount"), forKey: "customer_remaining_amount")
                    values.setValue(json_response.value(forKey: "customer_next_appointment"), forKey: "customer_next_appointment")
                    values.setValue(json_response.value(forKey: "customer_questionnaire_exists"), forKey: "customer_questionnaire_exists")
                    values.setValue(json_response.value(forKey: "customer_questionnaire_already_answer"), forKey: "customer_questionnaire_already_answer")
                    
                    ModelManager.getInstance().updateAll("customer", valuesDictionary: values)
                    
                    //Add trainer name
                    ModelManager.getInstance().deleteAll("others")
                    
                    values.removeAllObjects()
                    
                    values.setValue("trainer_fullname" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "trainer_fullname"), forKey: "others_value")
                    
                    
                    ModelManager.getInstance().insert("others", valuesDictionary: values)
                    
                    //trainer_working_hours
                    values.removeAllObjects()
                    
                    values.setValue("trainer_working_hours" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "trainer_working_hours"), forKey: "others_value")
                    
                    
                    ModelManager.getInstance().insert("others", valuesDictionary: values)
                    
                    //exercise_guide
                    values.removeAllObjects()
                    
                    values.setValue("exercise_guide" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "exercise_guide"), forKey: "others_value")
                    
                    
                    let insert = ModelManager.getInstance().insert("others", valuesDictionary: values)
                    
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
                    
                    
                    self.addNewsReadColumnIfNeeded()

                    let readNews = ModelManager.getInstance().q("SELECT news_id FROM news WHERE news_read = 1")
                    var readIds: [String] = []
                    for row in readNews {
                        if let dict = row as? NSDictionary, let anyId = dict["news_id"] {
                            if let s = anyId as? String {
                                readIds.append(s)
                            } else if let n = anyId as? NSNumber {
                                readIds.append(n.stringValue)
                            } else if let i = anyId as? Int {
                                readIds.append(String(i))
                            }
                        }
                    }

                    var data: NSArray = (json_response.value(forKey: "news") as! NSDictionary).value(forKey: "data") as! NSArray
                    ModelManager.getInstance().deleteAll("news")
                    for i in 0 ..< data.count {
                        let values: NSMutableDictionary = NSMutableDictionary()
                        let data_rec: NSDictionary = data[i] as! NSDictionary
                        
                        let newsId = data_rec.value(forKey: "news_id") as! String
                        var isRead = readIds.contains(newsId) ? 1 : 0

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
                        
                        values.setValue(newsId, forKey: "news_id")
                        values.setValue(data_rec.value(forKey: "news_title_en"), forKey: "news_title_en")
                        values.setValue(data_rec.value(forKey: "news_title_el"), forKey: "news_title_el")
                        values.setValue(data_rec.value(forKey: "news_text_en"), forKey: "news_text_en")
                        values.setValue(data_rec.value(forKey: "news_text_el"), forKey: "news_text_el")
                        values.setValue(data_rec.value(forKey: "news_date"), forKey: "news_date")
                        values.setValue(isRead, forKey: "news_read")

                        ModelManager.getInstance().insert("news", valuesDictionary: values)
                    }

                    ModelManager.getInstance().q("UPDATE news SET news_read = 1 WHERE date(news_date) <= date('now','-30 day')")

                    
                    //Membership Privilages
                   ModelManager.getInstance().deleteAll("membership_privileges")
                   
                   //Getting the JSON array teams from the response
                   data = (json_response.value(forKey: "membership_privileges")as! NSDictionary).value(forKey: "data") as! NSArray
                   
                   //looping through all the json objects in the array teams
                   for i in 0 ..< data.count{
                       let values : NSMutableDictionary = NSMutableDictionary()
                       let data_rec : NSDictionary = data[i] as! NSDictionary
                       
                       values.setValue(data_rec.value(forKey: "membership_privileges_id"), forKey: "membership_privileges_id")
                       values.setValue(data_rec.value(forKey: "membership_privileges_company_name"), forKey: "membership_privileges_company_name")
                       values.setValue(data_rec.value(forKey: "membership_privileges_image_path"), forKey: "membership_privileges_image_path")
                       values.setValue(data_rec.value(forKey: "membership_privileges_text_el"), forKey: "membership_privileges_text_el")
                       values.setValue(data_rec.value(forKey: "membership_privileges_text_en"), forKey: "membership_privileges_text_en")
                       
                       ModelManager.getInstance().insert("membership_privileges", valuesDictionary: values)
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
                    
                    //evaluation
                    ModelManager.getInstance().deleteAll("customer_lipometry_evaluation")
                    //Getting the JSON array teams from the response
                    let data_rec: NSDictionary = json_response.value(forKey: "evaluation") as? NSDictionary ?? NSDictionary()
                    
                    if (data_rec.object(forKey: "evaluation_date") != nil){
                        let values : NSMutableDictionary = NSMutableDictionary()
                    
                        values.setValue(data_rec.value(forKey: "evaluation_date"), forKey: "customer_lipometry_evaluation_date")
                        values.setValue(data_rec.value(forKey: "evaluation_question_1"), forKey: "customer_lipometry_evaluation_q1")
                        values.setValue(data_rec.value(forKey: "evaluation_question_2"), forKey: "customer_lipometry_evaluation_q2")
                        values.setValue(data_rec.value(forKey: "evaluation_question_3"), forKey: "customer_lipometry_evaluation_q3")
                        values.setValue(data_rec.value(forKey: "evaluation_question_4"), forKey: "customer_lipometry_evaluation_q4")
                        values.setValue(data_rec.value(forKey: "evaluation_question_5"), forKey: "customer_lipometry_evaluation_q5")
                        values.setValue(data_rec.value(forKey: "evaluation_question_6"), forKey: "customer_lipometry_evaluation_q6")
                        values.setValue(data_rec.value(forKey: "evaluation_question_7"), forKey: "customer_lipometry_evaluation_q7")
                        values.setValue(data_rec.value(forKey: "evaluation_question_8"), forKey: "customer_lipometry_evaluation_q8")
                    
                        ModelManager.getInstance().insert("customer_lipometry_evaluation", valuesDictionary: values)
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
                        
                        self.present(alertController, animated: true, completion: nil)
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
            
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.present(alertController, animated: true, completion: nil)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    @objc func logout(){
        // iOS8 and later
        let alert = UIAlertController(title: NSLocalizedString("CONFIRMATION", comment: "CONFIRMATION"), message: NSLocalizedString("LOGOUTCONFIRM", comment: "LOGOUTCONFIRM"),preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("YES", comment: "Yes"), style: .default, handler: {action in
            
            UserDefaults.standard.setValue(false, forKey: "launchedBefore")
            
            let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
            
            UIApplication.shared.unregisterForRemoteNotifications()
            
            Util.deleteFile("az.sqlite")
            ModelManager.reset()
            
            UIApplication.shared.keyWindow?.rootViewController = Login
        }))
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("NO", comment: "No"), style: .default, handler: {action in
            
        }))
        
        self.present(alert, animated:true, completion:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (GlobalVar.deviceLang == "el"){
            btnLanguage.setTitle("Ελληνικά", for: .normal)
            dropDown.selectRow(at: 1)
        }else{
            btnLanguage.setTitle("English", for: .normal)
            dropDown.selectRow(at: 0)
        }
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                self.themeProvider.currentTheme = .dark
            }else{
                self.themeProvider.currentTheme = .light
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTheming()
        
        let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM customer")
        let date_synch: String! = defaults.value(forKey: "synch_date") as! String
        let trainer:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM others WHERE others_field='trainer_fullname'")
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy, HH:mm"
        
        let date = dateFormatterGet.date(from:date_synch)
        
        btnNotification.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        lblLastSynch.text = dateFormatterPrint.string(from: date!)
        lblTrainer.text = trainer.value(forKey: "others_value") as? String
        
        ANLoader.pulseAnimation = true //It will animate your Loading
        ANLoader.activityColor = .white
        ANLoader.activityBackgroundColor = .clear
        ANLoader.activityTextColor = .clear
        ANLoader.viewBackgroundDark = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("LOGOUT",comment:"LOGOUT"), style: .plain, target: self, action: #selector(logout))
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor().convertHexStringToColor(GlobalVar.redColor)

        lblCode.text = values.value(forKey: "customer_code") as? String
        
        // The view to which the drop down will appear on
        dropDown.anchorView = btnLanguage // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["English", "Ελληνικά"]
        
        dropDown.direction = .any
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnLanguage.setTitle(item, for: .normal)
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            
            if (index == 0){
                UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                GlobalVar.deviceLang = "en"
                
                // Update the language by swaping bundle
                Bundle.setLanguage("en")
                
            }else{
                UserDefaults.standard.set(["el"], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                GlobalVar.deviceLang = "el"
                
                // Update the language by swaping bundle
                Bundle.setLanguage("el")
                
            }
            
            // Done to reintantiate the storyboards instantly
            //let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            //UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
            DietTableViewController.readData = true
            MeasuresViewController.readData = true
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        }
        
        btnLanguage.addTarget(self, action: #selector(changeLang(_:)), for: .touchUpInside)
        
        if (GlobalVar.deviceLang == "el"){
            btnLanguage.setTitle("Ελληνικά", for: .normal)
            dropDown.selectRow(at: 1)
        }else{
            btnLanguage.setTitle("English", for: .normal)
            dropDown.selectRow(at: 0)
        }
        
        dropDown.reloadAllComponents()
    }
    
    func restartApplication () {
        let viewController = LoginViewController()
        let navCtrl = UINavigationController(rootViewController: viewController)
        
        guard
            let window = UIApplication.shared.keyWindow,
            let rootViewController = window.rootViewController
            else {
                return
        }
        
        navCtrl.view.frame = rootViewController.view.frame
        navCtrl.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navCtrl
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }

}

extension SettingsViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        btnLanguage.setTitleColor(theme.textColor, for: .normal)
        
        navigationItem.rightBarButtonItem?.tintColor = theme.buttonRedColor
    }
}
