//
//  Texts.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 22/10/2020.
//  Copyright © 2020 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

class Texts: UIViewController {
    @IBOutlet weak var lblBody: UITextView!
    
    var n_body : String?
    var n_type : Int?
    var font_size = 20.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpTheming()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        

        
        let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM `texts` WHERE texts_id = " + String(n_type ?? 1))
        
        //We need to call URL and get last data
        if (values.allKeys.count == 0){
            if !Reachability.isConnectedToNetwork(){
                return
            }
            
            var parameters_arr: [String:AnyObject] = [:]
            
            /*ALWAYS NEED THEM FOR CHECK*/
            parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject?
            parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
            
            parameters_arr["need_datetime"] = "false" as AnyObject
            parameters_arr["text_type"] = self.n_type as AnyObject?
            
            
            do{
                try HTTP.POST(GlobalVar.URL+"gym_texts.php", parameters:parameters_arr){ response in
                    //do things...
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    Swift.debugPrint(response.text)
                    
                    if (response.text == ""){
                        return
                    }
                    
                    if let err = response.error {
                        Swift.debugPrint("Error: \(err.localizedDescription)")
                        
                        return //also notify app of failure as needed
                    }
                    
                    let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                    
                    let values : NSMutableDictionary = NSMutableDictionary()
                    values.setValue(json_response.value(forKey: "texts_id") as! String, forKey: "texts_id")
                    values.setValue(json_response.value(forKey: "texts_title") as! String, forKey: "texts_title")
                    values.setValue(json_response.value(forKey: "texts_text_en") as! String, forKey: "texts_text_en")
                    values.setValue(json_response.value(forKey: "texts_text_el") as! String, forKey: "texts_text_el")
                    values.setValue(json_response.value(forKey: "texts_modified_date") as! String, forKey: "texts_modified_date")
                    
                    ModelManager.getInstance().deleteAll("texts")
                    ModelManager.getInstance().insert("texts", valuesDictionary: values)
                    
                    self.n_body = json_response.value(forKey: "texts_text_"+GlobalVar.deviceLang) as! String
                    
                    OperationQueue.main.addOperation {
                        if (self.traitCollection.userInterfaceStyle == .dark) {
                            self.n_body = "<style>body{font-size:20px; color:#ffffff; font-family: 'Arial';}</style>" + self.n_body!
                        }else{
                            self.n_body = "<style>body{font-size:20px; color:#555555; font-family: 'Arial';}</style>" +
                                self.n_body!
                        }
                        
                        let baseFont = UIFont.systemFont(ofSize: self.font_size)

                        if let attrString = attributedStringFromHTML(self.n_body ?? "", baseFont: baseFont) {
                            self.lblBody.attributedText = attrString
                        }
                        
                        
                    }
                }
            } catch let error {
                Swift.debugPrint("Got an error creating the request: \(error)")
                
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }else{
            if !Reachability.isConnectedToNetwork(){
                self.n_body = values.value(forKey: "texts_text_"+GlobalVar.deviceLang) as! String
                
                OperationQueue.main.addOperation {
                    if (self.traitCollection.userInterfaceStyle == .dark) {
                        self.n_body = "<style>body{font-size:20px; color:#ffffff; font-family: 'Arial';}</style>" + self.n_body!
                    }else{
                        self.n_body = "<style>body{font-size:20px; color:#555555; font-family: 'Arial';}</style>" +
                            self.n_body!
                    }
                    
                    self.lblBody?.attributedText = self.n_body?.htmlAttributedString()
                }
            }else{
                
                var parameters_arr: [String:AnyObject] = [:]
                
                /*ALWAYS NEED THEM FOR CHECK*/
                parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject?
                parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
                
                parameters_arr["need_datetime"] = "true" as AnyObject
                parameters_arr["text_type"] = self.n_type as AnyObject?
                
                
                do{
                    try HTTP.POST(GlobalVar.URL+"gym_texts.php", parameters:parameters_arr){ response in
                        //do things...
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        //Swift.debugPrint(response.text)
                        
                        if (response.text == ""){
                            return
                        }
                        
                        if let err = response.error {
                            Swift.debugPrint("Error: \(err.localizedDescription)")
                            
                            return //also notify app of failure as needed
                        }
                        
                        let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                        
                        //We dont need update
                        if (json_response.value(forKey: "texts_modified_date") as! String != "0000-00-00 00:00:00" && json_response.value(forKey: "texts_modified_date") as! String == values.value(forKey: "texts_modified_date") as! String){
                            self.n_body = values.value(forKey: "texts_text_"+GlobalVar.deviceLang) as! String
                            
                            OperationQueue.main.addOperation {
                                if (self.traitCollection.userInterfaceStyle == .dark) {
                                    self.n_body = """
                                    <style>
                                    body {
                                        font-size: 20px;
                                        color: #ffffff;
                                        font-family: 'Arial';
                                        line-height: 1.4;
                                    }
                                    </style>
                                    """ + self.n_body!
                                    
                                }else{
                                    self.n_body = """
                                    <style>
                                    body {
                                        font-size: 20px;
                                        color: #000000;
                                        font-family: 'Arial';
                                        line-height: 1.4;
                                    }
                                    </style>
                                    """ + self.n_body!
                                }
                                
                                
                                let baseFont = UIFont.systemFont(ofSize: self.font_size)

                                if let attrString = attributedStringFromHTML(self.n_body ?? "", baseFont: baseFont) {
                                    self.lblBody?.attributedText = attrString
                                }
                            }
                            //We need to download last update
                        }else{
                            var parameters_arr: [String:AnyObject] = [:]
                            
                            /*ALWAYS NEED THEM FOR CHECK*/
                            parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject?
                            parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
                            
                            parameters_arr["need_datetime"] = "false" as AnyObject
                            parameters_arr["text_type"] = self.n_type as AnyObject?
                            
                            
                            do{
                                try HTTP.POST(GlobalVar.URL+"gym_texts.php", parameters:parameters_arr){ response in
                                    //do things...
                                    
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    Swift.debugPrint(response.text)
                                    
                                    if (response.text == ""){
                                        return
                                    }
                                    
                                    if let err = response.error {
                                        Swift.debugPrint("Error: \(err.localizedDescription)")
                                        
                                        return //also notify app of failure as needed
                                    }
                                    
                                    let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                                    
                                    let values : NSMutableDictionary = NSMutableDictionary()
                                    let whereDict : NSMutableDictionary = NSMutableDictionary()
                                    whereDict.setValue(json_response.value(forKey: "texts_id") as! String, forKey: "texts_id")
                                    values.setValue(json_response.value(forKey: "texts_title") as! String, forKey: "texts_title")
                                    values.setValue(json_response.value(forKey: "texts_text_en") as! String, forKey: "texts_text_en")
                                    values.setValue(json_response.value(forKey: "texts_text_el") as! String, forKey: "texts_text_el")
                                    values.setValue(json_response.value(forKey: "texts_modified_date") as! String, forKey: "texts_modified_date")
                                    
                                    ModelManager.getInstance().update("text", valuesDictionary: values, whereDictionary: whereDict)
                                    
                                    self.n_body = json_response.value(forKey: "texts_text_"+GlobalVar.deviceLang) as! String
                                    
                                    OperationQueue.main.addOperation {
                                        if (self.traitCollection.userInterfaceStyle == .dark) {
                                            self.n_body = "<style>body{font-size:20px; color:#ffffff; font-family: 'Arial';}</style>" + self.n_body!
                                        }else{
                                            self.n_body = "<style>body{font-size:20px; color:#555555; font-family: 'Arial';}</style>" +
                                                self.n_body!
                                        }
                                        
                                        self.lblBody?.attributedText = self.n_body?.htmlAttributedString()
                                    }
                                    
                                }
                            } catch let error {
                                Swift.debugPrint("Got an error creating the request: \(error)")
                                
                                
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        }
                        
                        
                        
                    }
                } catch let error {
                    Swift.debugPrint("Got an error creating the request: \(error)")
                    
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
        
        if (n_type == 1){
            self.navigationItem.title = NSLocalizedString("GDPR", comment: "GDPR")
        }else if (n_type == 2){
            self.navigationItem.title = NSLocalizedString("PAYMENT_TERMS", comment: "PAYMENT_TERMS")
        }else if(n_type == 3){
            self.navigationItem.title = NSLocalizedString("DIET_RULES", comment: "DIET_RULES")
        }else if(n_type == 4){
            self.navigationItem.title = NSLocalizedString("TIMETABLE", comment: "TIMETABLE")
        }else if(n_type == 5){
            self.navigationItem.title = NSLocalizedString("TRAINERS", comment: "TRAINERS")
        }
        
        
    }
    
}

extension Texts: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        
        //titleLabel.textColor = theme.textColor
        //subtitleLabel.textColor = theme.textColor
        lblBody.textColor = theme.textColor
        
        if (theme.textColor == .white ){
            if (n_body != nil){
                n_body = """
                <style>
                body {
                    font-size: 20px;
                    color: #ffffff;
                    font-family: 'Arial';
                    line-height: 1.4;
                }
                </style>
                """ + n_body!
                
                lblBody?.attributedText = n_body?.htmlAttributedString()
            }
        }else{
            if (n_body != nil){
                n_body = """
                <style>
                body {
                    font-size: 20px;
                    color: #000000;
                    font-family: 'Arial';
                    line-height: 1.4;
                }
                </style>
                """ + n_body!
                lblBody?.attributedText = n_body?.htmlAttributedString()
            
            }
        }
        
        let baseFont = UIFont.systemFont(ofSize: font_size)

        if let attrString = attributedStringFromHTML(n_body ?? "", baseFont: baseFont) {
            lblBody.attributedText = attrString
        }
        
        
        
        lblBody.backgroundColor = theme.backgroundColor
    }
}

extension UIFont {
    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0) // 0 keeps the current size
    }
}

func attributedStringFromHTML(_ html: String, baseFont: UIFont) -> NSAttributedString? {
    guard let data = html.data(using: .utf8) else { return nil }

    // Parse HTML to NSAttributedString
    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
    ]

    guard let attributedString = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
        return nil
    }

    // Update fonts while preserving bold/italic traits
    attributedString.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedString.length)) { value, range, _ in
        if let originalFont = value as? UIFont {
            let traits = originalFont.fontDescriptor.symbolicTraits
            let newFont = baseFont.with(traits: traits)
            attributedString.addAttribute(.font, value: newFont, range: range)
        }
    }

    return attributedString
}
