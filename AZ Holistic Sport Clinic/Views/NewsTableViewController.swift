//
//  NewsTableViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 17/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

final class NewsTableViewController: UITableViewController {
    var data : NSMutableArray = []
    var selected_title : String = ""
    var selected_body  : String = ""
    var selected_date  : String = ""
    
    func read_news(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        
        do{
            HTTP.POST(GlobalVar.URL+"news.php", parameters:parameters_arr) { response in
                //do things...
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let err = response.error {
                    Swift.debugPrint("Error: \(err.localizedDescription)")
                    
                    //Logout function
                    OperationQueue.main.addOperation {
                        
                    }
                    
                    return //also notify app of failure as needed
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "true"){
                    //Logout function
                    OperationQueue.main.addOperation {
                        
                    }
                    
                    return //also notify app of failure as needed
                }
                
                ModelManager.getInstance().deleteAll("news")
                
                //Getting the JSON array teams from the response
                let data: NSArray = json_response.value(forKey: "data") as! NSArray
                
                //looping through all the json objects in the array teams
                for i in 0 ..< data.count{
                    let values : NSMutableDictionary = NSMutableDictionary()
                    let data_rec : NSDictionary = data[i] as! NSDictionary
                    
                    values.setValue(data_rec.value(forKey: "news_id"), forKey: "news_id")
                    values.setValue(data_rec.value(forKey: "news_title_en"), forKey: "news_title_en")
                    values.setValue(data_rec.value(forKey: "news_title_el"), forKey: "news_title_el")
                    values.setValue(data_rec.value(forKey: "news_text_en"), forKey: "news_text_en")
                    values.setValue(data_rec.value(forKey: "news_text_el"), forKey: "news_text_el")
                    values.setValue(data_rec.value(forKey: "news_date"), forKey: "news_date")
                    
                    
                    ModelManager.getInstance().insert("news", valuesDictionary: values)
                    
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                self.read_news_value()
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            OperationQueue.main.addOperation {
                
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    func read_news_value(){
        data = ModelManager.getInstance().q("SELECT news_id,news_title_en,news_title_el,news_text_en,news_text_el,strftime('%d/%m/%Y',news_date) as news_date FROM news ORDER BY news_date")
        
        self.tableView.reloadData()
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
        
        self.read_news()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let val : NSDictionary = data.object(at: section) as! NSDictionary
        let text: String =  (val.value(forKey: "diet_customer_time") as! String) + " - " + (val.value(forKey: "diet_customer_title_en") as! String)
        
        return text
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
        return 60.0
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
        let cell: NewsCell = tableView.dequeueReusableCell(for: indexPath)
        
        let val : NSDictionary = data.object(at: indexPath.section) as! NSDictionary
        let title: String =  val.value(forKey: "news_title_en") as! String
        let date: String =  val.value(forKey: "news_date") as! String
        
        cell.fill(date, title: title)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let arr: Array = UserDefaults.standard.value(forKey: "AppleLanguages") as! Array<String>
        let val : NSDictionary = data.object(at: indexPath.section) as! NSDictionary
        let title: String =  val.value(forKey: "news_title_en") as! String
        let body: String =  val.value(forKey: "news_text_en") as! String
        let date: String =  val.value(forKey: "news_date") as! String
        
        //if (arr[0] == "el"){
            selected_title  =   title
            selected_body  =   body
            selected_date  =   date
        //}else{
        //    selected_q  =   questions_en[(indexPath as NSIndexPath).row]
        //    selected_a  =   answers_en[(indexPath as NSIndexPath).row]
        //}
        
        //performSegue(withIdentifier: "show_faq_details", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // initialize new view controller and cast it as your view controller
        let viewController = segue.destination as! NewsDetails
        
        // your new view controller should have property that will store passed value
        viewController.n_body =   selected_body
        viewController.n_date =   selected_date
        viewController.n_title =   selected_title
    }
}
