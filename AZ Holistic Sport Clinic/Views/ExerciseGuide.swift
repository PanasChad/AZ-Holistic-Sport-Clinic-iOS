//
//  ExerciseGuide.swift
//  AZ Holistic Sport Clinic
//
//  Created by Developer User1 on 11/04/2025.
//  Copyright © 2025 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

import UIKit

class ExerciseGuide: UIViewController {
    @IBOutlet weak var lblBody: UITextView!
    
    var n_body: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTheming()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch from local DB using your custom query
        let values: NSDictionary = ModelManager.getInstance().line("SELECT * FROM others WHERE others_field='exercise_guide'")

        if let html = values.value(forKey: "others_value") as? String {
            n_body = html
        } else {
            n_body = "<p>No guide found.</p>"
        }

        applyTheme(themeProvider.currentTheme)
        
        self.navigationItem.title = NSLocalizedString("EXERCISE_GUIDE", comment: "EXERCISE_GUIDE")
        
        //n_body = "<style>body{font-size:16px; color:#ffffff; font-family: '"+UIFont.systemFont(ofSize: 16).familyName+"';}</style>" + n_body!
        
        
    }
    
}


extension ExerciseGuide: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        
        //titleLabel.textColor = theme.textColor
        //subtitleLabel.textColor = theme.textColor
        lblBody.textColor = theme.textColor
        
        if (theme.textColor == .white ){
            if (n_body != nil){
                n_body = n_body?
                    .replacingOccurrences(of: "<ul>", with: "")
                    .replacingOccurrences(of: "</ul>", with: "")
                    .replacingOccurrences(of: "<li>", with: "&bull; ")
                    .replacingOccurrences(of: "</li>", with: "<br>")

                n_body = """
                    <style>
                    body {
                        font-size: 20px;
                        color: #ffffff;
                        font-family: 'Arial';
                        line-height: 1.5;
                    }
                    ul, ol {
                        margin-left: 20px;
                        padding-left: 20px;
                    }
                    li {
                        margin-bottom: 8px;
                        display: list-item;
                        list-style-type: disc;
                    }
                    </style>
                    """ + n_body!
                DispatchQueue.main.async {
                    self.lblBody?.attributedText = self.n_body?.htmlAttributedString()
                }

                
            }
        }else{
            if (n_body != nil){
                n_body = n_body?
                    .replacingOccurrences(of: "<ul>", with: "")
                    .replacingOccurrences(of: "</ul>", with: "")
                    .replacingOccurrences(of: "<li>", with: "&bull; ")
                    .replacingOccurrences(of: "</li>", with: "<br>")

                n_body = """
                    <style>
                    body {
                        font-size: 20px;
                        color: #555555;
                        font-family: 'Arial';
                        line-height: 1.5;
                    }
                    ul, ol {
                        margin-left: 20px;
                        padding-left: 20px;
                    }
                    li {
                        margin-bottom: 8px;
                        display: list-item;
                        list-style-type: disc;
                    }
                    </style>
                    """ + n_body!
                DispatchQueue.main.async {
                    self.lblBody?.attributedText = self.n_body?.htmlAttributedString()
                }
            }
        }
        
        lblBody.backgroundColor = theme.backgroundColor
    }
}

