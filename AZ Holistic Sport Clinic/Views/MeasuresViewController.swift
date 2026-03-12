//
//  MeasuresViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 17/04/2019.
//  Copyright © 2019 Manolis Georgiou. All rights reserved.
//

import UIKit
import SwiftHTTP
import Charts
import ANLoader

@available(iOS 11.0, *)
class MeasuresViewController: ChartBaseViewController {
    var linePlotLabels: [String] = ["customer_lipometry_baros","customer_lipometry_lipos","customer_lipometry_myiki_maza","customer_lipometry_splaxniko_lipos"]
    
    
    var linePlotArray_1: NSMutableArray!
    var linePlotArray_2: NSMutableArray!
    var linePlotArray_3: NSMutableArray!
    var linePlotArray_4: NSMutableArray!
    
    var pdfButton: UIBarButtonItem!
    
    var weekPlotArray: NSDictionary!
    
    var pdfURL: URL!
    let pdfViewController = PDFViewController()
    
    static var readData : Bool = true
    
    var set1 : LineChartDataSet!
    var set2 : LineChartDataSet!
    var set3 : LineChartDataSet!
    var set4 : BarChartDataSet!
    var set5 : BarChartDataSet!
    
    var showBool : Bool = true
    
    @IBOutlet weak var SegControls: UISegmentedControl!
    @IBOutlet weak var chartView_1: LineChartView!
    @IBOutlet weak var chartView_2: LineChartView!
    @IBOutlet weak var chartView_3: LineChartView!
    @IBOutlet weak var chartView_4: BarChartView!
    @IBOutlet weak var chartView_5: BarChartView!
    
    func setDataBarChartWeek(_ lineSelectedIndex:Int, zoomIn:Bool, chartView:inout BarChartView, setT:inout BarChartDataSet) {
        let values = (1..<6).map { (i) -> BarChartDataEntry in
            let string_name : String = "week_name_" + String(6-i)
            let string_val : String = "week_value_" + String(6-i)
            
            let chart_v = BarChartDataEntry(x: (Double(Int(i))), y: weekPlotArray.value(forKey: string_val) as! Double);
            
            chart_v.data = weekPlotArray.value(forKey: string_name)
            
            
            return chart_v
        }
        
        let leftAxis = chartView.leftAxis
        
        leftAxis.axisMaximum = 7
        leftAxis.axisMinimum = 0
        
        
        chartView.xAxis.valueFormatter = IntAxisValueFormatter()
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        chartView.xAxis.spaceMin = 0.8
        
        setT = BarChartDataSet(entries: values, label: "")
        
        setT.drawIconsEnabled = false
        
        setT.setColor(UIColor.colorFromHex("#e67e22"))
        setT.valueFont = .boldSystemFont(ofSize: 12)
        setT.formLineDashLengths = [5, 2.5]
        setT.formLineWidth = 1
        setT.formSize = 15
        setT.valueTextColor = self.themeProvider.currentTheme.textBlueColor
        
        
        setT.notifyDataSetChanged()
        
        let data = BarChartData(dataSet: setT)
        
        data.setValueFormatter(LargeValueFormatter())
        chartView.data = data
        
        // Ensure label generation matches our simple 1...N x values
        chartView.xAxis.centerAxisLabelsEnabled = false
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1
        
        chartView.setNeedsDisplay()
    }
    
