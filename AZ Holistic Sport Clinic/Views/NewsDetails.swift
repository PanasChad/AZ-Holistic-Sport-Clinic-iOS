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
        
        lblTitle?.text = n_title
        self.navigationItem.title = n_date
        
        // Initial theme application in case applyTheme was called before outlets were ready
        if let theme = AppThemeProvider.shared.currentTheme as? AppTheme {
            applyTheme(theme)
        }
    }
}

extension NewsDetails: Themed {
    func applyTheme(_ theme: AppTheme) {
        guard isViewLoaded else { return }
        
        view.backgroundColor = theme.backgroundColor
        lblTitle.textColor = theme.textColor
        lblBody.textColor = theme.textColor
        lblBody.backgroundColor = theme.backgroundColor
        lblTitle.backgroundColor = theme.backgroundColor

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
            lblBody?.attributedText = styledBody.htmlAttributedString()
        }

        lblTitle.numberOfLines = 2
        lblTitle.lineBreakMode = .byTruncatingTail
        lblTitle.adjustsFontSizeToFitWidth = true
        lblTitle.minimumScaleFactor = 0.5
    }
}
