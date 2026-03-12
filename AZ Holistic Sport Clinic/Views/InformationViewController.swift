//
//  ContactViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 14/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP

class InformationViewController: UITableViewController {
    @IBOutlet weak var img_1 : UIImageView!
    @IBOutlet weak var img_2 : UIImageView!
    @IBOutlet weak var img_3 : UIImageView!
    @IBOutlet weak var img_4 : UIImageView!
    @IBOutlet weak var img_5 : UIImageView!
    @IBOutlet weak var img_6 : UIImageView!
    @IBOutlet weak var img_7 : UIImageView!
    @IBOutlet weak var img_8 : UIImageView!
    @IBOutlet weak var img_9 : UIImageView!
    @IBOutlet weak var img_10 : UIImageView!
    @IBOutlet weak var img_11 : UIImageView!
    @IBOutlet weak var img_12 : UIImageView!
    @IBOutlet weak var img_13 : UIImageView!
    @IBOutlet weak var img_14 : UIImageView!
    @IBOutlet weak var img_15 : UIImageView!
    
    public var show_news : Bool!
    public var show_questionnaire : Bool!
    
    public var irthaapobell : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        irthaapobell = false
        show_news = false
        show_questionnaire = false
        let NewsReadChanged = Notification.Name("newsReadChanged")

        // observe
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onNewsReadChanged),
                                               name: NewsReadChanged,
                                               object: nil)

    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func onNewsReadChanged() {
        // Reload just the first cell (News/Notifications)
        let idx = IndexPath(row: 0, section: 0)
        if let visible = tableView.cellForRow(at: idx) {
            configureBadge(for: visible) // update in place if visible
        }
        // Also safe to ask table to reload that row (handles offscreen case)
        tableView.reloadRows(at: [idx], with: .none)
    }
    private func configureBadge(for cell: UITableViewCell) {
        // remove any previous badge
        cell.contentView.viewWithTag(999)?.removeFromSuperview()

        let count = unreadCount()
        guard count > 0 else {
            tabBarController?.tabBar.removeDot(at: 3)
            return
        }

        let badgeLabel = UILabel()
        badgeLabel.tag = 999
        badgeLabel.text = "\(count)"
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.textAlignment = .center
        badgeLabel.font = .systemFont(ofSize: 15, weight: .bold)
        badgeLabel.layer.cornerRadius = 15
        badgeLabel.clipsToBounds = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            badgeLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            badgeLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    private func unreadCount() -> Int {
        let result = ModelManager.getInstance().line("SELECT COUNT(*) AS total FROM news WHERE news_read = 0")
        return (result["total"] as? Int) ?? 0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 3{
            var url_s: String!
            
            url_s = "https://fitlb.com/tabata-timer"
             
            if let url = URL(string: url_s) {
                UIApplication.shared.open(url)
            }
        }else if indexPath.section == 0 && indexPath.row == 4{
            var url_s: String!
            
            url_s = "https://thermidometritis.gr"
             
            if let url = URL(string: url_s) {
                UIApplication.shared.open(url)
            }
        }else if indexPath.section == 0 && indexPath.row == 13 {
            var url_s: String!
            if (GlobalVar.deviceLang == "en"){
                url_s = "https://andreaszachariou.com/en/terms-and-rules/"
            }else{
                url_s = "https://andreaszachariou.com/el/oroi-kai-kanones/"
            }
             
            if let url = URL(string: url_s) {
                UIApplication.shared.open(url)
            }
        }else if indexPath.section == 0 && indexPath.row == 12 {
            var url_s: String!
            if (GlobalVar.deviceLang == "en"){
                url_s = "https://andreaszachariou.com/en/measurements-rules/"
            }else{
                url_s = "https://andreaszachariou.com/el/kanones-metriseon/"
            }
             
            if let url = URL(string: url_s) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                self.themeProvider.currentTheme = .dark
            }else{
                self.themeProvider.currentTheme = .light
            }
        }
        print(irthaapobell)
        if irthaapobell != nil && irthaapobell == true {
            self.performSegue(withIdentifier: "show_news", sender: nil)
            irthaapobell = false
        }
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("INFORMATION", comment: "")
        self.navigationItem.title = NSLocalizedString("INFORMATION", comment: "")
        
        applyTheme(themeProvider.currentTheme)
        onNewsReadChanged()
    }
    
    func showNews(){
        self.performSegue(withIdentifier: "show_news", sender: nil)
    }
    
    func showQuestionnaire(){
        self.performSegue(withIdentifier: "show_questionaire", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                self.themeProvider.currentTheme = .dark
            }else{
                self.themeProvider.currentTheme = .light
            }
        }
        
        if (show_questionnaire){
            self.performSegue(withIdentifier: "show_questionaire", sender: nil)
        }else if (show_news){
            self.performSegue(withIdentifier: "show_news", sender: nil)
        }
        
        setUpTheming()
        
        show_news = false
        show_questionnaire = false
        
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("INFORMATION", comment: "")
        self.navigationItem.title = NSLocalizedString("INFORMATION", comment: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_texts_gdpr" {
            if let destinationVC = segue.destination as? Texts {
                destinationVC.n_type = 1
            }
        }else if segue.identifier == "show_texts_payments" {
            if let destinationVC = segue.destination as? Texts {
                destinationVC.n_type = 2
            }
        }else if segue.identifier == "show_texts_diet" {
            if let destinationVC = segue.destination as? Texts {
                destinationVC.n_type = 3
            }
        }else if segue.identifier == "show_exercise_guide" {
            if let destinationVC = segue.destination as? Texts {
                destinationVC.n_type = 4
            }
        }else if segue.identifier == "show_timetable" {
            if let destinationVC = segue.destination as? Texts {
                destinationVC.n_type = 4
            }
        }else if segue.identifier == "show_trainers" {
            if let destinationVC = segue.destination as? Texts {
                destinationVC.n_type = 5
            }
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "show_questionaire")
        {
            let values:NSDictionary =  ModelManager.getInstance().line("SELECT * FROM customer")
            
            if (values.value(forKey: "customer_questionnaire_already_answer") as! String == "true" || values.value(forKey: "customer_questionnaire_exists") as! String == "false"){
                
                let alert = UIAlertController(title: NSLocalizedString("alert",comment: "Alert"), message: NSLocalizedString("ALREADYANSWER",comment: "Alert"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                        
                    }}))
                
                self.present(alert, animated: true, completion: nil)
                
                return false
            }
        }
        
        return true
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        if indexPath.section == 0 && indexPath.row == 0 {
            configureBadge(for: cell)
        }
    }

}

