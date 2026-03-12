//
//  ContactViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 14/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

class ContactViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var txtTitle : UITextField!
    @IBOutlet weak var txtPhone : UILabel!
    @IBOutlet weak var txtBody : UITextView!
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtTitle.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        txtBody.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        
        textField.layer.borderColor = UIColor().convertHexStringToColor(GlobalVar.blueColor).cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        txtTitle.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        
        txtBody.layer.borderColor = UIColor().convertHexStringToColor(GlobalVar.blueColor).cgColor
        
        //txtBody.placeholder = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //if (txtBody.text == ""){
        //    txtBody.placeholder = NSLocalizedString("Addyourbodytexthere",comment: "Add_your_body_text_here")
        //}else{
        //    txtBody.placeholder = ""
        //}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTheming()
        
        txtTitle.delegate = self
        
        txtTitle.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        txtTitle.layer.borderWidth = 1.0
        txtTitle.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(make_a_call))
        txtPhone.isUserInteractionEnabled = true
        txtPhone.addGestureRecognizer(tap)
        
        txtTitle.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        txtBody.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        txtBody.layer.borderWidth = 1.0
        txtBody.layer.cornerRadius = 5
        
        //txtBody.placeholder = NSLocalizedString("Addyourbodytexthere",comment: "Add_your_body_text_here")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor().convertHexStringToColor(GlobalVar.blueColor)
        
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.topItem?.title = "";
        
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "send"), style: .done, target: self, action: #selector(send_message))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        txtBody.delegate = self
    }
    
    @objc func make_a_call(){
        guard let url = URL(string: "tel://70003400") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func send_message(){
        
        if ((txtTitle.text?.isEmpty)!  || (txtBody.text?.isEmpty)!){
            let alert = UIAlertController(title: NSLocalizedString("alert",comment: "Alert"), message: NSLocalizedString("Pleasefillthefields",comment: "Pleasefillthefields"), preferredStyle: .alert)
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
                        self.txtBody.text = ""
                        
                        
                        let alert = UIAlertController(title: NSLocalizedString("SUCCESS",comment: "Alert"), message: NSLocalizedString("Weapprociateforyourmessage",comment: "Alert"), preferredStyle: .alert)
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

extension ContactViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        //titleLabel.textColor = theme.textColor
        //subtitleLabel.textColor = theme.textColor
        txtTitle.textColor = theme.textColor
        txtPhone.textColor = theme.textColor
        txtBody.textColor = theme.textColor
        
        txtTitle.backgroundColor = theme.backgroundColor
        txtPhone.backgroundColor = theme.backgroundColor
        txtBody.backgroundColor = theme.backgroundColor
    }
}
