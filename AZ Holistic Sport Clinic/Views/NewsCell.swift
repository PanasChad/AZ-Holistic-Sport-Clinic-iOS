//
//  NewsCell.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 17/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import Reusable
import SDWebImage

final class NewsCell: UITableViewCell, Reusable
{
    @IBOutlet private weak var lblDate: UILabel!
    @IBOutlet private weak var lblTitle: UILabel!
    @IBOutlet private weak var lblBodyPreview: UILabel!
    @IBOutlet weak var dotView: UIView!
    
    var n_body: String?
    func fill(_ date: String, title: String, isRead: Bool, body: String) {
        lblDate.text = formatRelativeDate(from: date)
        lblTitle.text = title

        // Prepare HTML like in NewsDetails
        n_body = body
        let style = """
        <style>
        body {
            font-size: 16px;
            color: #9c9c9d;
            font-family: 'Arial';
            line-height: 1.4;
        }
        </style>
        """
        let html = style + (n_body ?? "")
        lblBodyPreview.attributedText = html.htmlAttributedString()

        // hide dot if read
        dotView.isHidden = isRead
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        lblBodyPreview.isEditable = false
        
        dotView.layer.cornerRadius = dotView.frame.size.width / 2
        dotView.clipsToBounds = true
        lblDate.textAlignment = .right
    }

    // MARK: - Relative date formatting (Today / Yesterday / Weekday) with el/en
    private func formatRelativeDate(from dateString: String) -> String {
        guard let date = parseDate(from: dateString) else { return dateString }
        let cal = Calendar.current
        let startOfInput = cal.startOfDay(for: date)
        let startOfToday = cal.startOfDay(for: Date())
        let diff = cal.dateComponents([.day], from: startOfInput, to: startOfToday).day ?? 0

        // Language: use Greek if device language is el, otherwise English
        let isGreek = Locale.preferredLanguages.first?.hasPrefix("el") == true
        let locale = Locale(identifier: isGreek ? "el_GR" : "en_US")

        if diff == 0 {
            return isGreek ? "Σήμερα" : "Today"
        } else if diff == 1 {
            return isGreek ? "Χθες" : "Yesterday"
        } else if (2...6).contains(diff) {
            let df = DateFormatter()
            df.locale = locale
            df.dateFormat = "EEEE" // Weekday name
            return df.string(from: date)
        } else {
            // Fallback full date
            let df = DateFormatter()
            df.locale = locale
            df.dateFormat = "dd/MM/yyyy"
            return df.string(from: date)
        }
    }

    private func parseDate(from s: String) -> Date? {
        // Try common formats you may receive from backend/DB
        let fmts = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd",
            "dd/MM/yyyy HH:mm",
            "dd/MM/yyyy"
        ]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for f in fmts {
            df.dateFormat = f
            if let d = df.date(from: s) { return d }
        }
        return nil
    }

}