    func setDataBarChartCount(_ lineSelectedIndex:Int, zoomIn:Bool, chartView:inout BarChartView, setT:inout BarChartDataSet) {
        var max_value : Int = 0;
        var linePlotArray: NSMutableArray!
        
        switch lineSelectedIndex {
        case 0:
            linePlotArray = linePlotArray_1
            break
        case 1:
            linePlotArray = linePlotArray_2
            break
        case 2:
            linePlotArray = linePlotArray_3
            break
        case 3:
            linePlotArray = linePlotArray_4
            break
        default:
            break
        }
        
        let values = (0..<linePlotArray.count).map { (i) -> BarChartDataEntry in
            let val : NSDictionary = linePlotArray.object(at: i) as! NSDictionary
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "dd/MM/yyyy"
            
            let date : Date = dateFormatterGet.date(from:val.value(forKey: "customer_lipometry_datetime") as! String)!
            
            if (val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Int > max_value){
                max_value = val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Int;
            }
            
            let chart_v = BarChartDataEntry(x: (Double(i+1)), y: val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Double);
            
            chart_v.data = dateFormatterGet.string(from: date)
            
            //return ChartDataEntry(x: Double(NSNumber(value: date.timeIntervalSince1970)), y: val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Double);
            
            return chart_v
        }
        
        let leftAxis = chartView.leftAxis
        
        leftAxis.axisMaximum = Double(max_value + 5)
        leftAxis.axisMinimum = 0
        
        
        setT = BarChartDataSet(entries: values, label: "")
        
        setT.drawIconsEnabled = false
        
        setT.setColor(UIColor.colorFromHex("#FFC926"))
        setT.valueFont = .boldSystemFont(ofSize: 12)
        setT.formLineDashLengths = [5, 2.5]
        setT.formLineWidth = 1
        setT.formSize = 15
        setT.valueTextColor = self.themeProvider.currentTheme.textBlueColor
        
        
        setT.notifyDataSetChanged()
        
        let data = BarChartData(dataSet: setT)
        
        data.setValueFormatter(LargeValueFormatter())
        chartView.data = data
        
        if (zoomIn){
            chartView.zoom(scaleX: 4, scaleY: 0, x: 10000, y: 0)
        }
        
        // Ensure label generation matches our simple 1...N x values
        chartView.xAxis.centerAxisLabelsEnabled = false
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1
        
        chartView.setNeedsDisplay()
    }
    
