//
//  IntAxisValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class IntAxisValueFormatter: NSObject, ValueFormatter,AxisValueFormatter {
    /// **default**: suffix: ["", "k", "m", "b", "t"]
    public var suffix = ["", "k", "m", "b", "t"]
    
    /// An appendix text to be added at the end of the formatted value.
    public var appendix: String?
    
    public init(appendix: String? = nil) {
        self.appendix = appendix
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(round(value)))"
    }
    
    fileprivate func format(value: Double) -> String {
        var sig = value
        var length = 0
        let maxLength = suffix.count - 1
        
        while sig >= 1000.0 && length < maxLength {
            sig /= 1000.0
            length += 1
        }
        
        var r = String(format: "%2.f", sig) + suffix[length]
        
        if let appendix = appendix {
            r += appendix
        }
        
        return r
    }

    public func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String {
        
        return "\(Int(round(value)))"
    }
}
