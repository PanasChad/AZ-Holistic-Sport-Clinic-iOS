//
//  NewsTableViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 17/01/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP


final class NewsTableViewController: UITableViewController {
    var data : NSMutableArray = []
    var selected_title : String = ""
    var selected_body  : String = ""
    var selected_date  : String = ""
    
    func read_news(){
        
        
        if !Reachability.isConnectedToNetwork(){
            OperationQueue.main.addOperation {
                self.read_news_value();
                
                self.refreshControl!.endRefreshing()
            }
        
            return;
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        
        do{
            HTTP.POST(GlobalVar.URL+"news.php", parameters:parameters_arr) { response in
                //do things...
                
                
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let err = response.error {
                    /*
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.setValue(false, forKey: "launchedBefore")
                        
                        let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                        
                        UIApplication.shared.unregisterForRemoteNotifications()
                        
                        Util.deleteFile("az.sqlite")
                        
                        self.present(Login, animated: true, completion: nil)
                    }
                    */
                    
                    return //also notify app of failure as needed
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "true"){
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.setValue(false, forKey: "launchedBefore")
                        
                        let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                        
                        UIApplication.shared.unregisterForRemoteNotifications()
                        
                        Util.deleteFile("az.sqlite")
                        
                        UIApplication.shared.keyWindow?.rootViewController = Login
                    }
                    
                    return //also notify app of failure as needed
                }
                
                let readNews = ModelManager.getInstance().q("SELECT news_id FROM news WHERE news_read = 1")
                var readIds: [String] = []
                for row in readNews {
                    if let dict = row as? NSDictionary, let anyId = dict["news_id"] {
                        if let s = anyId as? String {
                            readIds.append(s)
                        } else if let n = anyId as? NSNumber {
                            readIds.append(n.stringValue)
                        } else if let i = anyId as? Int {
                            readIds.append(String(i))
                        }
                    }
                }

                let data: NSArray = json_response.value(forKey: "data") as! NSArray
                ModelManager.getInstance().deleteAll("news")
                for i in 0 ..< data.count {
                    let values: NSMutableDictionary = NSMutableDictionary()
                    let data_rec: NSDictionary = data[i] as! NSDictionary
                    
                    let newsId = data_rec.value(forKey: "news_id") as! String
                    var isRead = readIds.contains(newsId) ? 1 : 0

                    if let dateStr = data_rec.value(forKey: "news_date") as? String {
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        if let d = df.date(from: dateStr),
                           let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()),
                           d < thirtyDaysAgo {
                            isRead = 1
                        }
                    }
                    
                    values.setValue(newsId, forKey: "news_id")
                    values.setValue(data_rec.value(forKey: "news_title_en"), forKey: "news_title_en")
                    values.setValue(data_rec.value(forKey: "news_title_el"), forKey: "news_title_el")
                    values.setValue(data_rec.value(forKey: "news_text_en"), forKey: "news_text_en")
                    values.setValue(data_rec.value(forKey: "news_text_el"), forKey: "news_text_el")
                    values.setValue(data_rec.value(forKey: "news_date"), forKey: "news_date")
                    values.setValue(isRead, forKey: "news_read")

                    ModelManager.getInstance().insert("news", valuesDictionary: values)
                }
                
               OperationQueue.main.addOperation {
                    // code here
                    self.read_news_value()
                
                    self.refreshControl!.endRefreshing()
                }
                
            }
        } catch let error {
            self.refreshControl!.endRefreshing()
            
            
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            OperationQueue.main.addOperation {
                self.refreshControl!.endRefreshing()
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    func read_news_value(){
        data = ModelManager.getInstance().q("""
            SELECT news_id,
                   news_title_en,
                   news_title_el,
                   news_text_en,
                   news_text_el,
                   strftime('%d/%m/%Y',news_date) as news_date_t,
                   news_read
            FROM news
            ORDER BY news_date DESC
        """)

        self.tableView.reloadData()
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
                
        self.navigationController?.navigationBar.tintColor = UIColor().convertHexStringToColor(GlobalVar.blueColor)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.navigationBar.topItem?.title = "";
        
        self.tableView.tableFooterView = UIView()
        
        
        self.refreshControl = UIRefreshControl()
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = self.refreshControl
        } else {
            tableView.addSubview(self.refreshControl!)
        }
        
        // Configure Refresh Control
        self.refreshControl!.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.refreshControl!.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        self.read_news_value()
        
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Weather Data
        read_news()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let val : NSDictionary = data.object(at: section) as! NSDictionary
        let text: String =  (val.value(forKey: "diet_customer_time") as! String) + " - " + (val.value(forKey: "diet_customer_title_en") as! String)
        
        return text
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let message = messages[indexPath.row]
        let cell: NewsCell = tableView.dequeueReusableCell(for: indexPath)
        
        let val = data.object(at: indexPath.row) as! NSDictionary
        let title = val["news_title_" + GlobalVar.deviceLang] as! String
        let date = val["news_date_t"] as! String
        let body = val["news_text_" + GlobalVar.deviceLang] as! String
        let isRead = (val["news_read"] as? Int ?? 0) == 1

        cell.fill(date, title: title, isRead: isRead, body: body)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let oldVal = data.object(at: indexPath.row) as? NSDictionary else {
            return
        }

        // Δημιουργία μεταβλητού αντιγράφου
        let mutableVal = NSMutableDictionary(dictionary: oldVal)

        // Ανάκτηση ID
        guard let newsId = mutableVal["news_id"] as? Int else {
            return
        }

        // Ενημέρωση βάσης: μαρκάρισμα ως διαβασμένο
        ModelManager.getInstance().q("UPDATE news SET news_read = 1 WHERE news_id = \(newsId)")

        // Ενημέρωση τοπικού array
        mutableVal["news_read"] = 1
        data.replaceObject(at: indexPath.row, with: mutableVal)

        // Αναφόρτωση μόνο της γραμμής (ώστε να εξαφανιστεί η μπλε τελεία)
        tableView.reloadRows(at: [indexPath], with: .automatic)

        // Μετάβαση σε λεπτομέρειες
        selected_title = mutableVal["news_title_" + GlobalVar.deviceLang] as! String
        selected_body  = mutableVal["news_text_" + GlobalVar.deviceLang] as! String
        selected_date  = mutableVal["news_date_t"] as! String

        let NewsReadChanged = Notification.Name("newsReadChanged")

        // post
        NotificationCenter.default.post(name: NewsReadChanged, object: nil)

        performSegue(withIdentifier: "show_details", sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // initialize new view controller and cast it as your view controller
        if (segue.identifier == "show_details") {
            let viewController = segue.destination as! NewsDetails
            
            // your new view controller should have property that will store passed value
            viewController.n_body =   selected_body
            viewController.n_date =   selected_date
            viewController.n_title =   selected_title
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}
