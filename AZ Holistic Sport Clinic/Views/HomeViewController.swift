//
//  HomeViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 11/12/2018.
//  Copyright © 2018 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import RSBarcodes_Swift
import AVFoundation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var imgBarcode: UIImageView!
    @IBOutlet weak var lblEndSubscription: UILabel!
    @IBOutlet weak var lblAmountRemains: UILabel!
    @IBOutlet weak var lblNextAppointment: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM customer")
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : UIColor().convertHexStringToColor(GlobalVar.blueColor)]
        
        imgBarcode.image = RSCode128Generator(codeTable: .a).generateCode(values.value(forKey: "customer_code") as! String, machineReadableCodeObjectType: AVMetadataObject.ObjectType.code128.rawValue)
        
        lblEndSubscription.text = values.value(forKey: "customer_end_of_subscription") as? String
        lblAmountRemains.text = values.value(forKey: "customer_remaining_amount") as? String
        lblNextAppointment.text = values.value(forKey: "customer_next_appointment") as? String
        
        GlobalVar.deviceID = values.value(forKey: "customer_id") as? String
        GlobalVar.deviceUsername = values.value(forKey: "customer_code") as? String
        GlobalVar.devicePassword = values.value(forKey: "customer_password") as? String
        
        self.navigationItem.title = values.value(forKey: "customer_fullname") as? String
    }
    
}
