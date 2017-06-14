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
    
    private var firstValue: Double = 0
    private var _currentValue: Double = 0
    @objc public dynamic var lastResult: CalculatorResult?
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
        network.publish(firstValue: firstValue, operation: actualLockedOperation, secondValue: currentValue)
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
        if network.uuid == message.data.publisher {
            currentValue = result
        } else {
            print("Published by someone else: \(message.data.publisher)")
            guard let actualOtherResult = CalculatorResult(message: message) else {
                return
            }
            lastResult = actualOtherResult
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
