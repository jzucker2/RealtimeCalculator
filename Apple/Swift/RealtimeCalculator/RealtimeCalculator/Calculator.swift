//
//  Calculator.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 5/3/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

enum CalculatorLockedOperation: String {
    case add
    case subtract
    case mutiply
    case divide
}

enum CalculatorSpecialOperation: String {
    case clear
    case equal
}

enum CalculatorValue: String {
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

class Calculator: NSObject {
    
    override init() {
        super.init()
        Network.shared.addListener(self)
    }
    
    private var firstValue: Double = 0
    private var _currentValue: Double = 0
    @objc public dynamic var currentValue: Double {
        get {
            return self._currentValue
        }
        set {
            self._currentValue = newValue
        }
    }
    private var currentLockedOperation: CalculatorLockedOperation? = nil
    
    func add(lockedOperation: CalculatorLockedOperation) throws -> Bool {
        print("add locked operation: \(lockedOperation.rawValue)")
        currentLockedOperation = lockedOperation
        return true
    }
    
    func add(value: CalculatorValue) throws -> Bool {
        if currentLockedOperation != nil && firstValue == 0 {
            firstValue = currentValue
            currentValue = 0
        }
        currentValue = (currentValue * 10.0) + value.doubleValue
        return true
    }
    
    func perform(special operation: CalculatorSpecialOperation) throws -> Bool {
        switch operation {
        case .clear:
            clear()
        case .equal:
            equal()
        }
        return true
    }
    
    func equal() {
        guard let actualLockedOperation = currentLockedOperation else {
            print("Nothing to publish!")
            return
        }
        Network.shared.publish(firstValue: firstValue, operation: actualLockedOperation, secondValue: currentValue)
        firstValue = 0
    }
    
    func clear() {
        firstValue = 0
        currentValue = 0
        currentLockedOperation = nil
    }
    
    

}

extension Calculator: PNObjectEventListener {
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        guard let expectedMessageBody = message.data.message as? [String: Any] else {
            print("Received unexpected message body type: \(message.debugDescription)")
            return
        }
        guard let result = expectedMessageBody[Constants.result] as? Double else {
            print("Did not find result")
            return
        }
        guard Network.shared.uuid == message.data.publisher else {
            print("Published by someone else: \(message.data.publisher)")
            return
        }
        currentValue = result
    }
}

extension Calculator {
    
    func performOperation(for calculatorButton: CalculatorDisplayButton) throws -> Bool {
        do {
            switch calculatorButton {
            case let valueButton as CalculatorValue:
                print("valueButton: \(valueButton)")
                return try self.add(value: valueButton)
            case let lockedOperationButton as CalculatorLockedOperation:
                print("lockedOperation: \(lockedOperationButton)")
                return try self.add(lockedOperation: lockedOperationButton)
            case let specialOperationButton as CalculatorSpecialOperation:
                print("specialOperation: \(specialOperationButton)")
                return try self.perform(special: specialOperationButton)
            default:
                fatalError()
            }
        } catch {
            throw error
        }
    }
    
}
