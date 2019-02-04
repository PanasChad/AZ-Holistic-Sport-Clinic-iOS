//
//  NewsCell.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 17/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import Reusable

final class NewsCell: UITableViewCell, Reusable
{
    @IBOutlet private weak var lblDate: UILabel!
    @IBOutlet private weak var lblTitle: UILabel!
    
    func fill(_ date: String , title : String) {
        lblDate.text = date
        lblTitle.text = title
    }
}
