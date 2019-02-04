//
//  MeasuresViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 12/12/2018.
//  Copyright © 2018 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import ScrollableGraphView

class MeasuresViewController: UIViewController,ScrollableGraphViewDataSource {
    var lineSeletectIndex: NSInteger = 0
    var linePlotLabels: [String] = ["customer_lipometry_baros","customer_lipometry_lipodis_maza","customer_lipometry_myiki_maza","customer_lipometry_lipos"]
    var linePlotArray: NSMutableArray!
    
    var graphView : ScrollableGraphView!
    
    @IBOutlet weak var SegControls: UISegmentedControl!
    
    @IBAction func change_tab(_ sender: UISegmentedControl) {
        lineSeletectIndex = sender.selectedSegmentIndex
        
        graphView.reload()
    }
    
    func read_measures_value(){
        linePlotArray = ModelManager.getInstance().q("SELECT customer_lipometry_datetime,customer_lipometry_baros,customer_lipometry_lipos,customer_lipometry_myiki_maza,customer_lipometry_splaxniko_lipos,customer_lipometry_lipodis_maza FROM customer_lipometry ORDER BY customer_lipometry_id")
        
        graphView.reload()
        
        graphView.updateConstraints()
    }
    
    func read_measures(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var parameters_arr: [String:AnyObject] = [:]
        
        parameters_arr["username"] =  GlobalVar.deviceUsername as AnyObject
        parameters_arr["password"] = GlobalVar.devicePassword as AnyObject
        
        do{
            HTTP.POST(GlobalVar.URL+"measures.php", parameters:parameters_arr) { response in
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
                
                ModelManager.getInstance().deleteAll("customer_lipometry")
                
                //Getting the JSON array teams from the response
                let data: NSArray = json_response.value(forKey: "data") as! NSArray
                
                //looping through all the json objects in the array teams
                for i in 0 ..< data.count{
                    let values : NSMutableDictionary = NSMutableDictionary()
                    let data_rec : NSDictionary = data[i] as! NSDictionary
                    
                    values.setValue(data_rec.value(forKey: "customer_lipometry_id"), forKey: "customer_lipometry_id")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_datetime"), forKey: "customer_lipometry_datetime")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_baros"), forKey: "customer_lipometry_baros")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_lipos"), forKey: "customer_lipometry_lipos")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_lipodis_maza"), forKey: "customer_lipometry_lipodis_maza")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_myiki_maza"), forKey: "customer_lipometry_myiki_maza")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_bmi"), forKey: "customer_lipometry_bmi")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_metabolic_age"), forKey: "customer_lipometry_metabolic_age")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_bmr"), forKey: "customer_lipometry_bmr")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_ipsos"), forKey: "customer_lipometry_ipsos")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_splaxniko_lipos"), forKey: "customer_lipometry_splaxniko_lipos")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_tbw"), forKey: "customer_lipometry_tbw")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_full"), forKey: "customer_lipometry_full")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_waist_size"), forKey: "customer_lipometry_waist_size")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_buttocks_size"), forKey: "customer_lipometry_buttocks_size")
                    values.setValue(data_rec.value(forKey: "customer_lipometry_perimetros_laimou"), forKey: "customer_lipometry_perimetros_laimou")
                    
                    
                    ModelManager.getInstance().insert("customer_lipometry", valuesDictionary: values)
                    
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
                OperationQueue.main.addOperation {
                    self.read_measures_value()
                }
                
            }
        } catch let error {
            Swift.debugPrint("Got an error creating the request: \(error)")
            
            OperationQueue.main.addOperation {
                
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        //Swift.debugPrint(plot.identifier)
        let arr = linePlotArray.object(at: pointIndex) as! NSDictionary
        let val:String = linePlotLabels[lineSeletectIndex]
        
        // Return the data for each plot.
        switch(plot.identifier) {
        case "multiBlue":
            return arr.value(forKey:val) as! Double
        case "multiBlueDot":
            return arr.value(forKey:val) as! Double
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        let arr = linePlotArray.object(at: pointIndex) as! NSDictionary
        
        return arr.value(forKey: "customer_lipometry_datetime") as! String
    }
    
    func numberOfPoints() -> Int {
        if (linePlotArray == nil){
            return 0
        }
        
        return linePlotArray.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let screenRect = self.view.bounds
        
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        let frame = CGRect(x: 0, y: 120, width: screenWidth, height: screenHeight - 170)
        
        graphView = ScrollableGraphView(frame: frame, dataSource: self )
        graphView.dataSource = self
        
        // Setup the first plot.
        let blueLinePlot = LinePlot(identifier: "multiBlue")
        
        blueLinePlot.lineColor = UIColor.colorFromHex("#16aafc")
        blueLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        blueLinePlot.shouldFill = true
        blueLinePlot.fillType = ScrollableGraphViewFillType.gradient
        blueLinePlot.fillGradientType = ScrollableGraphViewGradientType.linear
        blueLinePlot.fillGradientStartColor = UIColor.colorFromHex("#555555")
        blueLinePlot.fillGradientEndColor = UIColor.colorFromHex("#444444")
        blueLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        // dots on the line
        let blueDotPlot = DotPlot(identifier: "multiBlueDot")
        blueDotPlot.dataPointType = ScrollableGraphViewDataPointType.circle
        blueDotPlot.dataPointSize = 5
        blueDotPlot.dataPointFillColor = UIColor.colorFromHex("#16aafc")
        
        blueDotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
    
        // Setup the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.relativePositions = [0, 0.2, 0.4, 0.6, 0.8, 1]
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        // Setup the graph
        graphView.backgroundFillColor = UIColor.colorFromHex("#333333")
        
        graphView.dataPointSpacing = 80
        graphView.sizeToFit()
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = false
        graphView.shouldRangeAlwaysStartAtZero = false
        graphView.shouldAnimateOnAdapt = true
        graphView.direction = ScrollableGraphViewDirection.rightToLeft
        graphView.shouldAnimateOnAdapt = true
        
        graphView.showsVerticalScrollIndicator = true
        graphView.showsHorizontalScrollIndicator = true
        
        // Add everything to the graph.
        graphView.addReferenceLines(referenceLines: referenceLines)
        graphView.addPlot(plot: blueLinePlot)
        graphView.addPlot(plot: blueDotPlot)
        
        //graphView.rangeMax = 10
        graphView.rangeMin = 0
        
        self.view.addSubview(graphView)
        
        read_measures()
        
    }

}
