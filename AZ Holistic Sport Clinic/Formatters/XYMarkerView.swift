//
//  XYMarkerView.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class XYMarkerView: BalloonMarker {
    public var xAxisValueFormatter: AxisValueFormatter
    fileprivate var yFormatter = NumberFormatter()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: AxisValueFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if (entry.data == nil){
            setLabel(yFormatter.string(from: NSNumber(floatLiteral: entry.y))!)
            return
        }
        
        let date = entry.data as! String
        let string = date
            + ": "
            + yFormatter.string(from: NSNumber(floatLiteral: entry.y))!
        
        setLabel(string)
    }
    
}
