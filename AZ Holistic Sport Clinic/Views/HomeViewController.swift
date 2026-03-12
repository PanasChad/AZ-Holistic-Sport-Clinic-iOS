//
//  HomeViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 11/12/2018.
//  Copyright © 2018 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import RSBarcodes_Swift
import AVFoundation
import ANLoader
import SCLAlertView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var imgBarcode: UIImageView!
    @IBOutlet weak var lblEndSubscription: UILabel!
    var AmountRemains: String!
    @IBOutlet weak var lblNextAppointment: UILabel!
    @IBOutlet weak var lblCustomerName: UILabel!
    
    @IBOutlet weak var lblTrainer: UILabel!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblTrainerWorkingTime: UILabel!
    
    @IBOutlet weak var lblAmountRemainsLabel: UILabel!
    @IBOutlet weak var lblNextAppointmentLabel: UILabel!
    @IBOutlet weak var lblEndSubscriptionLabel: UILabel!
    
    @IBOutlet weak var imgSmallBarcode: CLImageViewPopup!
    @IBOutlet weak var lblMemberCode: UILabel!
    var dotView: UIView!
    var bellButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
        self.read_values_from_server()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            self.themeProvider.currentTheme = (self.traitCollection.userInterfaceStyle == .dark) ? .dark : .light
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "blue_background")
            appearance.titleTextAttributes = [.foregroundColor:  UIColor(named: "blue_background")]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }

        let bellButton = UIButton(type: .custom)
        bellButton.setImage(UIImage(named: "notification"), for: .normal)
        bellButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        bellButton.imageView?.contentMode = .scaleAspectFit
        bellButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        bellButton.heightAnchor.constraint(equalToConstant: 28).isActive = true

        var dotView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        if #available (iOS 26.0,*){
            dotView = UIView(frame: CGRect(x: 20, y: 0, width: 10, height: 10))
        }
        dotView.backgroundColor = .red
        dotView.layer.borderWidth = 1
        dotView.layer.borderColor = UIColor.red.cgColor
        dotView.layer.cornerRadius = 6
        dotView.isHidden = true
        bellButton.addSubview(dotView)
        self.dotView = dotView
        self.bellButton = bellButton

        let barButton = UIBarButtonItem(customView: bellButton)
        navigationItem.rightBarButtonItem = barButton
        
        let unreadResult = ModelManager.getInstance().line("SELECT COUNT(*) AS total FROM news WHERE news_read = 0")
        let totalValue = unreadResult["total"]
        let unreadCount: Int
        if let n = totalValue as? NSNumber { unreadCount = n.intValue }
        else if let s = totalValue as? String, let n = Int(s) { unreadCount = n }
        else { unreadCount = 0 }
        let hasNews = unreadCount > 0
        if hasNews{
            dotView.isHidden = false
            tabBarController?.tabBar.addDot(at: 3)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTheming()
        
        ANLoader.pulseAnimation = true
        ANLoader.activityColor = .white
        ANLoader.activityBackgroundColor = .clear
        ANLoader.activityTextColor = .clear
        ANLoader.viewBackgroundDark = true
        
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor().convertHexStringToColor(GlobalVar.blueColor)]
        
        let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM customer")
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        GlobalVar.deviceLang = NSLocale.current.languageCode
        
        print("username: \(values.value(forKey: "customer_code") ?? "nil")")
        print("usernamebefore: \(GlobalVar.deviceUsername ?? "nil")")
        GlobalVar.deviceID = values.value(forKey: "customer_id") as? String
        GlobalVar.deviceUsername = values.value(forKey: "customer_code") as? String
        GlobalVar.devicePassword = values.value(forKey: "customer_password") as? String
        GlobalVar.deviceTokenString = UserDefaults.standard.string(forKey: Constants.KEY_DEVICE_TOKEN)
        
        if (launchedBefore == false){
            defaults.setValue(true, forKey: "launchedBefore")
            
            var parameters_arr: [String:AnyObject] = [:]
            
            //// dame to provlima
            ///
            print("Device Token String: \(GlobalVar.deviceTokenString ?? "nil")")
            print("username: \(GlobalVar.deviceUsername ?? "nil")")
            print("password: \(GlobalVar.devicePassword ?? "nil")")
            print("password2: \(values.value(forKey: "customer_password") ?? "nil")")
            parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject?
            parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
            parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject?
            parameters_arr["device_type"] = "1" as AnyObject?
            parameters_arr["device_os"] = UIDevice.current.systemVersion as AnyObject?
            parameters_arr["device_mobile"] = UIDevice.current.name as AnyObject?
            parameters_arr["notification_token"] = UserDefaults.standard.value(forKey: Constants.KEY_DEVICE_TOKEN) as AnyObject?
            
            let arr: Array = UserDefaults.standard.value(forKey: "AppleLanguages") as? Array<String> ?? []
            if (arr.first == "en"){
                parameters_arr["device_lang"] = "en" as AnyObject?
                GlobalVar.deviceLang = "en"
            }else{
                parameters_arr["device_lang"] = "el" as AnyObject?
                GlobalVar.deviceLang = "el"
            }
            
            do{
                try HTTP.POST(GlobalVar.URL+"set_device.php", parameters:parameters_arr){ response in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                    
                    // Transport / server error
                    if let err = response.error {
                        Swift.debugPrint("set_device.php error:", err.localizedDescription)
                        return
                    }
                    // Validate status code if present
                    if let code = response.statusCode, !(200...299).contains(code) {
                        Swift.debugPrint("set_device.php status:", code, response.text ?? "")
                        return
                    }
                    // Ensure body
                    guard let body = response.text, let data = body.data(using: .utf8) else {
                        Swift.debugPrint("set_device.php empty/non-utf8 body")
                        return
                    }
                    guard let json_response = Util.nsdataToJSON(data) as? NSDictionary else {
                        Swift.debugPrint("set_device.php invalid JSON body:", body)
                        return
                    }
                    // Accept result as String or Number
                    var device_id: String?
                    if let s = json_response["result"] as? String { device_id = s }
                    else if let n = json_response["result"] as? NSNumber { device_id = n.stringValue }
                    
                    guard let id = device_id, !id.isEmpty else {
                        Swift.debugPrint("set_device.php missing result key:", json_response)
                        return
                    }
                    GlobalVar.deviceID = id
                    UserDefaults.standard.setValue(GlobalVar.deviceID, forKey: Constants.KEY_DEVICE_ID)
                }
            } catch {
                Swift.debugPrint("Got an error creating the request: \(error)")
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }else{
            GlobalVar.deviceID = UserDefaults.standard.value(forKey: Constants.KEY_DEVICE_ID) as? String
        }
    
        self.read_values_from_server()
        checkUnreadNewsAndAnimateIfNeeded()
    }
    
    func checkUnreadNewsAndAnimateIfNeeded() {
        let unreadResult = ModelManager.getInstance().line("SELECT COUNT(*) AS total FROM news WHERE news_read = 0")
        let totalValue = unreadResult["total"]
        let unreadCount: Int
        if let n = totalValue as? NSNumber { unreadCount = n.intValue }
        else if let s = totalValue as? String, let n = Int(s) { unreadCount = n }
        else { unreadCount = 0 }

        if unreadCount > 0 {
            dotView?.isHidden = false
            dotView?.layer.cornerRadius = dotView.frame.width / 2
            animateNotification()
        } else {
            dotView?.isHidden = true
        }
    }

    @objc func notificationTapped() {
        tabBarController?.selectedIndex = 3
    }

    func animateNotification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5,
                           delay: 1.2,
                           options: [.autoreverse, .repeat],
                           animations: {
                self.dotView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.dotView.layer.removeAllAnimations()
                self.dotView.alpha = 1.0
                self.dotView.transform = .identity
            }
        }
    }

    func show_values(){
        guard let values = ModelManager.getInstance().line("SELECT * FROM customer") as NSDictionary?, values.count > 0 else {
            print("❌ No customer record found or query failed")
            return
        }
        let trainer:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM others WHERE others_field='trainer_fullname'")
        let trainer_working_hours:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM others WHERE others_field='trainer_working_hours'")
        
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor().convertHexStringToColor(GlobalVar.blueColor)]
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy HH:mm"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM, HH:mm"
        dateFormatterPrint.locale = Locale(identifier: "en_US")
        
        let dateFormatterSub = DateFormatter()
        dateFormatterSub.dateFormat = "dd MMMM, yyyy"
        dateFormatterSub.locale = Locale(identifier: "en_US")
        
        if (GlobalVar.deviceLang == "el"){
            dateFormatterPrint.locale = Locale(identifier: "el-GR")
            dateFormatterSub.locale = Locale(identifier: "el-GR")
        }
        
        let date_string = (values.value(forKey: "customer_next_appointment") as? String) ?? ""
        let date_string_sub = (values.value(forKey: "customer_end_of_subscription") as? String) ?? ""
        
        let date = dateFormatterGet.date(from:date_string)
        
        dateFormatterGet.dateFormat = "dd/MM/yyyy"
        let date_sub = dateFormatterGet.date(from:date_string_sub)
        
        let currentDate = Date()
        let diffInDays = date_sub != nil ? (Calendar.current.dateComponents([.day], from: currentDate, to: date_sub!).day ?? 0) : 0
        
        if ( diffInDays < 0 ){
            lblEndSubscription.textColor = lblAmountRemainsLabel.textColor
            lblEndSubscriptionLabel.textColor = lblAmountRemainsLabel.textColor
            GlobalVar.expired_sub = true
        }else{
            lblEndSubscription.textColor = .white
            lblEndSubscriptionLabel.textColor = .white
            GlobalVar.expired_sub = false
        }

        lblEndSubscription.isHidden = false
        lblEndSubscriptionLabel.isHidden = false
        lblCustomerName.isHidden = false
        
        lblMemberCode.isHidden = false
        
        if let d = date_sub {
            lblEndSubscription.text = dateFormatterSub.string(from: d)
        } else {
            lblEndSubscription.text = ""
        }
        lblMemberCode.text = values.value(forKey: "customer_code") as? String
        
        AmountRemains = values.value(forKey: "customer_remaining_amount") as? String
        
        if let d = date {
            lblNextAppointment.text = dateFormatterPrint.string(from: d)
            lblNextAppointment.isHidden = false
            lblNextAppointmentLabel.isHidden = false
        }else{
            lblNextAppointment.isHidden = true
            lblNextAppointmentLabel.isHidden = true
        }
        
        GlobalVar.deviceID = values.value(forKey: "customer_id") as? String
        GlobalVar.deviceUsername = values.value(forKey: "customer_code") as? String
        GlobalVar.devicePassword = values.value(forKey: "customer_password") as? String
        
        lblCustomerName.text = (values.value(forKey: "customer_fullname") as? String)?.replacingOccurrences(of: " ", with: "\n")
        lblTrainerName.text = trainer.value(forKey: "others_value") as? String
        lblTrainerWorkingTime.text = trainer_working_hours.value(forKey: "others_value") as? String
        lblTrainer.text = NSLocalizedString("TRAINER",comment: "TRAINER")
        
        if (lblTrainerName.text != ""){
            lblTrainer.isHidden = false
            lblTrainerName.isHidden = false
            lblTrainerWorkingTime.isHidden = false
        }else{
            lblTrainer.isHidden = true
            lblTrainerName.isHidden = true
            lblTrainerWorkingTime.isHidden = true
        }
        
        if (AmountRemains == "€0.00"){
            lblAmountRemainsLabel.isHidden = true
        }else{
            lblAmountRemainsLabel.isHidden = true
        }
        
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.white
        gen.strokeColor = UIColor.black
        
        if let code = values.value(forKey: "customer_code") as? String,
           let image = gen.generateCode(code, machineReadableCodeObjectType: AVMetadataObject.ObjectType.qr.rawValue) {
            
            self.imgSmallBarcode.layer.borderWidth = 0
            self.imgSmallBarcode.image = RSAbstractCodeGenerator.resizeImage(image, targetSize: imgSmallBarcode.bounds.size, contentMode: UIView.ContentMode.center)
            
            let tapRecognizer_1 = UITapGestureRecognizer(target: self, action: #selector(onBarcodeTouch))
            let tapRecognizer_2 = UITapGestureRecognizer(target: self, action: #selector(onBarcodeTouch))
            let tapRecognizer_3 = UITapGestureRecognizer(target: self, action: #selector(onBarcodeTouch))
            self.imgSmallBarcode.isUserInteractionEnabled = true
            self.imgSmallBarcode.addGestureRecognizer(tapRecognizer_1)
            self.imgSmallBarcode.addGestureRecognizer(tapRecognizer_2)
            self.imgSmallBarcode.addGestureRecognizer(tapRecognizer_3)
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        ANLoader.hide()
    }
    
    @objc func onBarcodeTouch() {
        var refreshAlert = UIAlertController(title: NSLocalizedString("CONFIRM",comment: "CONFIRM"), message: "", preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("YES",comment: "YES"), style: .default, handler: { (action: UIAlertAction!) in
            self.checkIn()
        }))

        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("NO",comment: "NO"), style: .cancel, handler: { (action: UIAlertAction!) in
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    func checkIn()
    {
        ANLoader.showLoading("", disableUI: true)
        
        let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM customer")
        guard let code = values.value(forKey: "customer_code") as? String else {
            ANLoader.hide()
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
        var parameters_arr: [String:AnyObject] = [:]
        parameters_arr["CustomerCode"] = code as AnyObject?

        do{
            HTTP.POST(GlobalVar.URL+"check_in.php", parameters:parameters_arr) { response in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    ANLoader.hide()
                }
                
                if let err = response.error {
                    Swift.debugPrint("check_in.php error:", err.localizedDescription)
                    return
                }
                if let code = response.statusCode, !(200...299).contains(code) {
                    Swift.debugPrint("check_in.php status:", code, response.text ?? "")
                    return
                }
                guard let body = response.text, let data = body.data(using: .utf8) else {
                    Swift.debugPrint("check_in.php empty/non-utf8 body")
                    return
                }
                // Parse but ignore content; just ensure valid JSON
                guard Util.nsdataToJSON(data) != nil else {
                    Swift.debugPrint("check_in.php invalid JSON:", body)
                    return
                }
                
                OperationQueue.main.addOperation {
                    let alert = UIAlertController(title: "", message: NSLocalizedString("WELCOMETOAZ", comment: "WELCOMETOAZ"), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: "OK"), style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } catch {
            ANLoader.hide()
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let alert = UIAlertController(title: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("NOINTERNETCONNECTION", comment: "WELCOMETOAZ"), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: "OK"), style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func call_parking(){
        let tel_no : String = self.defaults.value(forKey: "parking") as? String ?? ""
        guard !tel_no.isEmpty else { return }
        
        guard let url = URL(string: "tel://"+tel_no) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func read_values_from_server(){
        if !Reachability.isConnectedToNetwork(){
            show_values()
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var parameters_arr: [String:AnyObject] = [:]
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        parameters_arr["token"] = GlobalVar.deviceTokenString as AnyObject
        
        do{
            HTTP.POST(GlobalVar.URL+"subscription.php", parameters:parameters_arr) { response in
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let err = response.error {
                    Swift.debugPrint("subscription.php error:", err.localizedDescription)
                    return
                }
                if let code = response.statusCode, !(200...299).contains(code) {
                    Swift.debugPrint("subscription.php status:", code, response.text ?? "")
                    return
                }
                guard let body = response.text, let data = body.data(using: .utf8) else {
                    Swift.debugPrint("subscription.php empty/non-utf8 body")
                    return
                }
                guard let json_response = Util.nsdataToJSON(data) as? NSDictionary else {
                    Swift.debugPrint("subscription.php invalid JSON:", body)
                    return
                }
                
                if (json_response.value(forKey: "error") as? String == "true"){
                    // Logout sequence: reset DB queue BEFORE deleting the file
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.setValue(false, forKey: "launchedBefore")
                        UIApplication.shared.unregisterForRemoteNotifications()
                        
                        // Properly close and reset DB queue to avoid crashes on next login
                        ModelManager.reset()
                        Util.deleteFile("az.sqlite")
                        
                        let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                        UIApplication.shared.keyWindow?.rootViewController = Login
                    }
                    return
                }
                
                if let parking = json_response.value(forKey: "parking_number") as? String {
                    self.defaults.set(parking, forKey: "parking")
                }
                
                let values : NSMutableDictionary = NSMutableDictionary()
                values.setValue(json_response.value(forKey: "customer_fullname"), forKey: "customer_fullname")
                values.setValue(json_response.value(forKey: "customer_end_of_subscription"), forKey: "customer_end_of_subscription")
                values.setValue(json_response.value(forKey: "customer_remaining_amount"), forKey: "customer_remaining_amount")
                values.setValue(json_response.value(forKey: "customer_next_appointment"), forKey: "customer_next_appointment")
                values.setValue(json_response.value(forKey: "customer_questionnaire_exists"), forKey: "customer_questionnaire_exists")
                values.setValue(json_response.value(forKey: "customer_questionnaire_already_answer"), forKey: "customer_questionnaire_already_answer")
                
                ModelManager.getInstance().updateAll("customer", valuesDictionary: values)
                
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
                
                ModelManager.getInstance().deleteAll("question")
                if let qDict = json_response.value(forKey: "questions") as? NSDictionary,
                   let dataArr = qDict.value(forKey: "data") as? NSArray {
                    for i in 0 ..< dataArr.count{
                        let values : NSMutableDictionary = NSMutableDictionary()
                        let data_rec : NSDictionary = dataArr[i] as? NSDictionary ?? NSDictionary()
                        values.setValue(data_rec.value(forKey: "question_id"), forKey: "question_id")
                        values.setValue(data_rec.value(forKey: "question_en"), forKey: "question_en")
                        values.setValue(data_rec.value(forKey: "question_el"), forKey: "question_el")
                        ModelManager.getInstance().insert("question", valuesDictionary: values)
                    }
                }
                
                OperationQueue.main.addOperation {
                    self.show_values()
                }
            }
        } catch {
            OperationQueue.main.addOperation { }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}

extension HomeViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        //view.backgroundColor = theme.backgroundColor
    }
}

