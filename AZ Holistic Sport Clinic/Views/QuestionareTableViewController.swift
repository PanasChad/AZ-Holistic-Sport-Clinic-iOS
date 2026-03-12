//
//  Questionare.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 06/02/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import Foundation
//
//  ContactViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 14/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import Cosmos

class QuestionareTableViewController: UITableViewController {
    
    @IBOutlet weak var qst_1: CosmosView!
    @IBOutlet weak var qst_2: CosmosView!
    @IBOutlet weak var qst_3: CosmosView!
    @IBOutlet weak var qst_4: CosmosView!
    @IBOutlet weak var qst_5: CosmosView!
    @IBOutlet weak var qst_6: CosmosView!
    @IBOutlet weak var qst_7: CosmosView!
    @IBOutlet weak var qst_8: CosmosView!
    
    var data : NSMutableArray = []
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        data = ModelManager.getInstance().q("SELECT * FROM question")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = ModelManager.getInstance().q("SELECT * FROM question")
        
        setUpTheming()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor().convertHexStringToColor(GlobalVar.blueColor)
        
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.topItem?.title = "";
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "send"), style: .done, target: self, action: #selector(send_message))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        
    }
    
    // Hide header text by making clear
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        
        if (data.count < section + 1) {
            headerView.textLabel!.textColor = UIColor.clear
        }else if (section <= 7 && data.count >= section + 1){
            let val : NSDictionary = data.object(at: section) as! NSDictionary
            
            headerView.textLabel!.text = val.object(forKey: "question_"+GlobalVar.deviceLang) as! String
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if (data.count + 1 < section && section != 8) {
            let footerView = view as! UITableViewHeaderFooterView
            footerView.textLabel!.textColor = UIColor.clear
        }
    }
    
    
    // Hide Header(s)
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (data.count < section + 1 && section != 8) {
            return 0;
        }
        
        return  super.tableView(tableView, heightForHeaderInSection: section);
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (data.count < indexPath.section + 1 && indexPath.section != 8) {
            return 0;
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (data.count < section + 1 && section != 8) {
            return 0;
        }
        
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
    @objc func send_message(){
        if (qst_1.rating == 0 && qst_2.rating == 0 && qst_3.rating == 0 && qst_4.rating == 0 && qst_5.rating == 0 && qst_6.rating == 0 && qst_7.rating == 0 && qst_8.rating == 0){
            let alert = UIAlertController(title: NSLocalizedString("alert",comment: "Alert"), message: NSLocalizedString("ANSWERTATLEASTONE", comment: "ANSWERTATLEASTONE"), preferredStyle: .alert)
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
        
        parameters_arr["qst_1"] = qst_1.rating as AnyObject
        parameters_arr["qst_2"] = qst_2.rating as AnyObject
        parameters_arr["qst_3"] = qst_3.rating as AnyObject
        parameters_arr["qst_4"] = qst_4.rating as AnyObject
        parameters_arr["qst_5"] = qst_5.rating as AnyObject
        parameters_arr["qst_6"] = qst_6.rating as AnyObject
        parameters_arr["qst_7"] = qst_7.rating as AnyObject
        parameters_arr["qst_8"] = qst_8.rating as AnyObject
        
        do{
            
            HTTP.POST(GlobalVar.URL+"questionaire.php", parameters:parameters_arr) { response in
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
                        self.qst_1.rating = 0
                        self.qst_2.rating = 0
                        self.qst_3.rating = 0
                        self.qst_4.rating = 0
                        self.qst_5.rating = 0
                        self.qst_6.rating = 0
                        self.qst_7.rating = 0
                        self.qst_8.rating = 0
                        
                        let data_rec : NSMutableDictionary = NSMutableDictionary()
                        
                        data_rec.setValue("true", forKey: "customer_questionnaire_already_answer")
                        
                         ModelManager.getInstance().updateAll("customer", valuesDictionary: data_rec)
                        
                        let alert = UIAlertController(title: NSLocalizedString("SUCCESS",comment: "Alert"), message: NSLocalizedString("QUIESTONAIREANSWERS",comment: "Alert"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            switch action.style{
                            case .default:
                                print("default")

                                self.navigationController?.popViewController(animated: true)
                                
                            case .cancel:
                                print("cancel")
                                
                            case .destructive:
                                print("destructive")
                                
                                
                            }

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


extension QuestionareTableViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        //titleLabel.textColor = theme.textColor
        //subtitleLabel.textColor = theme.textColor
    }
}
