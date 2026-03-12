//
//  DietNoteTableViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 05/06/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

class Evaluation: UITableViewController {
    var data : NSDictionary = [:]
    
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

        data = ModelManager.getInstance().line("SELECT * FROM customer_lipometry_evaluation")
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        
        if(data.object(forKey: "customer_lipometry_evaluation_date") != nil){
            self.navigationController?.navigationBar.topItem?.title = data.value(forKey: "customer_lipometry_evaluation_date") as! String
            self.navigationItem.title = data.value(forKey: "customer_lipometry_evaluation_date") as! String
        }
            
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 8, y: 0, width: UIScreen.main.bounds.width - 8, height: 30)
        myLabel.font = UIFont.boldSystemFont(ofSize: 12)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        

        let headerView = UIView()
        headerView.addSubview(myLabel)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                headerView.backgroundColor = UIColor(red: 0.39, green: 0.43, blue: 0.45, alpha: 1.00)
            }else{
                headerView.backgroundColor = UIColor(red: 232/255, green: 233/255, blue: 237/255, alpha: 1)
            }
        }
        

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  NSLocalizedString("QUESTION" + String(section+1), comment: "QUESTION")
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)

        let italicFont = UIFont.italicSystemFont(ofSize:13)
        
        var text: String =  ""
        
        if(data.object(forKey: "customer_lipometry_evaluation_q"+String(indexPath.section+1)) != nil){
            text = data.value(forKey: "customer_lipometry_evaluation_q"+String(indexPath.section+1)) as! String
        }else{
            text = ""
        }
        
        var n_body = "<style>body{font-size:13px; color:#555555; font-family: '"+UIFont.systemFont(ofSize: 13).familyName+"';}</style>" + text
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                n_body = "<style>body{font-size:13px; color:#ffffff; font-family: '"+UIFont.systemFont(ofSize: 13).familyName+"';}</style>" + text
            }else{
                n_body = "<style>body{font-size:13px; color:#555555; font-family: '"+UIFont.systemFont(ofSize: 13).familyName+"';}</style>" + text
            }
        }
        
        cell.textLabel?.attributedText = n_body.htmlAttributedString()
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.font = italicFont
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.isUserInteractionEnabled = true
        cell.textLabel?.sizeToFit()
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)



        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.backgroundColor = UIColor.clear
    }
}

extension Evaluation: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
    }
}