extension InformationViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        //titleLabel.textColor = theme.textColor
        //subtitleLabel.textColor = theme.textColor
        
        img_1.tintColor = theme.textColor
        img_2.tintColor = theme.textColor
        img_3.tintColor = theme.textColor
        img_4.tintColor = theme.textColor
        img_5.tintColor = theme.textColor
        img_6.tintColor = theme.textColor
        img_7.tintColor = theme.textColor
        img_8.tintColor = theme.textColor
        img_9.tintColor = theme.textColor
        img_10.tintColor = theme.textColor
        img_11.tintColor = theme.textColor
        img_12.tintColor = theme.textColor
        img_13.tintColor = theme.textColor
        img_14.tintColor = theme.textColor
        img_15.tintColor = theme.textColor
    }
}
extension UITabBar {
    func addDot(at index: Int, color: UIColor = .red, size: CGFloat = 12) {
        let tag = 999 + index
        if self.viewWithTag(tag) != nil { return }

        let itemCount = CGFloat(items?.count ?? 1)
        let itemWidth = frame.width / itemCount
        var x = itemWidth * CGFloat(index + 1) - itemWidth / 2 + 10
        var y: CGFloat = 3
        if #available (iOS 26.0, *){
            x = itemWidth * CGFloat(index + 1) - itemWidth / 2 - 3
            y = 5
        }

        let dot = UIView(frame: CGRect(x: x, y: y, width: size, height: size))
        dot.tag = tag
        dot.backgroundColor = color
        dot.layer.cornerRadius = size / 2
        addSubview(dot)
    }

    func removeDot(at index: Int) {
        let tag = 999 + index
        viewWithTag(tag)?.removeFromSuperview()
    }
}
