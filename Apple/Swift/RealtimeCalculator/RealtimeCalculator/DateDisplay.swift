//
//  DateDisplay.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/20/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation

struct DateDisplay {
    
    static let resultHeaderFooterFormatter: DateFormatter = {
        let resultDateFormatter = DateFormatter()
        resultDateFormatter.dateStyle = .none
        resultDateFormatter.timeStyle = .long
        return resultDateFormatter
    } ()
    
}
