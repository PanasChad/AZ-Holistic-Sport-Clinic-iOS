//
//  Main.swift
//  AZ
//
//  Created by Μανώλης Γεωργίου on 03/08/16.
//  Copyright © 2016 Μανώλης Γεωργίου. All rights reserved.
//


import UIKit
import SwiftHTTP
import ANLoader

private let DB_QUEUE = DispatchQueue(label: "com.az.sqlite.serial")

class MainViewController: AppTabBarController {
    private var isSyncing = false
    
//    func viewDidLoadHello() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor().convertHexStringToColor(GlobalVar.blueColor)]
//
//        UIApplication.shared.registerForRemoteNotifications()
//
//        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
//
//        let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM user")
//
//        GlobalVar.devicePassword = values.value(forKey: "user_password") as! String
//
//        GlobalVar.deviceTokenString = UserDefaults.standard.string(forKey: Constants.KEY_DEVICE_TOKEN)
//
//        if (launchedBefore == false){
//            var parameters_arr: [String:AnyObject] = [:]
//
//            /*ALWAYS NEED THEM FOR CHECK*/
//
//            parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
//            parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject?
//
//            parameters_arr["device_type"] = "1" as AnyObject?
//            parameters_arr["device_os"] = UIDevice.current.systemVersion as AnyObject?
//            parameters_arr["device_mobile"] = UIDevice.current.name as AnyObject?
//
//            parameters_arr["notification_token"] = UserDefaults.standard.value(forKey: Constants.KEY_DEVICE_TOKEN) as AnyObject?
//
//            let arr: Array = UserDefaults.standard.value(forKey: "AppleLanguages") as! Array<String>
//
//            if (String(arr[0]) == "en"){
//                parameters_arr["device_lang"] = "en" as AnyObject?
//            }else{
//                parameters_arr["device_lang"] = "el" as AnyObject?
//            }
//
//
//            do{
//                let opt = try HTTP.POST(GlobalVar.URL+"set_device.php", parameters:parameters_arr){ response in
//                    //do things...
//
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                    Swift.debugPrint(response.text)
//
//                    if let err = response.error {
//                        Swift.debugPrint("Error: \(err.localizedDescription)")
//
//                        return //also notify app of failure as needed
//                    }
//
//                    let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
//
//                    let device_id :String = json_response.value(forKey: "result") as! String
//
//                    GlobalVar.deviceID = device_id
//                    UserDefaults.standard.setValue(GlobalVar.deviceID, forKey: Constants.KEY_DEVICE_ID)
//
//                    Swift.debugPrint("Result: \(json_response.value(forKey: "result"))")
//
//                }
//            } catch let error {
//                Swift.debugPrint("Got an error creating the request: \(error)")
//
//
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//        }else{
//            GlobalVar.deviceID = UserDefaults.standard.value(forKey: Constants.KEY_DEVICE_ID) as! String?
//        }
//
//        if Reachability.isConnectedToNetwork(){
//            OperationQueue.main.addOperation {
//                self.read_data_from_server();
//            }
//
//            return;
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork(){
            OperationQueue.main.addOperation {
                self.synch_now()
            }
//            if #available(iOS 15.0, *) {
//                let appearance = UITabBarAppearance()
//                appearance.configureWithOpaqueBackground() // removes translucency and gradient
//                appearance.backgroundColor = .black // or any solid color you want
//                appearance.shadowImage = nil
//                appearance.shadowColor = nil
//
//                UITabBar.appearance().standardAppearance = appearance
//                UITabBar.appearance().scrollEdgeAppearance = appearance
//            }
//
//            UITabBar.appearance().isTranslucent = false
            return;
        }
    }
    func synch_now(){
        guard !isSyncing else { return }
        isSyncing = true
        ANLoader.showLoading("Loading", disableUI: true)

        if !Reachability.isConnectedToNetwork(){
            ANLoader.hide()
            isSyncing = false
            return
        }

        var parameters_arr: [String:AnyObject] = [:]
        
        print("GLOBAL USERNAME HAHAHAA" + (GlobalVar.deviceUsername ?? "nil"))
        print("GLOBAL PASSWORD HAHAHAA" + (GlobalVar.devicePassword ?? "nil"))
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject

        do{
            HTTP.POST(GlobalVar.URL+"synch.php", parameters:parameters_arr) { response in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }

                if let err = response.error {
                    DispatchQueue.main.async {
                        ANLoader.hide()
                        Swift.debugPrint("Error: \(err.localizedDescription)")
                        self.isSyncing = false
                        let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { _ in }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }

                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!

                if (json_response.value(forKey: "error") as! String == "true"){
                    DispatchQueue.main.async {
                        ANLoader.hide()
                        self.isSyncing = false
                        let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { _ in }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }

                // Phase 1: Run ALL database operations on a single serial queue (no UI here)
                DB_QUEUE.sync {
                    let values : NSMutableDictionary = NSMutableDictionary()
                    values.setValue(json_response.value(forKey: "customer_fullname"), forKey: "customer_fullname")
                    values.setValue(json_response.value(forKey: "customer_end_of_subscription"), forKey: "customer_end_of_subscription")
                    values.setValue(json_response.value(forKey: "customer_remaining_amount"), forKey: "customer_remaining_amount")
                    values.setValue(json_response.value(forKey: "customer_next_appointment"), forKey: "customer_next_appointment")
                    values.setValue(json_response.value(forKey: "customer_questionnaire_exists"), forKey: "customer_questionnaire_exists")
                    values.setValue(json_response.value(forKey: "customer_questionnaire_already_answer"), forKey: "customer_questionnaire_already_answer")
                    ModelManager.getInstance().updateAll("customer", valuesDictionary: values)

                    // Others
                    ModelManager.getInstance().deleteAll("others")
                    values.removeAllObjects()
                    values.setValue("trainer_fullname" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "trainer_fullname"), forKey: "others_value")
                    ModelManager.getInstance().insert("others", valuesDictionary: values)

                    values.removeAllObjects()
                    values.setValue("trainer_working_hours" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "trainer_working_hours"), forKey: "others_value")
                    ModelManager.getInstance().insert("others", valuesDictionary: values)

                    values.removeAllObjects()
                    values.setValue("exercise_guide" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "exercise_guide"), forKey: "others_value")
                    ModelManager.getInstance().insert("others", valuesDictionary: values)

                    // Week
                    ModelManager.getInstance().deleteAll("week")
                    let values_week : NSMutableDictionary = NSMutableDictionary()
                    values_week.setValue(json_response.value(forKey: "week_name_5") as? String, forKey: "week_name_5")
                    values_week.setValue(json_response.value(forKey: "week_name_4") as? String, forKey: "week_name_4")
                    values_week.setValue(json_response.value(forKey: "week_name_3") as? String, forKey: "week_name_3")
                    values_week.setValue(json_response.value(forKey: "week_name_2") as? String, forKey: "week_name_2")
                    values_week.setValue(json_response.value(forKey: "week_name_1") as? String, forKey: "week_name_1")
                    values_week.setValue(json_response.value(forKey: "week_value_5") as? String, forKey: "week_value_5")
                    values_week.setValue(json_response.value(forKey: "week_value_4") as? String, forKey: "week_value_4")
                    values_week.setValue(json_response.value(forKey: "week_value_3") as? String, forKey: "week_value_3")
                    values_week.setValue(json_response.value(forKey: "week_value_2") as? String, forKey: "week_value_2")
                    values_week.setValue(json_response.value(forKey: "week_value_1") as? String, forKey: "week_value_1")
                    if let latest_checkin = json_response.value(forKey: "latest_checkin") as? String {
                        values_week.setValue(latest_checkin, forKey: "latest_checkin")
                    }
                    ModelManager.getInstance().insert("week", valuesDictionary: values_week)

                    // Questions (clear first)
                    ModelManager.getInstance().deleteAll("question")

                    // Ensure news_read exists
                    self.addNewsReadColumnIfNeeded()

                    // Previously read IDs
                    let readNews = ModelManager.getInstance().q("SELECT news_id FROM news WHERE news_read = 1")
                    var readIds: [String] = []
                    for row in readNews {
                        if let dict = row as? NSDictionary, let anyId = dict["news_id"] {
                            if let s = anyId as? String { readIds.append(s) }
                            else if let n = anyId as? NSNumber { readIds.append(n.stringValue) }
                            else if let i = anyId as? Int { readIds.append(String(i)) }
                        }
                    }

                    // News
                    var data: NSArray = (json_response.value(forKey: "news") as! NSDictionary).value(forKey: "data") as! NSArray
                    ModelManager.getInstance().deleteAll("news")
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd"
                    let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                    for i in 0 ..< data.count {
                        let values: NSMutableDictionary = NSMutableDictionary()
                        let data_rec: NSDictionary = data[i] as! NSDictionary
                        let newsId = data_rec.value(forKey: "news_id") as! String
                        var isRead = readIds.contains(newsId) ? 1 : 0
                        if let rawDateStr = data_rec.value(forKey: "news_date") as? String {
                            let dateStr = String(rawDateStr.prefix(10))
                            if let d = df.date(from: dateStr), d < thirtyDaysAgo { isRead = 1 }
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
                    // Bulk safety update for old news
                    ModelManager.getInstance().q("UPDATE news SET news_read = 1 WHERE substr(news_date,1,10) <= date('now','-30 day')")

                    // Membership Privileges
                    ModelManager.getInstance().deleteAll("membership_privileges")
                    data = (json_response.value(forKey: "membership_privileges")as! NSDictionary).value(forKey: "data") as! NSArray
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

                    // Questions
                    data = (json_response.value(forKey: "questions")as! NSDictionary).value(forKey: "data") as! NSArray
                    for i in 0 ..< data.count{
                        let values : NSMutableDictionary = NSMutableDictionary()
                        let data_rec : NSDictionary = data[i] as! NSDictionary
                        values.setValue(data_rec.value(forKey: "question_id"), forKey: "question_id")
                        values.setValue(data_rec.value(forKey: "question_en"), forKey: "question_en")
                        values.setValue(data_rec.value(forKey: "question_el"), forKey: "question_el")
                        ModelManager.getInstance().insert("question", valuesDictionary: values)
                    }

                    // Evaluation
                    ModelManager.getInstance().deleteAll("customer_lipometry_evaluation")
                    let data_rec_eval: NSDictionary = json_response.value(forKey: "evaluation") as? NSDictionary ?? NSDictionary()
                    if (data_rec_eval.object(forKey: "evaluation_date") != nil){
                        let values : NSMutableDictionary = NSMutableDictionary()
                        values.setValue(data_rec_eval.value(forKey: "evaluation_date"), forKey: "customer_lipometry_evaluation_date")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_1"), forKey: "customer_lipometry_evaluation_q1")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_2"), forKey: "customer_lipometry_evaluation_q2")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_3"), forKey: "customer_lipometry_evaluation_q3")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_4"), forKey: "customer_lipometry_evaluation_q4")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_5"), forKey: "customer_lipometry_evaluation_q5")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_6"), forKey: "customer_lipometry_evaluation_q6")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_7"), forKey: "customer_lipometry_evaluation_q7")
                        values.setValue(data_rec_eval.value(forKey: "evaluation_question_8"), forKey: "customer_lipometry_evaluation_q8")
                        ModelManager.getInstance().insert("customer_lipometry_evaluation", valuesDictionary: values)
                    }

                    // Diet
                    ModelManager.getInstance().deleteAll("diet_customer")
                    data = (json_response.value(forKey: "diet")as! NSDictionary).value(forKey: "data") as! NSArray
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
                }

                // Phase 2: Only UI/state on main
                DispatchQueue.main.async {
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                    let today = formatter.string(from: date)
                    UserDefaults.standard.set(today, forKey: "synch_date")
                    if let pk = json_response.value(forKey: "parking_number") as? String {
                        UserDefaults.standard.set(pk, forKey: "parking")
                    }
                    DietTableViewController.readData = true
                    MeasuresViewController.readData = true
                    ANLoader.hide()
                    self.isSyncing = false
                    // self.present(successAlert, animated: true) // (kept disabled as before)
                }
            }
        } catch let error {
            ANLoader.hide()
            Swift.debugPrint("Got an error creating the request: \(error)")
            let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { _ in }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            isSyncing = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Read All Data From Server */
//    func read_data_from_server(){
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//
//        var parameters_arr: [String:AnyObject] = [:]
//
//        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
//        parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject?
//
//        do{
//            ModelManager.getInstance().deleteAll("order")
//            ModelManager.getInstance().deleteAll("request")
//
//
//            let opt = try HTTP.POST(GlobalVar.URL+"get_all.php", parameters:parameters_arr){ response in
//                //do things...
//
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if let err = response.error {
//                    Swift.debugPrint("Error: \(response.description)")
//
//
//
//                    return //also notify app of failure as needed
//                }
//
//
//                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
//
//
//
//                for i in 0 ..< (json_response.value(forKey: "my_order") as! NSArray).count
//                {
//                    let obj : NSDictionary = ((json_response.value(forKey: "my_order")as! NSArray).object(at: i)) as! NSDictionary
//
//                    let values : NSMutableDictionary = NSMutableDictionary()
//
//                    values.setValue(obj.value(forKey: "my_user_fullname_en"), forKey: "order_user_en")
//                    values.setValue(obj.value(forKey: "my_user_fullname_el"), forKey: "order_user_el")
//
//                    values.setValue(obj.value(forKey: "my_shop_en"), forKey: "order_shop_en")
//                    values.setValue(obj.value(forKey: "my_shop_el"), forKey: "order_shop_el")
//
//
//                    values.setValue(obj.value(forKey: "my_order_id"), forKey: "order_code")
//                    values.setValue(obj.value(forKey: "my_order_no"), forKey: "order_no")
//                    values.setValue(obj.value(forKey: "my_order_text"), forKey: "order_text")
//                    values.setValue(obj.value(forKey: "my_order_note_to_customer"), forKey: "order_note")
//                    values.setValue(obj.value(forKey: "my_order_status_type_id"), forKey: "order_status")
//                    values.setValue(obj.value(forKey: "my_order_datetime_inserted"), forKey: "order_last_update")
//
//                    ModelManager.getInstance().insert("order", valuesDictionary: values)
//                }
//
//
//
//                for i in 0 ..< (json_response.value(forKey: "my_request") as! NSArray).count
//                {
//
//                    let obj : NSDictionary = ((json_response.value(forKey: "my_request")as! NSArray).object(at: i)) as! NSDictionary
//
//                    let values : NSMutableDictionary = NSMutableDictionary()
//
//                    values.setValue(obj.value(forKey: "my_user_fullname_en"), forKey: "request_user_en")
//                    values.setValue(obj.value(forKey: "my_user_fullname_el"), forKey: "request_user_el")
//
//                    values.setValue(obj.value(forKey: "my_shop_en"), forKey: "request_shop_en")
//                    values.setValue(obj.value(forKey: "my_shop_el"), forKey: "request_shop_el")
//
//                    values.setValue(obj.value(forKey: "my_request_id"), forKey: "request_code")
//                    values.setValue(obj.value(forKey: "my_request_no"), forKey: "request_no")
//                    values.setValue(obj.value(forKey: "my_request_text"), forKey: "request_text")
//                    values.setValue(obj.value(forKey: "my_request_answer"), forKey: "request_answer")
//                    values.setValue(obj.value(forKey: "my_request_note_to_customer"), forKey: "request_note")
//                    values.setValue(obj.value(forKey: "my_request_status_type_id"), forKey: "request_status")
//                    values.setValue(obj.value(forKey: "my_request_datetime_inserted"), forKey: "request_last_update")
//
//                    ModelManager.getInstance().insert("request", valuesDictionary: values)
//                }
//
//                ModelManager.getInstance().deleteAll("faq")
//
//                var cnt = json_response.value(forKey: "my_faq") as! NSArray
//
//                for i in 0 ..< cnt.count
//                {
//                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
//
//                    let values : NSMutableDictionary = NSMutableDictionary()
//
//                    values.setValue(obj.value(forKey: "my_faq_id"), forKey: "faq_id")
//                    values.setValue(obj.value(forKey: "my_faq_question_en"), forKey: "faq_question_en")
//                    values.setValue(obj.value(forKey: "my_faq_answer_en"), forKey: "faq_answer_en")
//                    values.setValue(obj.value(forKey: "my_faq_question_el"), forKey: "faq_question_el")
//                    values.setValue(obj.value(forKey: "my_faq_answer_el"), forKey: "faq_answer_el")
//
//                    ModelManager.getInstance().insert("faq", valuesDictionary: values)
//                }
//
//                ModelManager.getInstance().deleteAll("shop")
//
//                cnt = json_response.value(forKey: "my_shop") as! NSArray
//
//                for i in 0 ..< cnt.count
//                {
//                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
//
//                    let values : NSMutableDictionary = NSMutableDictionary()
//
//                    values.setValue(obj.value(forKey: "my_shop_id"), forKey: "shop_id")
//                    values.setValue(obj.value(forKey: "my_shop_code"), forKey: "shop_code")
//                    values.setValue(obj.value(forKey: "my_shop_atlantis_code"), forKey: "shop_atlantis_code")
//                    values.setValue(obj.value(forKey: "my_shop_name_en"), forKey: "shop_name_en")
//                    values.setValue(obj.value(forKey: "my_shop_name_el"), forKey: "shop_name_el")
//                    values.setValue(obj.value(forKey: "my_shop_category_fk"), forKey: "shop_category_fk")
//
//                    if (obj.value(forKey: "my_shop_user_fk") as! String == ""){
//                        values.setValue("0", forKey: "shop_user_fk")
//                    }else{
//                        values.setValue(obj.value(forKey: "my_shop_user_fk"), forKey: "shop_user_fk")
//                    }
//
//                    values.setValue(obj.value(forKey: "my_shop_available_choose"), forKey: "shop_choose")
//
//                    ModelManager.getInstance().insert("shop", valuesDictionary: values)
//                }
//
//                ModelManager.getInstance().deleteAll("shop_user")
//
//                cnt = json_response.value(forKey: "my_shop_user") as! NSArray
//
//                for i in 0 ..< cnt.count
//                {
//                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
//
//                    let values : NSMutableDictionary = NSMutableDictionary()
//
//                    values.setValue(obj.value(forKey: "my_user_id"), forKey: "shop_user_id")
//                    values.setValue(obj.value(forKey: "my_user_name_en"), forKey: "shop_user_name_en")
//                    values.setValue(obj.value(forKey: "my_user_name_el"), forKey: "shop_user_name_el")
//                    values.setValue(obj.value(forKey: "my_user_surname_en"), forKey: "shop_user_surname_en")
//                    values.setValue(obj.value(forKey: "my_user_surname_el"), forKey: "shop_user_surname_el")
//                    values.setValue(obj.value(forKey: "my_user_shop_fk"), forKey: "shop_user_shop_fk")
//
//                    ModelManager.getInstance().insert("shop_user", valuesDictionary: values)
//                }
//
//                ModelManager.getInstance().deleteAll("profile")
//
//                cnt = json_response.value(forKey: "my_profile") as! NSArray
//
//                for i in 0 ..< cnt.count
//                {
//                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
//
//                    let values : NSMutableDictionary = NSMutableDictionary()
//
//                    values.setValue(obj.value(forKey: "my_customer_name"), forKey: "profile_name")
//                    values.setValue(obj.value(forKey: "my_customer_lastname"), forKey: "profile_surname")
//                    values.setValue(obj.value(forKey: "my_customer_address"), forKey: "profile_address")
//                    values.setValue(obj.value(forKey: "my_customer_telephone"), forKey: "profile_telephone")
//                    values.setValue(obj.value(forKey: "my_customer_mobile_1"), forKey: "profile_mobile_1")
//                    values.setValue(obj.value(forKey: "my_customer_mobile_2"), forKey: "profile_mobile_2")
//
//                    ModelManager.getInstance().insert("profile", valuesDictionary: values)
//                }
//            }
//        } catch let error {
//            Swift.debugPrint("Got an error creating the request: \(error)")
//
//
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        }
//    }
    
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
}

