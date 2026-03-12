//
//  NewsDetails.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 29/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit

class NewsDetails: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblBody: UITextView!
    
    var n_title : String?
    var n_date : String?
    var n_body : String?
    
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
        
        lblTitle?.text =   n_title
        //lblDate?.text =    n_date
        //lblDate?.text =    ""
        
        //let myAttribute = [ NSFontAttributeName: UIFont.systemFont(ofSize: 12) ]
        //let myAttrString = NSAttributedString(string: answer!, attributes: myAttribute)
        n_body = "<style>body{font-size:20px; color:#555555; font-family: 'Arial';}</style>" + n_body!
        
        lblBody?.attributedText = n_body?.htmlAttributedString()
        
        self.navigationItem.title = n_date
    }
    
}

extension NewsDetails: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        
        //titleLabel.textColor = theme.textColor
        //subtitleLabel.textColor = theme.textColor
        lblTitle.textColor = theme.textColor
        //lblDate.textColor = theme.textColor
        lblBody.textColor = theme.textColor
        
        if theme.textColor == .white {
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

        } else {
            n_body = """
            <style>
            body {
                font-size: 20px;
                color: #555555;
                font-family: 'Arial';
                line-height: 1.4;
            }
            </style>
            """ + n_body!
            lblBody?.attributedText = n_body?.htmlAttributedString()

        }

        
        lblTitle.backgroundColor = theme.backgroundColor
        //lblDate.backgroundColor = theme.backgroundColor
        lblBody.backgroundColor = theme.backgroundColor
        
        lblTitle.numberOfLines = 2
        lblTitle.lineBreakMode = .byTruncatingTail // or .byWordWrapping if you prefer wrapping
        lblTitle.adjustsFontSizeToFitWidth = true
        lblTitle.minimumScaleFactor = 0.5
    }
}