    func setDataCount(_ lineSelectedIndex:Int, zoomIn:Bool, chartView:inout LineChartView, setT:inout LineChartDataSet) {
        var max_value : Double = 0;
        var linePlotArray: NSMutableArray!
        
        switch lineSelectedIndex {
        case 0:
            linePlotArray = linePlotArray_1
            break
        case 1:
            linePlotArray = linePlotArray_2
            break
        case 2:
            linePlotArray = linePlotArray_3
            break
        case 3:
            linePlotArray = linePlotArray_4
            break
        default:
            break
        }
        
        let values = (0..<linePlotArray.count).map { (i) -> ChartDataEntry in
            let val : NSDictionary = linePlotArray.object(at: i) as! NSDictionary
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "dd/MM/yyyy"
            
            let date : Date = dateFormatterGet.date(from:val.value(forKey: "customer_lipometry_datetime") as! String)!
            
            if (val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Double > max_value){
                max_value = val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Double;
            }
            
            let chart_v = ChartDataEntry(x: (Double(i+1)), y: val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Double);
            
            chart_v.data = dateFormatterGet.string(from: date)
            
            //return ChartDataEntry(x: Double(NSNumber(value: date.timeIntervalSince1970)), y: val.value(forKey: linePlotLabels[lineSelectedIndex]) as! Double);
            
            return chart_v
        }
        
        let leftAxis = chartView.leftAxis
        let xAxis = chartView.xAxis
        
        leftAxis.axisMaximum = max_value + (max_value / 5)
        leftAxis.axisMinimum = 0
        
        xAxis.removeAllLimitLines()
        
        setT = LineChartDataSet(entries: values, label: "")
        
        setT.drawIconsEnabled = false
        
        //setT.lineDashLengths = [5, 2.5]
        //setT.highlightLineDashLengths = [5, 2.5]
        //setT.setColor(self.themeProvider.currentTheme.textBlueColor)
        //setT.setCircleColor(self.themeProvider.currentTheme.textBlueColor)
        
        if (lineSelectedIndex == 0 ){
            setT.setColor(UIColor.colorFromHex("#FF951A"))
            setT.setCircleColor(UIColor.colorFromHex("#FF5C26"))
        }else if (lineSelectedIndex == 1){
            setT.setColor(UIColor.colorFromHex("#ff5e57"))
            setT.setCircleColor(UIColor.colorFromHex("#ff3f34"))
        }else if (lineSelectedIndex == 2){
            setT.setColor(UIColor.colorFromHex("#0be881"))
            setT.setCircleColor(UIColor.colorFromHex("#05c46b"))
        }
        
        setT.lineWidth = 4
        setT.circleRadius = 5
        setT.drawCircleHoleEnabled = false
        setT.valueFont = .boldSystemFont(ofSize: 12)
        setT.formLineDashLengths = [5, 2.5]
        setT.formLineWidth = 1
        setT.formSize = 15
        setT.valueTextColor = self.themeProvider.currentTheme.textBlueColor
        
        
        setT.notifyDataSetChanged()
        
        let data = LineChartData(dataSet: setT)
        
        chartView.data = data
        
        if (zoomIn){
            chartView.zoom(scaleX: 4, scaleY: 0, x: 10000, y: 0)
        }
        
        // Ensure label generation matches our simple 1...N x values
        chartView.xAxis.centerAxisLabelsEnabled = false
        chartView.xAxis.granularityEnabled = true
        chartView.xAxis.granularity = 1
        
        chartView.setNeedsDisplay()
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleFilled:
            if (!chartView_1.isHidden){
                for set in chartView_1.data!.dataSets as! [LineChartDataSet] {
                    set.drawFilledEnabled = !set.drawFilledEnabled
                }
                chartView_1.setNeedsDisplay()
            }else if (!chartView_2.isHidden){
                for set in chartView_2.data!.dataSets as! [LineChartDataSet] {
                    set.drawFilledEnabled = !set.drawFilledEnabled
                }
                chartView_2.setNeedsDisplay()
            }else if (!chartView_3.isHidden){
                for set in chartView_3.data!.dataSets as! [LineChartDataSet] {
                    set.drawFilledEnabled = !set.drawFilledEnabled
                }
                chartView_3.setNeedsDisplay()
            }else if (!chartView_4.isHidden){
                for set in chartView_4.data!.dataSets as! [LineChartDataSet] {
                    set.drawFilledEnabled = !set.drawFilledEnabled
                }
                chartView_4.setNeedsDisplay()
            }else if (!chartView_5.isHidden){
                for set in chartView_5.data!.dataSets as! [LineChartDataSet] {
                    set.drawFilledEnabled = !set.drawFilledEnabled
                }
                chartView_5.setNeedsDisplay()
            }
        case .toggleCircles:
            if (!chartView_1.isHidden){
                for set in chartView_1.data!.dataSets as! [LineChartDataSet] {
                    set.drawCirclesEnabled = !set.drawCirclesEnabled
                }
                chartView_1.setNeedsDisplay()
            }else if (!chartView_2.isHidden){
                for set in chartView_2.data!.dataSets as! [LineChartDataSet] {
                    set.drawCirclesEnabled = !set.drawCirclesEnabled
                }
                chartView_2.setNeedsDisplay()
            }else if (!chartView_3.isHidden){
                for set in chartView_3.data!.dataSets as! [LineChartDataSet] {
                    set.drawCirclesEnabled = !set.drawCirclesEnabled
                }
                chartView_3.setNeedsDisplay()
            }
            else if (!chartView_4.isHidden){
                for set in chartView_4.data!.dataSets as! [LineChartDataSet] {
                    set.drawCirclesEnabled = !set.drawCirclesEnabled
                }
                chartView_4.setNeedsDisplay()
            }else if (!chartView_5.isHidden){
                for set in chartView_5.data!.dataSets as! [LineChartDataSet] {
                    set.drawCirclesEnabled = !set.drawCirclesEnabled
                }
                chartView_5.setNeedsDisplay()
            }
        case .toggleCubic:
            if (!chartView_1.isHidden){
                for set in chartView_1.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
                }
                chartView_1.setNeedsDisplay()
            }else if (!chartView_2.isHidden){
                for set in chartView_2.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
                }
                chartView_2.setNeedsDisplay()
            }else if (!chartView_3.isHidden){
                for set in chartView_3.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
                }
                chartView_3.setNeedsDisplay()
            }else if (!chartView_4.isHidden){
                for set in chartView_4.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
                }
                chartView_4.setNeedsDisplay()
            }else if (!chartView_5.isHidden){
                for set in chartView_5.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
                }
                chartView_5.setNeedsDisplay()
            }
            
        case .toggleStepped:
            if (!chartView_1.isHidden){
                for set in chartView_1.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .stepped) ? .linear : .stepped
                }
                chartView_1.setNeedsDisplay()
            }else if (!chartView_2.isHidden){
                for set in chartView_2.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .stepped) ? .linear : .stepped
                }
                chartView_2.setNeedsDisplay()
            }else if (!chartView_3.isHidden){
                for set in chartView_3.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .stepped) ? .linear : .stepped
                }
                chartView_3.setNeedsDisplay()
            }else if (!chartView_4.isHidden){
                for set in chartView_4.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .stepped) ? .linear : .stepped
                }
                chartView_4.setNeedsDisplay()
            }else if (!chartView_5.isHidden){
                for set in chartView_5.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .stepped) ? .linear : .stepped
                }
                chartView_5.setNeedsDisplay()
            }
            
        case .toggleHorizontalCubic:
            if (!chartView_1.isHidden){
                for set in chartView_1.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
                }
                chartView_1.setNeedsDisplay()
            }else if (!chartView_2.isHidden){
                for set in chartView_2.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
                }
                chartView_2.setNeedsDisplay()
            }else if (!chartView_3.isHidden){
                for set in chartView_3.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
                }
                chartView_3.setNeedsDisplay()
            }else if (!chartView_4.isHidden){
                for set in chartView_4.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
                }
                chartView_4.setNeedsDisplay()
            }else if (!chartView_5.isHidden){
                for set in chartView_5.data!.dataSets as! [LineChartDataSet] {
                    set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
                }
                chartView_5.setNeedsDisplay()
            }
            
        default:
            if (!chartView_1.isHidden){
                super.handleOption(option, forChartView: chartView_1)
            }else if (!chartView_2.isHidden){
                super.handleOption(option, forChartView: chartView_2)
            }else if (!chartView_3.isHidden){
                super.handleOption(option, forChartView: chartView_3)
            }else if (!chartView_4.isHidden){
                super.handleOption(option, forChartView: chartView_4)
            }else if (!chartView_5.isHidden){
                super.handleOption(option, forChartView: chartView_5)
            }
        }
    }
    
    @IBAction func change_tab(_ sender: UISegmentedControl) {
        self.navigationItem.title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        
        switch sender.selectedSegmentIndex {
        case 0:
            chartView_1.isHidden = false
            chartView_2.isHidden = true
            chartView_3.isHidden = true
            chartView_4.isHidden = true
            chartView_5.isHidden = true
            break
        case 1:
            chartView_1.isHidden = true
            chartView_2.isHidden = false
            chartView_3.isHidden = true
            chartView_4.isHidden = true
            chartView_5.isHidden = true
            break
        case 2:
            chartView_1.isHidden = true
            chartView_2.isHidden = true
            chartView_3.isHidden = false
            chartView_4.isHidden = true
            chartView_5.isHidden = true
            break
        case 3:
            chartView_1.isHidden = true
            chartView_2.isHidden = true
            chartView_3.isHidden = true
            chartView_4.isHidden = false
            chartView_5.isHidden = true
            break
        case 4:
            chartView_1.isHidden = true
            chartView_2.isHidden = true
            chartView_3.isHidden = true
            chartView_4.isHidden = true
            chartView_5.isHidden = false
            break
        default:
            break
        }
    }
    
    func read_measures_value(){
        linePlotArray_1 = ModelManager.getInstance().q("SELECT customer_lipometry_datetime,customer_lipometry_baros FROM customer_lipometry WHERE customer_lipometry_baros > 0 ORDER BY customer_lipometry_id")
        
        linePlotArray_2 = ModelManager.getInstance().q("SELECT customer_lipometry_datetime,customer_lipometry_lipos FROM customer_lipometry WHERE customer_lipometry_lipos > 0 ORDER BY customer_lipometry_id")
        
        linePlotArray_3 = ModelManager.getInstance().q("SELECT customer_lipometry_datetime,customer_lipometry_myiki_maza FROM customer_lipometry WHERE customer_lipometry_myiki_maza > 0 ORDER BY customer_lipometry_id")
        
        linePlotArray_4 = ModelManager.getInstance().q("SELECT customer_lipometry_datetime,customer_lipometry_splaxniko_lipos FROM customer_lipometry WHERE customer_lipometry_splaxniko_lipos > 0 ORDER BY customer_lipometry_id")
        
        
        weekPlotArray = ModelManager.getInstance().line("SELECT * FROM week")
        
        if (linePlotArray_1.count > 0){
            setDataCount(0, zoomIn: showBool, chartView: &chartView_1, setT: &set1 )
        }
        
        if (linePlotArray_2.count > 0){
            setDataCount(1, zoomIn: showBool, chartView: &chartView_2, setT: &set2)
        }
        
        if (linePlotArray_3.count > 0){
            setDataCount(2, zoomIn: showBool, chartView: &chartView_3, setT: &set3)
        }
        
        if (linePlotArray_4.count > 0){
            setDataBarChartCount(3, zoomIn: showBool, chartView: &chartView_4, setT: &set4)
        }
        
        if (weekPlotArray.count > 0){
            setDataBarChartWeek(4, zoomIn: showBool, chartView: &chartView_5, setT: &set5)
        }
        
        showBool = false
    }
    
    func read_measures(){
        if !Reachability.isConnectedToNetwork(){
            OperationQueue.main.addOperation {
                self.read_measures_value()
            }
            
            return;
        }
        
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
                
                ModelManager.getInstance().deleteAll("customer_lipometry")
                ModelManager.getInstance().deleteAll("week")
                
                let values_week : NSMutableDictionary = NSMutableDictionary()
                values_week.setValue(json_response.value(forKey: "week_name_5") as! String, forKey: "week_name_5")
                values_week.setValue(json_response.value(forKey: "week_name_4") as! String, forKey: "week_name_4")
                values_week.setValue(json_response.value(forKey: "week_name_3") as! String, forKey: "week_name_3")
                values_week.setValue(json_response.value(forKey: "week_name_2") as! String, forKey: "week_name_2")
                values_week.setValue(json_response.value(forKey: "week_name_1") as! String, forKey: "week_name_1")
                
                values_week.setValue(json_response.value(forKey: "week_value_5") as! String, forKey: "week_value_5")
                values_week.setValue(json_response.value(forKey: "week_value_4") as! String, forKey: "week_value_4")
                values_week.setValue(json_response.value(forKey: "week_value_3") as! String, forKey: "week_value_3")
                values_week.setValue(json_response.value(forKey: "week_value_2") as! String, forKey: "week_value_2")
                values_week.setValue(json_response.value(forKey: "week_value_1") as! String, forKey: "week_value_1")
                
                if let latest_checkin = json_response.value(forKey: "latest_checkin") as? String {
                    values_week.setValue(latest_checkin, forKey: "latest_checkin")
                }
                
                ModelManager.getInstance().insert("week", valuesDictionary: values_week)
                
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
                
                //evaluation
                ModelManager.getInstance().deleteAll("customer_lipometry_evaluation")
                
                //Getting the JSON array teams from the response
                
                    let data_rec: NSDictionary = json_response.value(forKey: "evaluation") as? NSDictionary ?? NSDictionary()
                
                if (data_rec.object(forKey: "evaluation_date") != nil){
                    let values : NSMutableDictionary = NSMutableDictionary()
                
                    values.setValue(data_rec.value(forKey: "evaluation_date"), forKey: "customer_lipometry_evaluation_date")
                    values.setValue(data_rec.value(forKey: "evaluation_question_1"), forKey: "customer_lipometry_evaluation_q1")
                    values.setValue(data_rec.value(forKey: "evaluation_question_2"), forKey: "customer_lipometry_evaluation_q2")
                    values.setValue(data_rec.value(forKey: "evaluation_question_3"), forKey: "customer_lipometry_evaluation_q3")
                    values.setValue(data_rec.value(forKey: "evaluation_question_4"), forKey: "customer_lipometry_evaluation_q4")
                    values.setValue(data_rec.value(forKey: "evaluation_question_5"), forKey: "customer_lipometry_evaluation_q5")
                    values.setValue(data_rec.value(forKey: "evaluation_question_6"), forKey: "customer_lipometry_evaluation_q6")
                    values.setValue(data_rec.value(forKey: "evaluation_question_7"), forKey: "customer_lipometry_evaluation_q7")
                    values.setValue(data_rec.value(forKey: "evaluation_question_8"), forKey: "customer_lipometry_evaluation_q8")
                
                    ModelManager.getInstance().insert("customer_lipometry_evaluation", valuesDictionary: values)
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
    
    override func updateChartData() {
        if (!chartView_1.isHidden){
            setDataCount(0, zoomIn: false, chartView: &chartView_1, setT: &set1)
        }else if (!chartView_2.isHidden){
            setDataCount(1, zoomIn: false, chartView: &chartView_2, setT: &set2)
        }else if (!chartView_3.isHidden){
            setDataCount(2, zoomIn: false, chartView: &chartView_3, setT: &set3)
        }else if (!chartView_4.isHidden){
            setDataBarChartCount(3, zoomIn: false, chartView: &chartView_4, setT: &set4)
        }else if  (!chartView_5.isHidden){
            setDataBarChartWeek(4, zoomIn: showBool, chartView: &chartView_5, setT: &set5)
        }
    }
    
    @objc func showNotes(){
        let data_evaluation : NSDictionary = ModelManager.getInstance().line("SELECT customer_lipometry_evaluation_date FROM customer_lipometry_evaluation")
        if (data_evaluation.object(forKey: "customer_lipometry_evaluation_date") != nil){
            performSegue(withIdentifier: "showEvaluationNote", sender: nil)
        }else{
            let alert = UIAlertController(title: NSLocalizedString("alert",comment: "alert"), message: NSLocalizedString("no_diet_pdf_found",comment: "no_diet_pdf_found"), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK",comment: "OK"), style: .default, handler: { action in }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = SegControls.titleForSegment(at: 0)
        
        self.pdfButton = UIBarButtonItem(image: UIImage(named: "pdf"), style: UIBarButtonItem.Style.done, target: self, action: #selector(showPDF))
        self.pdfButton.isEnabled = true
        
        let button = UIBarButtonItem(image: UIImage(named: "note"), style: UIBarButtonItem.Style.done, target: self, action: #selector(showNotes))
        
        navigationItem.leftBarButtonItem = button
        navigationItem.rightBarButtonItem = self.pdfButton
        
        setUpTheming()
        
        // Do any additional setup after loading the view.
        self.options = [.toggleValues,
                        .toggleFilled,
                        .toggleCircles,
                        .toggleCubic,
                        .toggleHorizontalCubic,
                        .toggleIcons,
                        .toggleStepped,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData]
        
        init_chartView(&chartView_1)
        init_chartView(&chartView_2)
        init_chartView(&chartView_3)
        init_chartBarView(&chartView_4)
        init_chartBarView(&chartView_5)
        
        let marker = XYPerMarkerView(color: UIColor.colorFromHex("#1B9CFC"),
                                     font: .boldSystemFont(ofSize: 13),
                                     textColor: .white,
                                     insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                     xAxisValueFormatter: chartView_2.xAxis.valueFormatter!)
        marker.chartView = chartView_2
        marker.minimumSize = CGSize(width: 40, height: 40)
        
        chartView_2.marker = marker
        
        
        set1 = LineChartDataSet()
        set2 = LineChartDataSet()
        set3 = LineChartDataSet()
        set4 = BarChartDataSet()
        set5 = BarChartDataSet()
        
        chartView_1.isHidden = false
    }
    
    func init_chartBarView(_ chartView:inout BarChartView){
        chartView.delegate = self
        
        chartView.chartDescription.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 0, weight: .regular)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        // Disable center labels to avoid centeredEntries/entries mismatch
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularityEnabled = true
        xAxis.granularity = 1
        xAxis.removeAllLimitLines()
        xAxis.gridColor = UIColor.colorFromHex("#eeeeee")
        
        /*xAxis.valueFormatter = DateValueFormatter()*/
        
        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        
        leftAxis.axisMaximum = 100
        leftAxis.axisMinimum = 0
        leftAxis.drawLimitLinesBehindDataEnabled = false
        leftAxis.labelFont = .systemFont(ofSize: 8, weight: .regular)
        leftAxis.gridColor = UIColor.colorFromHex("#cccccc")
        
        chartView.rightAxis.enabled = false
        
        let marker = XYIntMarkerView(color: UIColor.colorFromHex("#1B9CFC"),
                                     font: .boldSystemFont(ofSize: 13),
                                     textColor: .white,
                                     insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                     xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 40, height: 40)
        
        
        chartView.marker = marker
        
        chartView.legend.form = .none
    }
    
    func init_chartView(_ chartView:inout LineChartView){
        chartView.delegate = self
        
        chartView.chartDescription.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 0, weight: .regular)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        // Disable center labels to avoid centeredEntries/entries mismatch
        xAxis.centerAxisLabelsEnabled = false
        xAxis.granularityEnabled = true
        xAxis.granularity = 1
        xAxis.removeAllLimitLines()
        xAxis.gridColor = UIColor.colorFromHex("#eeeeee")
        
        /*xAxis.valueFormatter = DateValueFormatter()*/
        
        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        
        leftAxis.axisMaximum = 100
        leftAxis.axisMinimum = 0
        leftAxis.drawLimitLinesBehindDataEnabled = false
        leftAxis.labelFont = .systemFont(ofSize: 8, weight: .regular)
        leftAxis.gridColor = UIColor.colorFromHex("#cccccc")
        
        chartView.rightAxis.enabled = false
        
        let marker = XYKgMarkerView(color: UIColor.colorFromHex("#1B9CFC"),
                                    font: .boldSystemFont(ofSize: 13),
                                    textColor: .white,
                                    insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                    xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 40, height: 40)
        
        
        chartView.marker = marker
        
        chartView.legend.form = .none
        
        //chartView.animate(xAxisDuration: 2.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if (MeasuresViewController.readData){
            read_measures()
            
            MeasuresViewController.readData = false
        }
        
        self.pdfButton.isEnabled = true
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
            HTTP.POST(GlobalVar.URL+"somatometrisis_check_pdf.php", parameters:parameters_arr) { response in
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
}

extension MeasuresViewController:  URLSessionDownloadDelegate {
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
}

extension MeasuresViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        
        SegControls.tintColor = theme.textBlueColor
        
        let leftAxis_1 = chartView_1.leftAxis
        let xAxis_1 = chartView_1.xAxis
        
        leftAxis_1.labelTextColor = theme.textColor
        xAxis_1.labelTextColor = theme.textColor
        
        
        let leftAxis_2 = chartView_2.leftAxis
        let xAxis_2 = chartView_2.xAxis
        
        leftAxis_2.labelTextColor = theme.textColor
        xAxis_2.labelTextColor = theme.textColor
        
        
        let leftAxis_3 = chartView_3.leftAxis
        let xAxis_3 = chartView_3.xAxis
        
        leftAxis_3.labelTextColor = theme.textColor
        xAxis_3.labelTextColor = theme.textColor
        
        
        let leftAxis_4 = chartView_4.leftAxis
        let xAxis_4 = chartView_4.xAxis
        
        leftAxis_4.labelTextColor = theme.textColor
        xAxis_4.labelTextColor = theme.textColor
        
        let leftAxis_5 = chartView_5.leftAxis
        let xAxis_5 = chartView_5.xAxis
        
        leftAxis_5.labelTextColor = theme.textColor
        xAxis_5.labelTextColor = theme.textColor
        
        if (set1 != nil){
            set1.valueTextColor = theme.textBlueColor
            //set1.setColor(self.themeProvider.currentTheme.textBlueColor)
            //set1.setCircleColor(self.themeProvider.currentTheme.textBlueColor)
            set1.notifyDataSetChanged()
        }
        
        if (set2 != nil){
            set2.valueTextColor = theme.textBlueColor
            //set2.setColor(self.themeProvider.currentTheme.textBlueColor)
            //set2.setCircleColor(self.themeProvider.currentTheme.textBlueColor)
            set2.notifyDataSetChanged()
        }
        
        if (set3 != nil){
            set3.valueTextColor = theme.textBlueColor
            //set3.setColor(self.themeProvider.currentTheme.textBlueColor)
            //set3.setCircleColor(self.themeProvider.currentTheme.textBlueColor)
            set3.notifyDataSetChanged()
        }
        
        if (set4 != nil){
            set4.valueTextColor = theme.textBlueColor
            //set4.setColor(self.themeProvider.currentTheme.textBlueColor)
            set4.notifyDataSetChanged()
        }
        
        if (set5 != nil){
            set5.valueTextColor = theme.textBlueColor
            //set5.setColor(self.themeProvider.currentTheme.textBlueColor)
            set5.notifyDataSetChanged()
        }
        
        
    }
}
