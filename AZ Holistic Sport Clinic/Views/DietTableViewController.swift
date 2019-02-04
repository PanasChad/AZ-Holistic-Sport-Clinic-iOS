//
//  DietTableViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 12/12/2018.
//  Copyright © 2018 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

class DietTableViewController: UITableViewController {
    var data : NSMutableArray = []
    var date : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(DietCell.self, forCellReuseIdentifier: "diet")
        
        
        if (date == "Thursday"){
            date = "Thirsday"
        }
        
        data = ModelManager.getInstance().q("SELECT diet_customer_time,diet_customer_title_en,diet_customer_title_el,diet_customer_"+date+"_text as diet_customer_text FROM diet_customer WHERE diet_customer_"+date+"_text != '' AND diet_customer_"+date+"_text != '-' ORDER BY diet_customer_time")
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let val : NSDictionary = data.object(at: section) as! NSDictionary
        let text: String =  (val.value(forKey: "diet_customer_time") as! String) + " - " + (val.value(forKey: "diet_customer_title_en") as! String)
        
        return text
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 32
        }
        
        return 28
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let message = messages[indexPath.row]
        let cell : DietCell = tableView.dequeueReusableCell(withIdentifier: "diet") as! DietCell
        let italicFont = UIFont.italicSystemFont(ofSize:13)
        let val : NSDictionary = data.object(at: indexPath.section) as! NSDictionary
        let text: String =  val.value(forKey: "diet_customer_text") as! String
        
        cell.textLabel?.text = text
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.font = italicFont
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.adjustsFontSizeToFitWidth = true
    
        return cell
    }
}
