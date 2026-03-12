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
    static var readData : Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                self.themeProvider.currentTheme = .dark
            }else{
                self.themeProvider.currentTheme = .light
            }
        }
        
        if (DietTableViewController.readData){
            data = ModelManager.getInstance().q("SELECT diet_customer_time,diet_customer_title_en,diet_customer_title_el,diet_customer_"+date+"_text as diet_customer_text FROM diet_customer WHERE diet_customer_"+date+"_text != '' AND diet_customer_"+date+"_text != '-' ORDER BY diet_customer_time")
        
            self.tableView.reloadData()
            
            //DietTableViewController.readData = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(DietCell.self, forCellReuseIdentifier: "diet")
        
        switch date {
        case "Δευτέρα":
            date = "Monday"
            break;
        case "Τρίτη":
            date = "Tuesday"
            break;
        case "Τετάρτη":
            date = "Wednesday"
            break;
        case "Thursday":
            date = "Thirsday"
            break
        case "Πέμπτη":
            date = "Thirsday"
            break;
        case "Παρασκευή":
            date = "Friday"
        case "Σάββατο":
            date = "Saturday"
            break;
        case "Κυριακή":
            date = "Sunday"
        default: break
            
        }
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let val : NSDictionary = data.object(at: section) as! NSDictionary
        let text: String =  (val.value(forKey: "diet_customer_time") as! String) + " - " + (val.value(forKey: "diet_customer_title_"+GlobalVar.deviceLang) as! String)
        
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
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        return action == #selector(copy(_:))
    }
    
    override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        
        let cell = self.tableView.cellForRow(at: indexPath)
        let text = cell?.textLabel?.text
        
        if action == #selector(copy(_:)) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = text
        }
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
        cell.textLabel?.isUserInteractionEnabled = true
        
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.backgroundColor = UIColor.clear
    }
}

extension DietTableViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        
        //titleLabel.textColor = theme.textColor
        //subtitleLabel.textColor = theme.textColor
    }
}
