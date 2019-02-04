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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblTitle?.text =   n_title
        lblDate?.text =    n_date
        
        //let myAttribute = [ NSFontAttributeName: UIFont.systemFont(ofSize: 12) ]
        //let myAttrString = NSAttributedString(string: answer!, attributes: myAttribute)
        n_body = "<style>body{font-size:16px; color:#555555; font-family: '"+UIFont.systemFont(ofSize: 16).familyName+"';}</style>" + n_body!
        
        lblBody?.attributedText = n_body?.htmlAttributedString()
        
        self.navigationItem.title = n_date
    }
    
}
