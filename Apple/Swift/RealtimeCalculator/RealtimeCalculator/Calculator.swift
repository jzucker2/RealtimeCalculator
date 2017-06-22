//
//  Calculator.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 5/3/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

class Calculator: NSObject {
    
    let network: Network
    
    let queue = DispatchQueue(label: "com.CalculatorQueue", qos: .userInitiated, attributes: [])
    
    required init(network: Network) {
        self.network = network
        super.init()
        network.addListener(self)
    }
    
    @objc dynamic private(set) var currentTotal: Double = 0.0
    @objc dynamic private(set) var inputValue: Double = 0.0
    @objc dynamic private(set) var displayValue: Double = 0.0
    
    var localHeaderUpdate: CalculatorHeaderFooterUpdate {
        if let actualLocalResult = myRemoteResult {
            return actualLocalResult.headerFooterUpdate(of: .header)
        }
        
        return CalculatorHeaderFooterUpdate(publisher: network.uuid, time: nil, result: nil, inputValue: inputValue, currentTotal: nil)
    }
    
    @objc private(set) dynamic var otherResult: CalculatorResult?
    @objc private(set) dynamic var myRemoteResult: CalculatorResult?
    
    private(set) var currentLockedOperation: CalculatorLockedOperation? {
        get {
            guard let actualLockedOperationRawValue = currentLockedOperationRawValue else {
                return nil
            }
            return CalculatorLockedOperation(rawValue: actualLockedOperationRawValue)
        }
        set {
            self.currentLockedOperationRawValue = newValue?.rawValue
        }
    }
    @objc private(set) dynamic var currentLockedOperationRawValue: String? = nil
    
    func add(lockedOperation: CalculatorLockedOperation) throws -> Bool {
        currentLockedOperation = lockedOperation
        return true
    }
    
    func add(value: CalculatorValue) throws -> Bool {
        let addDigit: (Double) -> (Double) = { ($0 * 10.0) + value.doubleValue }
        defer {
            displayValue = inputValue
        }
        if currentLockedOperation == nil {
            if inputValue == 0.0 {
                myRemoteResult = nil
                currentTotal = 0.0
            }
            inputValue = addDigit(inputValue)
        } else {
            if currentTotal == 0.0 {
                currentTotal = inputValue
                inputValue = 0.0
            }
            if let _ = myRemoteResult {
                inputValue = 0.0
                myRemoteResult = nil
            }
            inputValue = addDigit(inputValue)
        }
        
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
        network.publish(current: currentTotal, operation: actualLockedOperation, input: inputValue) { (status) in
            self.inputValue = 0.0
            self.currentLockedOperation = nil
        }
    }
    
    func clear() {
        myRemoteResult = nil
        currentTotal = 0.0
        inputValue = 0.0
        currentLockedOperation = nil
        displayValue = 0.0
    }
    
    

}

extension Calculator: PNObjectEventListener {
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        guard let result = CalculatorResult(message: message) else {
            print("Received invalid result")
            return
        }
        // Handle own results
        if network.uuid == result.publisher {
            myRemoteResult = result
            currentLockedOperation = nil
            if let actualUpdatedResult = result.result {
                currentTotal = actualUpdatedResult
                displayValue = currentTotal
            }
        } else {
            otherResult = result
        }
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
