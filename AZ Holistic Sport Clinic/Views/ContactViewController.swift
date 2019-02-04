//
//  ContactViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 14/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

class ContactViewController: UITableViewController {
    
    @IBOutlet weak var txtTitle : UITextField!
    @IBOutlet weak var txtSubject : UITextField!
    
    @IBOutlet weak var txtBody : UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtBody.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        txtBody.layer.borderWidth = 1.0
        txtBody.layer.cornerRadius = 5
        
        txtBody.placeholder = "Add you body text"
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor().convertHexStringToColor(GlobalVar.blueColor)
        
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.topItem?.title = "";
        
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "send"), style: .done, target: self, action: #selector(send_message))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        
    }
    
    @objc func send_message(){
        
        if ((txtTitle.text?.isEmpty)! || (txtSubject.text?.isEmpty)! || (txtBody.text?.isEmpty)!){
            let alert = UIAlertController(title: "Alert", message: "Please fill the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                }}))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        
        parameters_arr["title"] = txtTitle.text as AnyObject
        parameters_arr["subject"] = txtSubject.text as AnyObject
        parameters_arr["body"] = txtBody.text as AnyObject
        
        self.txtTitle.becomeFirstResponder()
        
        do{
            
            HTTP.POST(GlobalVar.URL+"complaint_admissions.php", parameters:parameters_arr) { response in
                //do things...
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    UIViewController.removeSpinner(spinner: sv)
                }
                
                if let err = response.error {
                    Swift.debugPrint("Error: \(err.localizedDescription)")
                    
                    //Logout function
                    OperationQueue.main.addOperation {
                        
                    }
                    
                    return //also notify app of failure as needed
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "false"){
                    //Logout function
                    OperationQueue.main.addOperation {
                        self.txtTitle.text = ""
                        self.txtSubject.text = ""
                        self.txtBody.text = ""
                        
                        
                        let alert = UIAlertController(title: "Success", message: "We approciate for your message.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            switch action.style{
                            case .default:
                                print("default")
                                
                            case .cancel:
                                print("cancel")
                                
                            case .destructive:
                                print("destructive")
                                
                                
                            }
                            
                            self.txtTitle.becomeFirstResponder()
                        }))
                        
                        alert.view.layoutIfNeeded()
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return //also notify app of failure as needed
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            OperationQueue.main.addOperation {
                
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
}
