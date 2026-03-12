//
//  DietViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 12/12/2018.
//  Copyright © 2018 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwipeMenuViewController
import ANLoader

class DietViewController: SwipeMenuViewController {
    
    private var dates: [String] = [NSLocalizedString("Monday",comment:"Monday"),NSLocalizedString("Tuesday",comment:"Tuesday"),NSLocalizedString("Wednesday",comment:"Wednesday"),NSLocalizedString("Thursday",comment:"Thursday"),NSLocalizedString("Friday",comment:"Friday"),NSLocalizedString("Saturday",comment:"Saturday"),NSLocalizedString("Sunday",comment:"Sunday")]
    
    var options = SwipeMenuViewOptions()
    var pdfButton: UIBarButtonItem!
    
    var pdfURL: URL!
    let pdfViewController = PDFViewController()
    
    func read_diet(){
        
        if !Reachability.isConnectedToNetwork(){
            self.load_tabs()
            
            var day = Calendar.current.component(.weekday, from: Date())
            day = day - 2
            
            if (day < 0){
                day = 6
            }
            
            DispatchQueue.main.async {
                // code here
                self.reload(date:day)
            }
            
            return;
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        
        do{
            HTTP.POST(GlobalVar.URL+"diet.php", parameters:parameters_arr) { response in
                //do things...
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let err = response.error {
                    Swift.debugPrint("Error: \(err.localizedDescription)")
                    
                    //Logout function
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
                    //Logout function
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.setValue(false, forKey: "launchedBefore")
                        
                        let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                        
                        UIApplication.shared.unregisterForRemoteNotifications()
                        
                        Util.deleteFile("az.sqlite")
                        
                        UIApplication.shared.keyWindow?.rootViewController = Login
                        
                    }
                    
                    return //also notify app of failure as needed
                }
                
                
                
                ModelManager.getInstance().deleteAll("diet_customer")
                
                //Getting the JSON array teams from the response
                let data: NSArray = json_response.value(forKey: "data") as! NSArray
                
                //looping through all the json objects in the array teams
                for i in 0 ..< data.count{
                    let values : NSMutableDictionary = NSMutableDictionary()
                    let data_rec : NSDictionary = data[i] as! NSDictionary
                    
                    values.setValue(data_rec.value(forKey: "diet_customer_time"), forKey: "diet_customer_time")
                    values.setValue(data_rec.value(forKey: "diet_customer_title_en"), forKey: "diet_customer_title_en")
                    values.setValue(data_rec.value(forKey: "diet_customer_title_el"), forKey: "diet_customer_title_el")
                    values.setValue(data_rec.value(forKey: "diet_customer_monday_text"), forKey: "diet_customer_monday_text")
                    values.setValue(data_rec.value(forKey: "diet_customer_monday_calories"), forKey: "diet_customer_monday_calories")
                    values.setValue(data_rec.value(forKey: "diet_customer_tuesday_text"), forKey: "diet_customer_tuesday_text")
                    values.setValue(data_rec.value(forKey: "diet_customer_tuesday_calories"), forKey: "diet_customer_tuesday_calories")
                    values.setValue(data_rec.value(forKey: "diet_customer_wednesday_text"), forKey: "diet_customer_wednesday_text")
                    values.setValue(data_rec.value(forKey: "diet_customer_wednesday_calories"), forKey: "diet_customer_wednesday_calories")
                    values.setValue(data_rec.value(forKey: "diet_customer_thirsday_text"), forKey: "diet_customer_thirsday_text")
                    values.setValue(data_rec.value(forKey: "diet_customer_thirsday_calories"), forKey: "diet_customer_thirsday_calories")
                    values.setValue(data_rec.value(forKey: "diet_customer_friday_text"), forKey: "diet_customer_friday_text")
                    values.setValue(data_rec.value(forKey: "diet_customer_friday_calories"), forKey: "diet_customer_friday_calories")
                    values.setValue(data_rec.value(forKey: "diet_customer_saturday_text"), forKey: "diet_customer_saturday_text")
                    values.setValue(data_rec.value(forKey: "diet_customer_saturday_calories"), forKey: "diet_customer_saturday_calories")
                    values.setValue(data_rec.value(forKey: "diet_customer_sunday_text"), forKey: "diet_customer_sunday_text")
                    values.setValue(data_rec.value(forKey: "diet_customer_sunday_calories"), forKey: "diet_customer_sunday_calories")
                    values.setValue(data_rec.value(forKey: "diet_customer_note"), forKey: "diet_customer_note")
                    values.setValue(data_rec.value(forKey: "diet_customer_target"), forKey: "diet_customer_target")
                    values.setValue(data_rec.value(forKey: "diet_customer_supplements"), forKey: "diet_customer_supplements")
                    
                    
                    ModelManager.getInstance().insert("diet_customer", valuesDictionary: values)
                }
            
                self.load_tabs()
                
                var day = Calendar.current.component(.weekday, from: Date())
                day = day - 2
                
                if (day < 0){
                    day = 6
                }
                
                 DispatchQueue.main.async {
                    // code here
                    self.reload(date:day)
                }
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            OperationQueue.main.addOperation {
                
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    func load_tabs(){
        dates.forEach { date in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            DispatchQueue.main.async {
                let vc = storyboard.instantiateViewController(withIdentifier: "DietTableViewController") as! DietTableViewController
                
                vc.date = date
                vc.title = date
                
                self.addChild(vc)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTheming()

        swipeMenuView.dataSource = self
        swipeMenuView.delegate = self

        self.pdfButton = UIBarButtonItem(image: UIImage(named: "diet_pdf"), style: UIBarButtonItem.Style.done, target: self, action: #selector(showPDF))
        self.pdfButton.isEnabled = true

        let button = UIBarButtonItem(image: UIImage(named: "note"), style: UIBarButtonItem.Style.done, target: self, action: #selector(showNotes))

        navigationItem.leftBarButtonItem = button
        navigationItem.rightBarButtonItem = self.pdfButton

        read_diet()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTabBarAppearance()
    }
    func updateTabBarAppearance() {
        if #available(iOS 26.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()

            if traitCollection.userInterfaceStyle == .dark {
                appearance.backgroundColor = .black
                appearance.shadowImage = nil
                appearance.shadowColor = nil

                if let tabBar = self.tabBarController?.tabBar {
                    tabBar.standardAppearance = appearance
                    tabBar.scrollEdgeAppearance = appearance
                    tabBar.isTranslucent = false
                }
            }
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            // reapply tab bar appearance
            updateTabBarAppearance()
        }
    }
    @objc func showPDF(){
        self.pdfButton.isEnabled = false
        
        if !Reachability.isConnectedToNetwork(){
            let alert = UIAlertController(title: NSLocalizedString("alert",comment: "alert"), message: NSLocalizedString("NOINTERNETCONNECTION",comment: "NOINTERNETCONNECTION"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: "OK"), style: .default, handler: { action in }))
            
            self.present(alert, animated: true, completion: nil)
            
            self.pdfButton.isEnabled = true
            
            return;
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ANLoader.showLoading("", disableUI: true)
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        
        do{
            HTTP.POST(GlobalVar.URL+"diet_check_pdf.php", parameters:parameters_arr) { response in
                //do things...
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    ANLoader.hide()
                }
                
                if let err = response.error {
                    Swift.debugPrint("Error: \(err.localizedDescription)")
                    
                    return //also notify app of failure as needed
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "true"){
                    //Logout function
                    OperationQueue.main.addOperation {
                        UserDefaults.standard.setValue(false, forKey: "launchedBefore")
                        
                        let Login = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                        
                        UIApplication.shared.unregisterForRemoteNotifications()
                        
                        Util.deleteFile("az.sqlite")
                        
                        UIApplication.shared.keyWindow?.rootViewController = Login
                        
                    }
                    
                    return //also notify app of failure as needed
                }
                                
                //Getting the JSON array teams from the response
                let data: NSDictionary = json_response.value(forKey: "data") as! NSDictionary
                
                if(data.value(forKey: "exists") as! String == "true"){
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        ANLoader.showLoading("", disableUI: true)
                    }
                    
                    guard let url = URL(string: data.value(forKey: "url") as! String) else { return }
                    
                    let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
                    
                    let downloadTask = urlSession.downloadTask(with: url)
                    
                    downloadTask.resume()
                }else{
                    DispatchQueue.main.async {
                        
                    let alert = UIAlertController(title: NSLocalizedString("alert", comment: "alert"), message: NSLocalizedString("no_measures_pdf_found", comment: "no_measures_pdf_found"),preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { action in
                          switch action.style{
                          case .default:
                                print("default")

                          case .cancel:
                                print("cancel")

                          case .destructive:
                                print("destructive")
                    }}))
                        
                    self.present(alert, animated: true, completion: nil)
                        
                    }
                }
                
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    self.pdfButton.isEnabled = true
                }
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            OperationQueue.main.addOperation {
                
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
        
    }
    
    @objc func showNotes(){
        performSegue(withIdentifier: "showDietNote", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    private func reload( date: Int) {
        swipeMenuView.reloadData(options: options, default: date, isOrientationChange: false)
    }
    
    // MARK: - SwipeMenuViewDelegate
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewWillSetupAt: currentIndex)
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewDidSetupAt: currentIndex)
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, willChangeIndexFrom: fromIndex, to: toIndex)
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, didChangeIndexFrom: fromIndex, to: toIndex)
    }

    // MARK - SwipeMenuViewDataSource
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return children.count
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return children[index].title ?? ""
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = children[index]
        
        vc.didMove(toParent: self)
        
        return vc
    }
}

extension DietViewController:  URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        
        DispatchQueue.main.async { // Make sure you're on the main thread here
            ANLoader.hide()
        }
        
        self.pdfViewController.pdfTemporaryLocation = location
        // create destination URL with the original pdf name
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            self.pdfURL = destinationURL
            
            self.pdfViewController.pdfURL = self.pdfURL
            DispatchQueue.main.async { // Make sure you're on the main thread here
                self.present(self.pdfViewController, animated: false, completion: nil)
            }
            
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()

            if let tabBar = self.tabBarController?.tabBar {
                tabBar.standardAppearance = appearance
                tabBar.scrollEdgeAppearance = appearance
                tabBar.isTranslucent = true
            }
        }
    }
}

extension DietViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        options.tabView.backgroundColor = theme.backgroundColor
        options.tabView.itemView.selectedTextColor = theme.textBlueColor
        options.tabView.additionView.backgroundColor = theme.textBlueColor
    }
}


