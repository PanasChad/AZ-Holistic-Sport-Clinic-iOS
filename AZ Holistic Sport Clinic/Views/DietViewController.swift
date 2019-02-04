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

class DietViewController: SwipeMenuViewController {
    
    private var dates: [String] = ["Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var options = SwipeMenuViewOptions()
    
    
    func read_diet(){
        
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
                    OperationQueue.main.addOperation {
                        
                    }
                    
                    return //also notify app of failure as needed
                }
                
                let json_response : NSDictionary = Util.nsdataToJSON(response.text!.data(using: String.Encoding.utf8)!)!
                
                if (json_response.value(forKey: "error") as! String == "true"){
                    //Logout function
                    OperationQueue.main.addOperation {
                        
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
                day = day - 1
                
                if (day == -1){
                    day = 6
                }
                
                 DispatchQueue.main.async {
                    // code here
                    self.reload()
                    
                    self.swipeMenuView.jump(to: day, animated: true)
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
            
            let vc = storyboard.instantiateViewController(withIdentifier: "DietTableViewController") as! DietTableViewController
            
            vc.date = date
            vc.title = date
            
            self.addChild(vc)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeMenuView.dataSource = self
        swipeMenuView.delegate = self
        
        options.tabView.itemView.selectedTextColor = UIColor().convertHexStringToColor(GlobalVar.blueColor)
        options.tabView.additionView.backgroundColor = UIColor().convertHexStringToColor(GlobalVar.blueColor)
        
        read_diet()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    private func reload() {
        swipeMenuView.reloadData(options: options)
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
