//
//  LoginViewController.swift
//  Kapodistrias Tool
//
//  Created by Μανώλης Γεωργίου on 01/08/16.
//  Copyright © 2016 Μανώλης Γεωργίου. All rights reserved.
//

import UIKit
import SwiftHTTP

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblPassowrd: UILabel!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var lblUrl1: UILabel!
    @IBOutlet weak var lblUrl2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnSubmit.layer.cornerRadius = 5
        
        txtUsername.delegate = self
        txtPassword.delegate = self
        
        let tap_1 = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.open_url))
        let tap_2 = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.open_url))
        
        lblUrl1.isUserInteractionEnabled = true
        lblUrl1.addGestureRecognizer(tap_1)
        
        lblUrl2.isUserInteractionEnabled = true
        lblUrl2.addGestureRecognizer(tap_2)
    }
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == txtUsername){
            txtPassword.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
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
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  txtUsername.text as AnyObject?
        parameters_arr["password"] = txtPassword.text as AnyObject?
        
        self.btnSubmit.isEnabled = false
        self.txtUsername.isEnabled = false
        self.txtPassword.isEnabled = false
        
        do{
            HTTP.POST(GlobalVar.URL+"login.php", parameters:parameters_arr) { response in
                //do things...
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                
                
                if let err = response.error {
                    Swift.debugPrint("Error: \(err.localizedDescription)")
                    
                    let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        
                    }
                    alertController.addAction(OKAction)
                    
                    OperationQueue.main.addOperation {
                        self.btnSubmit.isEnabled = true
                        self.txtUsername.isEnabled = true
                        self.txtPassword.isEnabled = true
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    return //also notify app of failure as needed
                }
                
                Util.copyFile("az.sqlite")
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "true"){
                    let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        
                    }
                    alertController.addAction(OKAction)
                    
                    OperationQueue.main.addOperation {
                        self.btnSubmit.isEnabled = true
                        self.txtUsername.isEnabled = true
                        self.txtPassword.isEnabled = true
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                    return //also notify app of failure as needed
                }
                
                Swift.debugPrint("Customer ID: \(json_response.value(forKey: "my_customer_id"))")
                Swift.debugPrint("Customer KEY: \(json_response.value(forKey: "my_customer_key"))")
                
                let values : NSMutableDictionary = NSMutableDictionary()
                
                values.setValue(json_response.value(forKey: "customer_id"), forKey: "customer_id")
                values.setValue(json_response.value(forKey: "customer_code"), forKey: "customer_code")
                values.setValue(self.txtPassword.text as! String, forKey: "customer_password")
                values.setValue(json_response.value(forKey: "customer_fullname"), forKey: "customer_fullname")
                values.setValue(json_response.value(forKey: "customer_end_of_subscription"), forKey: "customer_end_of_subscription")
                values.setValue(json_response.value(forKey: "customer_remaining_amount"), forKey: "customer_remaining_amount")
                values.setValue(json_response.value(forKey: "customer_next_appointment"), forKey: "customer_next_appointment")
                values.setValue(json_response.value(forKey: "customer_mobile_token"), forKey: "customer_mobile_token")
                
                //values.setValue(json_response.value(forKey: "customer_id"), forKey: "customer_language")
                //values.setValue(json_response.value(forKey: "customer_id"), forKey: "customer_notifications")
                
                ModelManager.getInstance().deleteAll("customer")
                ModelManager.getInstance().insert("customer", valuesDictionary: values)
                
                GlobalVar.deviceID = json_response.value(forKey: "customer_id")as! String
                GlobalVar.deviceCode = json_response.value(forKey: "customer_code")as! String
                GlobalVar.devicePassword = self.txtPassword.text as! String
                
                //GlobalVar.deviceTokenString = json_response.value(forKey: "my_customer_key") as! String
                GlobalVar.deviceLang = ""
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                OperationQueue.main.addOperation {
                    self.btnSubmit.isEnabled = true
                    self.txtUsername.isEnabled = true
                    self.txtPassword.isEnabled = true
                    
                    self.present(mainViewController, animated: true, completion: nil)
                }
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            let alertController = UIAlertController(title: NSLocalizedString("ERROR",comment: "Attention"), message:NSLocalizedString("WRONGLOGIN", comment: "WRONGLOGIN"), preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                
            }
            alertController.addAction(OKAction)
            
            OperationQueue.main.addOperation {
                self.btnSubmit.isEnabled = true
                self.txtUsername.isEnabled = true
                self.txtPassword.isEnabled = true
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
