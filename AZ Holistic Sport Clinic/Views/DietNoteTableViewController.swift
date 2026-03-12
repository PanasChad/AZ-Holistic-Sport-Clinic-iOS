//
//  DietNoteTableViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 05/06/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

class DietNoteTableViewController: UITableViewController {
    var data : NSDictionary = [:]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        data = ModelManager.getInstance().line("SELECT diet_customer_note,diet_customer_target,diet_customer_supplements FROM diet_customer")
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        
        var hasAnyData = false
        if let target = data.value(forKey: "diet_customer_target") as? String, !target.isEmpty { hasAnyData = true }
        if let suppl = data.value(forKey: "diet_customer_supplements") as? String, !suppl.isEmpty { hasAnyData = true }
        if let note = data.value(forKey: "diet_customer_note") as? String, !note.isEmpty { hasAnyData = true }
        
        if hasAnyData {
            tableView.clearBackground()
        } else {
            tableView.setMessage(NSLocalizedString("Noresults", comment: "Noresults"))
        }
            
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTheming()
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let target = data.value(forKey: "diet_customer_target") as? String, !target.isEmpty {
                return 1
            }
            return 0
        case 1:
            if let suppl = data.value(forKey: "diet_customer_supplements") as? String, !suppl.isEmpty {
                return 1
            }
            return 0
        case 2:
            if let note = data.value(forKey: "diet_customer_note") as? String, !note.isEmpty {
                return 1
            }
            return 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return NSLocalizedString("TARGET",comment: "TARGET")
        case 1:
            return NSLocalizedString("SUPPLEMENT",comment: "SUPPLEMENT")
        case 2:
            return NSLocalizedString("NOTE",comment: "NOTE")
        default:
            return "---"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if (data.value(forKey: "diet_customer_target") != nil){
                if (data.value(forKey: "diet_customer_target") as! String != ""){
                    return 30
                }
            }
            break;
        case 1:
            if (data.value(forKey: "diet_customer_supplements") != nil){
                if (data.value(forKey: "diet_customer_supplements") as! String != ""){
                    return 30
                }
            }
            break;
        case 2:
            if (data.value(forKey: "diet_customer_note") != nil){
                if (data.value(forKey: "diet_customer_note") as! String != ""){
                    return 30
                }
            }
            break;
        default:
            return 0
            
            break;
        }
        
        return 0
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
        
        if action == #selector(copy(_:)) {
            let pasteboard = UIPasteboard.general
            pasteboard.string = text
        }
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)

        let italicFont = UIFont.italicSystemFont(ofSize:13)
        
        var text: String =  ""
        
        switch indexPath.section {
        case 0:
            if (data.value(forKey: "diet_customer_target") != nil){
                text = data.value(forKey: "diet_customer_target") as! String
            }
            break;
        case 1:
            if (data.value(forKey: "diet_customer_supplements") != nil){
                text = data.value(forKey: "diet_customer_supplements") as! String
            }
            break;
        case 2:
            if (data.value(forKey: "diet_customer_note") != nil){
                text = data.value(forKey: "diet_customer_note") as! String
            }
            break;
        default:
            break;
        }
        
        
        var colorHex = "#555555"
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                colorHex = "#FFFFFF"
            }
        }
        
        let n_body = "<style>body{font-size:13px; color:" + colorHex + "; font-family: '"+UIFont.systemFont(ofSize: 13).familyName+"';}</style>" + text
        
        cell.textLabel?.attributedText = n_body.htmlAttributedString()
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.font = italicFont
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.isUserInteractionEnabled = true
        cell.textLabel?.sizeToFit()
        
        if #available(iOS 13.0, *) {
            cell.textLabel?.textColor = self.traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = themeProvider.currentTheme.textColor
            header.contentView.backgroundColor = themeProvider.currentTheme.backgroundColor
        }
    }
}

extension DietNoteTableViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        
        if let lblMessage = tableView.backgroundView as? UILabel {
            lblMessage.textColor = theme.textColor
        }
        
        tableView.reloadData()
    }
}

extension UITableView {

    func setMessage(_ message: String) {
        let lblMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        lblMessage.text = message
        lblMessage.textColor = AppThemeProvider.shared.currentTheme.textColor
        lblMessage.numberOfLines = 0
        lblMessage.textAlignment = .center
        lblMessage.font = UIFont(name: "TrebuchetMS", size: 15)
        lblMessage.sizeToFit()

        self.backgroundView = lblMessage
        self.separatorStyle = .none
    }

    func clearBackground() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
