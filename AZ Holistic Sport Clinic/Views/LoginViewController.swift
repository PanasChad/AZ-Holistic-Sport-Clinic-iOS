//
//  LoginViewController.swift
//  Kapodistrias Tool
//
//  Created by Μανώλης Γεωργίου on 01/08/16.
//  Copyright © 2016 Μανώλης Γεωργίου. All rights reserved.
//

import UIKit
import SwiftHTTP

class  LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblPassowrd: UILabel!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var lblUrl1: UILabel!
    
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                self.imgLogo.image = UIImage(named: "a2z-logo")
            } else {
                self.imgLogo.image = UIImage(named: "logo")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor().convertHexStringToColor(GlobalVar.blueColor)]
        btnSubmit.layer.cornerRadius = 5
        
        setUpTheming()
        
        txtUsername.delegate = self
        txtPassword.delegate = self

        txtPassword.returnKeyType = .go
        txtPassword.enablesReturnKeyAutomatically = true

        // Apply custom styling
        setTextFieldStyle(txtUsername)
        setTextFieldStyle(txtPassword)

        // Add eye icon for password visibility toggle
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        let padding: CGFloat = 8
        eyeButton.frame = CGRect(x: 0, y: 0, width: 36 + padding, height: 30)
        eyeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: padding)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        txtPassword.rightView = eyeButton
        txtPassword.rightViewMode = .always

        // Pressing enter on password field triggers login
        txtPassword.addTarget(self, action: #selector(pressEnterToLogin(_:)), for: .editingDidEndOnExit)
        
        let tap_1 = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.open_url))
        
        lblUrl1.isUserInteractionEnabled = true
        lblUrl1.addGestureRecognizer(tap_1)
        
    }
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUsername {
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            textField.resignFirstResponder()
            check_login(btnSubmit)
        }
        return true
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func open_url(_ sender:UITapGestureRecognizer)
    {
        if let url = URL(string: "https://andreaszachariou.com") {
            UIApplication.shared.open(url, options: [:]) { (Bool) in
                
            }
        }
    }
    
    @IBAction func check_login(_ sender: UIButton){
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        sender.setTitle("", for: .normal)
        sender.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: sender.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
        ])
        spinner.startAnimating()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Capture and validate inputs up front
        let username = (txtUsername.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (txtPassword.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        print("PASSWORD: " + password)
        guard !username.isEmpty, !password.isEmpty else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.async {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                sender.setTitle(NSLocalizedString("LOGIN", comment: "Submit button title"), for: .normal)
                sender.alpha = 1.0
            }
            return
        }
        
        // Assign globals immediately to ensure consistency across the app
        GlobalVar.deviceUsername = username
        GlobalVar.devicePassword = password
        
        var parameters_arr: [String:AnyObject] = [:]
        parameters_arr["username"] =  username as AnyObject
        parameters_arr["password"] = password as AnyObject
        
        self.btnSubmit.isEnabled = false
        self.txtUsername.isEnabled = false
        self.txtPassword.isEnabled = false
        
        do{
            HTTP.POST(GlobalVar.URL+"login.php", parameters:parameters_arr) { response in
                //do things...
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                
                if let err = response.error {
                    Swift.debugPrint("Error: \(err.localizedDescription)")
                    
                    let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        
                    }
                    alertController.addAction(OKAction)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        self.btnSubmit.isEnabled = true
                        self.txtUsername.isEnabled = true
                        self.txtPassword.isEnabled = true
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    DispatchQueue.main.async {
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                        sender.setTitle(NSLocalizedString("LOGIN", comment: "Submit button title"), for: .normal)
                        sender.alpha = 1.0
                    }
                    return //also notify app of failure as needed
                }
                
                Util.copyFile("az.sqlite")
                
                DispatchQueue.main.async {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                    appDelegate.registerForPushNotifications(UIApplication.shared.self)
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "true"){
                    let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        
                    }
                    alertController.addAction(OKAction)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        self.btnSubmit.isEnabled = true
                        self.txtUsername.isEnabled = true
                        self.txtPassword.isEnabled = true
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    DispatchQueue.main.async {
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                        sender.setTitle(NSLocalizedString("LOGIN", comment: "Submit button title"), for: .normal)
                        sender.alpha = 1.0
                    }
                    return //also notify app of failure as needed
                }
                
                Swift.debugPrint("Customer ID: \(json_response.value(forKey: "my_customer_id"))")
                Swift.debugPrint("Customer KEY: \(json_response.value(forKey: "my_customer_key"))")
                
                let values : NSMutableDictionary = NSMutableDictionary()
                
                DispatchQueue.main.async {
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                    
                    //Get Date
                    let today = formatter.string(from: date)
                    
                    self.defaults.set(today, forKey: "synch_date")
                    
                    var update_db = "CREATE TABLE IF NOT EXISTS \"membership_privileges\" ( \"membership_privileges_id\" integer NOT NULL, \"membership_privileges_company_name\" text, \"membership_privileges_image_path\" text, \"membership_privileges_text_el\" text, \"membership_privileges_text_en\" text, PRIMARY KEY (\"membership_privileges_id\"));"
                    
                    ModelManager.getInstance().q(update_db)
                    
                    update_db = "CREATE TABLE IF NOT EXISTS \"main\".\"text\" (" +
                        "  \"texts_id\" INTEGER NOT NULL," +
                        "  \"texts_title\" TEXT NOT NULL," +
                        "  \"texts_text_en\" TEXT NOT NULL," +
                        "  \"texts_text_el\" TEXT NOT NULL," +
                        "  \"texts_modified_date\" DATE NOT NULL," +
                        "  PRIMARY KEY (\"texts_id\")" +
                        ");";
                    
                    ModelManager.getInstance().q(update_db)
                    
                    update_db = "CREATE TABLE IF NOT EXISTS \"main\".\"customer_lipometry_evaluation\" ( " +
                    " \"customer_lipometry_evaluation_date\" DATE," +
                    " \"customer_lipometry_evaluation_q1\" TEXT," +
                    " \"customer_lipometry_evaluation_q2\" TEXT," +
                    " \"customer_lipometry_evaluation_q3\" TEXT," +
                    " \"customer_lipometry_evaluation_q4\" TEXT," +
                    " \"customer_lipometry_evaluation_q5\" TEXT," +
                    " \"customer_lipometry_evaluation_q6\" TEXT," +
                    " \"customer_lipometry_evaluation_q7\" TEXT," +
                    " \"customer_lipometry_evaluation_q8\" TEXT);";
                    
                    ModelManager.getInstance().q(update_db)
                    
                    update_db = "CREATE TABLE IF NOT EXISTS \"main\".\"others\" (\"others_field\" TEXT NOT NULL,\"others_value\" TEXT, PRIMARY KEY (\"others_field\"));"
                    
                    ModelManager.getInstance().q(update_db)
                    
                    values.setValue(json_response.value(forKey: "customer_id"), forKey: "customer_id")
                    values.setValue(username, forKey: "customer_code")
                    values.setValue(password, forKey: "customer_password")
                    print("SAVING PASSWORD: " + (password))
                    print("SAVING username: " + (username))
                    print("SAVING usernamee: " + (values.value(forKey: "customer_code") as? String ?? "nil"))
                    values.setValue(json_response.value(forKey: "customer_fullname"), forKey: "customer_fullname")
                    values.setValue(json_response.value(forKey: "customer_end_of_subscription"), forKey: "customer_end_of_subscription")
                    values.setValue(json_response.value(forKey: "customer_remaining_amount"), forKey: "customer_remaining_amount")
                    values.setValue(json_response.value(forKey: "customer_next_appointment"), forKey: "customer_next_appointment")
                    values.setValue("---", forKey: "customer_mobile_token")
                    values.setValue("en", forKey: "customer_language")
                    values.setValue("true", forKey: "customer_notifications")
                    
                    values.setValue(json_response.value(forKey: "customer_questionnaire_exists"), forKey: "customer_questionnaire_exists")
                    values.setValue(json_response.value(forKey: "customer_questionnaire_already_answer"), forKey: "customer_questionnaire_already_answer")
                    //values.setValue(json_response.value(forKey: "customer_id"), forKey: "customer_language")
                    //values.setValue(json_response.value(forKey: "customer_id"), forKey: "customer_notifications")
                    
                    ModelManager.getInstance().deleteAll("customer")
                    ModelManager.getInstance().insert("customer", valuesDictionary: values)
                    
                    
                   
                    
                    
                    //Lipometry
                    ModelManager.getInstance().deleteAll("customer_lipometry")
                    //Getting the JSON array teams from the response
                    var data: NSArray = (json_response.value(forKey: "measures")as! NSDictionary).value(forKey: "data") as! NSArray
                    
                    //looping through all the json objects in the array teams
                    for i in 0 ..< data.count{
                        let values : NSMutableDictionary = NSMutableDictionary()
                        let data_rec : NSDictionary = data[i] as! NSDictionary
                        
                        values.setValue(data_rec.value(forKey: "customer_lipometry_id"), forKey: "customer_lipometry_id")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_datetime"), forKey: "customer_lipometry_datetime")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_baros"), forKey: "customer_lipometry_baros")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_lipos"), forKey: "customer_lipometry_lipos")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_lipodis_maza"), forKey: "customer_lipometry_lipodis_maza")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_myiki_maza"), forKey: "customer_lipometry_myiki_maza")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_bmi"), forKey: "customer_lipometry_bmi")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_metabolic_age"), forKey: "customer_lipometry_metabolic_age")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_bmr"), forKey: "customer_lipometry_bmr")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_ipsos"), forKey: "customer_lipometry_ipsos")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_splaxniko_lipos"), forKey: "customer_lipometry_splaxniko_lipos")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_tbw"), forKey: "customer_lipometry_tbw")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_full"), forKey: "customer_lipometry_full")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_waist_size"), forKey: "customer_lipometry_waist_size")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_buttocks_size"), forKey: "customer_lipometry_buttocks_size")
                        values.setValue(data_rec.value(forKey: "customer_lipometry_perimetros_laimou"), forKey: "customer_lipometry_perimetros_laimou")
                        
                        
                        ModelManager.getInstance().insert("customer_lipometry", valuesDictionary: values)
                        
                    }
                    
                    
                    //Weeks
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
                    
                    //News
                    ModelManager.getInstance().deleteAll("news")
                    
                    //Getting the JSON array teams from the response
                    data = (json_response.value(forKey: "news")as! NSDictionary).value(forKey: "data") as! NSArray
                    
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
                    
                    //evaluation
                    ModelManager.getInstance().deleteAll("customer_lipometry_evaluation")
                    //Getting the JSON array teams from the response
                    
                    
                        let data_rec: NSDictionary = json_response.value(forKey: "evaluation") as? NSDictionary ?? NSDictionary()
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    
                    if (data_rec.object(forKey: "evaluation_date") != nil){
                    
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
                    
                    //Add trainer name
                    ModelManager.getInstance().deleteAll("others")
                    
                    values.removeAllObjects()
                    
                    values.setValue("trainer_fullname" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "trainer_fullname"), forKey: "others_value")
                    
                    
                    ModelManager.getInstance().insert("others", valuesDictionary: values)
                    
                    
                    //Add Trainer Time
                    values.removeAllObjects()
                    
                    values.setValue("trainer_working_hours" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "trainer_working_hours"), forKey: "others_value")
                    
                    
                    ModelManager.getInstance().insert("others", valuesDictionary: values)
                    
                    //Add exercise_guide
                    values.removeAllObjects()
                    
                    values.setValue("exercise_guide" , forKey: "others_field")
                    values.setValue(json_response.value(forKey: "exercise_guide"), forKey: "others_value")
                    
                    
                    let insert = ModelManager.getInstance().insert("others", valuesDictionary: values)
                    

                    GlobalVar.deviceID = json_response.value(forKey: "customer_id")as! String
                    // Keep using the captured username/password instead of reading text fields again
                    GlobalVar.deviceUsername = username
                    GlobalVar.devicePassword = password
                    print("GLOBAL USERNAME HAHAH" + (GlobalVar.deviceUsername ?? "nil"))
                    print("GLOBAL PASSWORD HAHAH" + (GlobalVar.devicePassword ?? "nil"))
                    
                    self.defaults.set(json_response.value(forKey: "parking_number") as! String, forKey: "parking")
                    
                    //GlobalVar.deviceTokenString = json_response.value(forKey: "my_customer_key") as! String
                    GlobalVar.deviceLang = NSLocale.current.languageCode
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                    self.btnSubmit.isEnabled = true
                    self.txtUsername.isEnabled = true
                    self.txtPassword.isEnabled = true
                    
                    DispatchQueue.main.async {
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()
                        sender.setTitle(NSLocalizedString("LOGIN", comment: "Submit button title"), for: .normal)
                    }
                    UIApplication.shared.keyWindow?.rootViewController = mainViewController
                    
                }
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
            }
            alertController.addAction(OKAction)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.btnSubmit.isEnabled = true
                self.txtUsername.isEnabled = true
                self.txtPassword.isEnabled = true
                
                self.present(alertController, animated: true, completion: nil)
            }
            DispatchQueue.main.async {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                sender.setTitle(NSLocalizedString("LOGIN", comment: "Submit button title"), for: .normal)
                sender.alpha = 1.0
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setTextFieldStyle(_ textField: UITextField) {
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.masksToBounds = true
        textField.setLeftPaddingPoints(10)
    }

    @objc func togglePasswordVisibility() {
        txtPassword.isSecureTextEntry.toggle()
        if let button = txtPassword.rightView as? UIButton {
            let imageName = txtPassword.isSecureTextEntry ? "eye.slash" : "eye"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    @objc func pressEnterToLogin(_ sender: UITextField) {
        check_login(btnSubmit)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.cgColor
    }
}

extension LoginViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        
        lblUsername.textColor = theme.textColor
        lblPassowrd.textColor = theme.textColor
        
        txtUsername.textColor = theme.textColor
        lblPassowrd.textColor = theme.textColor
        
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
