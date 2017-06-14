//
//  CalculatorModels.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/13/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import Foundation
import PubNub

class CalculatorResult: NSObject {
    let publisher: String
    let firstValue: Double
    let secondValue: Double
    let operation: CalculatorLockedOperation
    let result: Double?
    let errorString: String?
    let time: Date
    
    convenience init?(publisher: String, time: Date, firstValue: Double, secondValue: Double, operationString: String, result: Double?, errorString: String? = nil) {
        guard let operation = CalculatorLockedOperation(rawValue: operationString) else {
            return nil
        }
        self.init(publisher: publisher, time: time, firstValue: firstValue, secondValue: secondValue, operation: operation, result: result, errorString: errorString)
    }
    
    required init(publisher: String, time: Date, firstValue: Double, secondValue: Double, operation: CalculatorLockedOperation, result: Double?, errorString: String? = nil) {
        self.publisher = publisher
        self.firstValue = firstValue
        self.secondValue = secondValue
        self.operation = operation
        self.result = result
        self.errorString = errorString
        self.time = time
        super.init()
    }
    
}

extension CalculatorResult {
    
//    func generateOtherPublisherString() -> String {
//        let
//        let finalString = "\()"
//    }
    
}

extension CalculatorResult {
    
    convenience init?(message: PNMessageResult) {
        guard let resultDict = message.data.message as? [String: Any] else {
            return nil
        }
        guard let actualFirstValue = resultDict[Constants.firstValue] as? Double else {
            return nil
        }
        guard let actualSecondValue = resultDict[Constants.secondValue] as? Double else {
            return nil
        }
        guard let actualOperationString = resultDict[Constants.operation] as? String else {
            return nil
        }
        let result = resultDict[Constants.result] as? Double
//        var errorString = resultDict[Constants.errorString] as? String
        self.init(publisher: message.data.publisher, time: Date(), firstValue: actualFirstValue, secondValue: actualSecondValue, operationString: actualOperationString, result: result, errorString: nil)
    }
    
}

public enum CalculatorLockedOperation: String {
    case add
    case subtract
    case mutiply
    case divide
}

public enum CalculatorSpecialOperation: String {
    case clear
    case equal
}

public enum CalculatorValue: String {
    case zero
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    
    static func value(from value: Int) -> CalculatorValue? {
        guard value >= 0 && value < 10 else {
            return nil
        }
        switch value {
        case 0:
            return .zero
        case 1:
            return .one
        case 2:
            return .two
        case 3:
            return .three
        case 4:
            return .four
        case 5:
            return .five
        case 6:
            return .six
        case 7:
            return .seven
        case 8:
            return .eight
        case 9:
            return .nine
        default:
            return nil
        }
    }
    
    var doubleValue: Double {
        return Double(intValue)
    }
    
    var intValue: Int {
        switch self {
        case .zero:
            return 0
        case .one:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        case .five:
            return 5
        case .six:
            return 6
        case .seven:
            return 7
        case .eight:
            return 8
        case .nine:
            return 9
        }
    }
    
    var numberObject: NSNumber {
        return NSNumber(value: intValue)
    }
}

enum CalculatorError: Error {
    case operationInput
    case valueInput
}
