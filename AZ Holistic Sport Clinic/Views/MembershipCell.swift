//
//  MembershipCell.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 30/10/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import Reusable

final class MembershipCell: UITableViewCell, Reusable
{
    
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var lblDetails: UILabel!
    
    @IBOutlet private weak var imgLogo: UIImageView!
    @IBOutlet private weak var viewDisable: UIView!
    @IBOutlet private weak var lblDisable: UILabel!
    
    func fill(_ title: String , details : String, imgPath: String, disable:Bool) {
        
        lblTitle.text = title
        lblDetails.text = details
        
        imgLogo.sd_setImage(with: URL(string: imgPath), placeholderImage: UIImage(named: "no_image.png"))
        
        viewDisable.isHidden = !disable
        lblDisable.isHidden = !disable

    }
}

