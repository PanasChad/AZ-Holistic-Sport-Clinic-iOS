//
//  Main.swift
//  Kapodistrias Tool
//
//  Created by Μανώλης Γεωργίου on 03/08/16.
//  Copyright © 2016 Μανώλης Γεωργίου. All rights reserved.
//

import UIKit
import SwiftHTTP

class MainViewController: UITabBarController {
    
    func viewDidLoadHello() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBar.tintColor = UIColor().convertHexStringToColor(GlobalVar.redColor)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM user")
        
        
        GlobalVar.devicePassword = values.value(forKey: "user_password") as! String
        
        GlobalVar.deviceTokenString = UserDefaults.standard.string(forKey: Constants.KEY_DEVICE_TOKEN)
        
        GlobalVar.deviceLang = ""
        
        if (launchedBefore == false){
            var parameters_arr: [String:AnyObject] = [:]
            
            /*ALWAYS NEED THEM FOR CHECK*/
            
            parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
            parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject?
            
            parameters_arr["device_type"] = "1" as AnyObject?
            parameters_arr["device_os"] = UIDevice.current.systemVersion as AnyObject?
            parameters_arr["device_mobile"] = UIDevice.current.name as AnyObject?
            
            parameters_arr["notification_token"] = UserDefaults.standard.value(forKey: Constants.KEY_DEVICE_TOKEN) as AnyObject?
            
            let arr: Array = UserDefaults.standard.value(forKey: "AppleLanguages") as! Array<String>
            
            if (String(arr[0]) == "en"){
                parameters_arr["device_lang"] = "en" as AnyObject?
            }else{
                parameters_arr["device_lang"] = "el" as AnyObject?
            }
            
            
            do{
                let opt = try HTTP.POST(GlobalVar.URL+"set_device.php", parameters:parameters_arr){ response in
                    //do things...
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    Swift.debugPrint(response.text)
                    
                    if let err = response.error {
                        Swift.debugPrint("Error: \(err.localizedDescription)")
                        
                        return //also notify app of failure as needed
                    }
                    
                    let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                    
                    let device_id :String = json_response.value(forKey: "result") as! String
                    
                    GlobalVar.deviceID = device_id
                    UserDefaults.standard.setValue(GlobalVar.deviceID, forKey: Constants.KEY_DEVICE_ID)
                    
                    Swift.debugPrint("Result: \(json_response.value(forKey: "result"))")
                    
                }
            } catch let error {
                Swift.debugPrint("Got an error creating the request: \(error)")
                
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }else{
            GlobalVar.deviceID = UserDefaults.standard.value(forKey: Constants.KEY_DEVICE_ID) as! String?
        }
        
        self.read_data_from_server();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Read All Data From Server */
    func read_data_from_server(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
        parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject?
        
        do{
            ModelManager.getInstance().deleteAll("order")
            ModelManager.getInstance().deleteAll("request")
            
            
            let opt = try HTTP.POST(GlobalVar.URL+"get_all.php", parameters:parameters_arr){ response in
                //do things...
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let err = response.error {
                    Swift.debugPrint("Error: \(response.description)")
                    
                    return //also notify app of failure as needed
                }
                
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                
                
                for i in 0 ..< (json_response.value(forKey: "my_order") as! NSArray).count
                {
                    let obj : NSDictionary = ((json_response.value(forKey: "my_order")as! NSArray).object(at: i)) as! NSDictionary
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    values.setValue(obj.value(forKey: "my_user_fullname_en"), forKey: "order_user_en")
                    values.setValue(obj.value(forKey: "my_user_fullname_el"), forKey: "order_user_el")
                    
                    values.setValue(obj.value(forKey: "my_shop_en"), forKey: "order_shop_en")
                    values.setValue(obj.value(forKey: "my_shop_el"), forKey: "order_shop_el")
                    
                    
                    values.setValue(obj.value(forKey: "my_order_id"), forKey: "order_code")
                    values.setValue(obj.value(forKey: "my_order_no"), forKey: "order_no")
                    values.setValue(obj.value(forKey: "my_order_text"), forKey: "order_text")
                    values.setValue(obj.value(forKey: "my_order_note_to_customer"), forKey: "order_note")
                    values.setValue(obj.value(forKey: "my_order_status_type_id"), forKey: "order_status")
                    values.setValue(obj.value(forKey: "my_order_datetime_inserted"), forKey: "order_last_update")
                    
                    ModelManager.getInstance().insert("order", valuesDictionary: values)
                }
                
                
                
                for i in 0 ..< (json_response.value(forKey: "my_request") as! NSArray).count
                {
                    
                    let obj : NSDictionary = ((json_response.value(forKey: "my_request")as! NSArray).object(at: i)) as! NSDictionary
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    values.setValue(obj.value(forKey: "my_user_fullname_en"), forKey: "request_user_en")
                    values.setValue(obj.value(forKey: "my_user_fullname_el"), forKey: "request_user_el")
                    
                    values.setValue(obj.value(forKey: "my_shop_en"), forKey: "request_shop_en")
                    values.setValue(obj.value(forKey: "my_shop_el"), forKey: "request_shop_el")
                    
                    values.setValue(obj.value(forKey: "my_request_id"), forKey: "request_code")
                    values.setValue(obj.value(forKey: "my_request_no"), forKey: "request_no")
                    values.setValue(obj.value(forKey: "my_request_text"), forKey: "request_text")
                    values.setValue(obj.value(forKey: "my_request_answer"), forKey: "request_answer")
                    values.setValue(obj.value(forKey: "my_request_note_to_customer"), forKey: "request_note")
                    values.setValue(obj.value(forKey: "my_request_status_type_id"), forKey: "request_status")
                    values.setValue(obj.value(forKey: "my_request_datetime_inserted"), forKey: "request_last_update")
                    
                    ModelManager.getInstance().insert("request", valuesDictionary: values)
                }
                
                ModelManager.getInstance().deleteAll("faq")
                
                var cnt = json_response.value(forKey: "my_faq") as! NSArray
                
                for i in 0 ..< cnt.count
                {
                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    values.setValue(obj.value(forKey: "my_faq_id"), forKey: "faq_id")
                    values.setValue(obj.value(forKey: "my_faq_question_en"), forKey: "faq_question_en")
                    values.setValue(obj.value(forKey: "my_faq_answer_en"), forKey: "faq_answer_en")
                    values.setValue(obj.value(forKey: "my_faq_question_el"), forKey: "faq_question_el")
                    values.setValue(obj.value(forKey: "my_faq_answer_el"), forKey: "faq_answer_el")
                    
                    ModelManager.getInstance().insert("faq", valuesDictionary: values)
                }
                
                ModelManager.getInstance().deleteAll("shop")
                
                cnt = json_response.value(forKey: "my_shop") as! NSArray
                
                for i in 0 ..< cnt.count
                {
                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    values.setValue(obj.value(forKey: "my_shop_id"), forKey: "shop_id")
                    values.setValue(obj.value(forKey: "my_shop_code"), forKey: "shop_code")
                    values.setValue(obj.value(forKey: "my_shop_atlantis_code"), forKey: "shop_atlantis_code")
                    values.setValue(obj.value(forKey: "my_shop_name_en"), forKey: "shop_name_en")
                    values.setValue(obj.value(forKey: "my_shop_name_el"), forKey: "shop_name_el")
                    values.setValue(obj.value(forKey: "my_shop_category_fk"), forKey: "shop_category_fk")
                    
                    if (obj.value(forKey: "my_shop_user_fk") as! String == ""){
                        values.setValue("0", forKey: "shop_user_fk")
                    }else{
                        values.setValue(obj.value(forKey: "my_shop_user_fk"), forKey: "shop_user_fk")
                    }
                    
                    values.setValue(obj.value(forKey: "my_shop_available_choose"), forKey: "shop_choose")
                    
                    ModelManager.getInstance().insert("shop", valuesDictionary: values)
                }
                
                ModelManager.getInstance().deleteAll("shop_user")
                
                cnt = json_response.value(forKey: "my_shop_user") as! NSArray
                
                for i in 0 ..< cnt.count
                {
                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    values.setValue(obj.value(forKey: "my_user_id"), forKey: "shop_user_id")
                    values.setValue(obj.value(forKey: "my_user_name_en"), forKey: "shop_user_name_en")
                    values.setValue(obj.value(forKey: "my_user_name_el"), forKey: "shop_user_name_el")
                    values.setValue(obj.value(forKey: "my_user_surname_en"), forKey: "shop_user_surname_en")
                    values.setValue(obj.value(forKey: "my_user_surname_el"), forKey: "shop_user_surname_el")
                    values.setValue(obj.value(forKey: "my_user_shop_fk"), forKey: "shop_user_shop_fk")
                    
                    ModelManager.getInstance().insert("shop_user", valuesDictionary: values)
                }
                
                ModelManager.getInstance().deleteAll("profile")
                
                cnt = json_response.value(forKey: "my_profile") as! NSArray
                
                for i in 0 ..< cnt.count
                {
                    let obj : NSDictionary = cnt.object(at: i) as! NSDictionary
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    values.setValue(obj.value(forKey: "my_customer_name"), forKey: "profile_name")
                    values.setValue(obj.value(forKey: "my_customer_lastname"), forKey: "profile_surname")
                    values.setValue(obj.value(forKey: "my_customer_address"), forKey: "profile_address")
                    values.setValue(obj.value(forKey: "my_customer_telephone"), forKey: "profile_telephone")
                    values.setValue(obj.value(forKey: "my_customer_mobile_1"), forKey: "profile_mobile_1")
                    values.setValue(obj.value(forKey: "my_customer_mobile_2"), forKey: "profile_mobile_2")
                    
                    ModelManager.getInstance().insert("profile", valuesDictionary: values)
                }
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    
}
