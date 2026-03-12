//
//  MembershipTableViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 29/10/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import ANLoader

final class MembershipTableViewController: UITableViewController {
    var data : NSMutableArray = []
    
    func read_membership(){
        //ANLoader.showLoading("", disableUI: true)
        
        if !Reachability.isConnectedToNetwork(){
            OperationQueue.main.addOperation {
                self.read_news_value();
                
                self.refreshControl!.endRefreshing()
            }
        
            return;
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        
        do{
            HTTP.POST(GlobalVar.URL+"membership.php", parameters:parameters_arr) { response in
                //do things...
                
                OperationQueue.main.addOperation {
                    self.refreshControl!.endRefreshing()
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let err = response.error {
                    /*
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.setValue(false, forKey: "launchedBefore")
                        
                        let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                        
                        UIApplication.shared.unregisterForRemoteNotifications()
                        
                        Util.deleteFile("az.sqlite")
                        
                        self.present(Login, animated: true, completion: nil)
                    }
                    */
                    
                    return //also notify app of failure as needed
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "true"){
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.setValue(false, forKey: "launchedBefore")
                        
                        let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                        
                        UIApplication.shared.unregisterForRemoteNotifications()
                        
                        Util.deleteFile("az.sqlite")
                        
                        UIApplication.shared.keyWindow?.rootViewController = Login
                    }
                    
                    return //also notify app of failure as needed
                }
                
                ModelManager.getInstance().deleteAll("membership_privileges")
                
                //Getting the JSON array teams from the response
                let data: NSArray = json_response.value(forKey: "data") as! NSArray
                
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
                
               OperationQueue.main.addOperation {
                    // code here
                    self.read_news_value()
                
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    ANLoader.hide()
                }
                
            }
        } catch let error {
            
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            OperationQueue.main.addOperation {
                self.refreshControl!.endRefreshing()
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    func read_news_value(){
        data = ModelManager.getInstance().q("SELECT membership_privileges_id,membership_privileges_company_name,membership_privileges_image_path,membership_privileges_text_el,membership_privileges_text_en FROM membership_privileges ORDER BY membership_privileges_company_name")
        
        self.tableView.reloadData()
        
        ANLoader.hide()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
                
        self.navigationController?.navigationBar.tintColor = UIColor().convertHexStringToColor(GlobalVar.blueColor)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.topItem?.title = "";
        
        self.tableView.tableFooterView = UIView()
        
        ANLoader.pulseAnimation = true //It will animate your Loading
        ANLoader.activityColor = .white
        ANLoader.activityBackgroundColor = .clear
        ANLoader.activityTextColor = .clear
        ANLoader.viewBackgroundDark = true
        
        self.refreshControl = UIRefreshControl()
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = self.refreshControl
        } else {
            tableView.addSubview(self.refreshControl!)
        }
        
        // Configure Refresh Control
        self.refreshControl!.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.refreshControl!.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        self.read_news_value()
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Weather Data
        read_membership()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 244.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let message = messages[indexPath.row]
        let cell: MembershipCell = tableView.dequeueReusableCell(for: indexPath)
        
        let val : NSDictionary = data.object(at: indexPath.row) as! NSDictionary
        
        let id: Int =  val.value(forKey: "membership_privileges_id") as! Int
        let title: String =  val.value(forKey: "membership_privileges_company_name") as! String
        let details: String =  val.value(forKey: "membership_privileges_text_"+GlobalVar.deviceLang) as! String
        
        
        let imgPath = GlobalVar.URL+"image.php?id="+String(id)
        
        cell.fill(title, details: details, imgPath: imgPath, disable:GlobalVar.expired_sub )
        
        cell.selectionStyle = .none;
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
