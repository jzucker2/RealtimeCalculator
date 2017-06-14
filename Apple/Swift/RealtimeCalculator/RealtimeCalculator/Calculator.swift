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
    
    var myLocalResult: CalculatorResult {
        return CalculatorResult.localResult(publisher: network.uuid, currentTotal: currentTotal, inputValue: inputValue)
    }
    
    @objc private(set) dynamic var otherResult: CalculatorResult?
    @objc private(set) dynamic var myRemoteResult: CalculatorResult?
    
    private(set) var currentLockedOperation: CalculatorLockedOperation? = nil
    
    func add(lockedOperation: CalculatorLockedOperation) throws -> Bool {
        currentLockedOperation = lockedOperation
        return true
    }
    
    func add(value: CalculatorValue) throws -> Bool {
        if currentLockedOperation != nil {
            if currentTotal == 0 {
                currentTotal = inputValue
                inputValue = 0
            } else {
                print("ELSE!!!!!!")
                myRemoteResult = nil
            }
            print("has current locked operation and currentTotal == 0")
        } else {
            myRemoteResult = nil
            currentTotal = 0
            inputValue = 0
            print("has NO current locked operation and currentTotal is NOT 0")
        }
        inputValue = (inputValue * 10.0) + value.doubleValue
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
            if let actualUpdatedResult = result.result {
                currentTotal = actualUpdatedResult
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
