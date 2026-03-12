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
        
        loadData()
        
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
    
    private func loadData() {
        let values:NSDictionary = ModelManager.getInstance().line("SELECT * FROM `texts` WHERE texts_id = " + String(n_type ?? 1))
        
        if (values.allKeys.count == 0){
            if !Reachability.isConnectedToNetwork(){ return }
            
            var parameters_arr: [String:AnyObject] = [:]
            parameters_arr["username"] = GlobalVar.deviceUsername as AnyObject?
            parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
            parameters_arr["need_datetime"] = "false" as AnyObject
            parameters_arr["text_type"] = self.n_type as AnyObject?
            
            do {
                try HTTP.POST(GlobalVar.URL+"gym_texts.php", parameters:parameters_arr) { response in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if response.text == "" { return }
                    if let err = response.error { return }
                    
                    let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                    let values : NSMutableDictionary = NSMutableDictionary()
                    values.setValue(json_response.value(forKey: "texts_id") as! String, forKey: "texts_id")
                    values.setValue(json_response.value(forKey: "texts_title") as! String, forKey: "texts_title")
                    values.setValue(json_response.value(forKey: "texts_text_en") as! String, forKey: "texts_text_en")
                    values.setValue(json_response.value(forKey: "texts_text_el") as! String, forKey: "texts_text_el")
                    values.setValue(json_response.value(forKey: "texts_modified_date") as! String, forKey: "texts_modified_date")
                    
                    ModelManager.getInstance().deleteAll("texts")
                    ModelManager.getInstance().insert("texts", valuesDictionary: values)
                    
                    OperationQueue.main.addOperation {
                        self.n_body = json_response.value(forKey: "texts_text_"+GlobalVar.deviceLang) as? String
                        self.applyTheme(AppThemeProvider.shared.currentTheme)
                    }
                }
            } catch {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        } else {
            if !Reachability.isConnectedToNetwork() {
                self.n_body = values.value(forKey: "texts_text_"+GlobalVar.deviceLang) as? String
                self.applyTheme(AppThemeProvider.shared.currentTheme)
            } else {
                var parameters_arr: [String:AnyObject] = [:]
                parameters_arr["username"] = GlobalVar.deviceUsername as AnyObject?
                parameters_arr["password"] = GlobalVar.devicePassword as AnyObject?
                parameters_arr["need_datetime"] = "true" as AnyObject
                parameters_arr["text_type"] = self.n_type as AnyObject?
                
                do {
                    try HTTP.POST(GlobalVar.URL+"gym_texts.php", parameters:parameters_arr) { response in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        if response.text == "" { return }
                        if let err = response.error { return }
                        
                        let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                        
                        if (json_response.value(forKey: "texts_modified_date") as! String != "0000-00-00 00:00:00" && json_response.value(forKey: "texts_modified_date") as! String == values.value(forKey: "texts_modified_date") as! String) {
                            OperationQueue.main.addOperation {
                                self.n_body = values.value(forKey: "texts_text_"+GlobalVar.deviceLang) as? String
                                self.applyTheme(AppThemeProvider.shared.currentTheme)
                            }
                        } else {
                            var p_arr: [String:AnyObject] = [:]
                            p_arr["username"] = GlobalVar.deviceUsername as AnyObject?
                            p_arr["password"] = GlobalVar.devicePassword as AnyObject?
                            p_arr["need_datetime"] = "false" as AnyObject
                            p_arr["text_type"] = self.n_type as AnyObject?
                            
                            do {
                                try HTTP.POST(GlobalVar.URL+"gym_texts.php", parameters:p_arr) { resp in
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    if resp.text == "" { return }
                                    
                                    let j_resp : NSDictionary = Util.nsdataToJSON(resp.text!.data(using: String.Encoding.utf8)!)!
                                    let v : NSMutableDictionary = NSMutableDictionary()
                                    let w : NSMutableDictionary = NSMutableDictionary()
                                    w.setValue(j_resp.value(forKey: "texts_id") as! String, forKey: "texts_id")
                                    v.setValue(j_resp.value(forKey: "texts_title") as! String, forKey: "texts_title")
                                    v.setValue(j_resp.value(forKey: "texts_text_en") as! String, forKey: "texts_text_en")
                                    v.setValue(j_resp.value(forKey: "texts_text_el") as! String, forKey: "texts_text_el")
                                    v.setValue(j_resp.value(forKey: "texts_modified_date") as! String, forKey: "texts_modified_date")
                                    
                                    ModelManager.getInstance().update("text", valuesDictionary: v, whereDictionary: w)
                                    
                                    OperationQueue.main.addOperation {
                                        self.n_body = j_resp.value(forKey: "texts_text_"+GlobalVar.deviceLang) as? String
                                        self.applyTheme(AppThemeProvider.shared.currentTheme)
                                    }
                                }
                            } catch {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        }
                    }
                } catch {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
}

extension Texts: Themed {
    func applyTheme(_ theme: AppTheme) {
        guard isViewLoaded else { return }
        
        view.backgroundColor = theme.backgroundColor
        lblBody.textColor = theme.textColor
        lblBody.backgroundColor = theme.backgroundColor

        let colorHex = theme.textColor == .white ? "#ffffff" : "#555555"
        
        if let body = n_body {
            let styledBody = """
            <style>
            body {
                font-size: 20px;
                color: \(colorHex);
                font-family: 'Arial';
                line-height: 1.4;
            }
            </style>
            """ + body
            
            let baseFont = UIFont.systemFont(ofSize: font_size)
            if let attrString = attributedStringFromHTML(styledBody, baseFont: baseFont) {
                lblBody.attributedText = attrString
            }
        }
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
