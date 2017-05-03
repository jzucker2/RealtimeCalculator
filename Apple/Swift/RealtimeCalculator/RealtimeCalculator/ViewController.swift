//
//  ViewController.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 5/3/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var calculator: Calculator!
    
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var equalButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oneButton.tag = CalculatorValue.one.intValue
        twoButton.tag = CalculatorValue.two.intValue
        threeButton.tag = CalculatorValue.three.intValue
        
        oneButton.addTarget(self, action: #selector(valueButtonPressed(sender:)), for: .touchUpInside)
        twoButton.addTarget(self, action: #selector(valueButtonPressed(sender:)), for: .touchUpInside)
        threeButton.addTarget(self, action: #selector(valueButtonPressed(sender:)), for: .touchUpInside)
        equalButton.addTarget(self, action: #selector(equalButtonPressed(sender:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(lockedOperationButtonPressed(sender:)), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonPressed(sender:)), for: .touchUpInside)
    }
    
    private var observerVCKVOContext = 0
    
    var observingCalculator: Calculator? {
        didSet {
            let observingKeyPaths = [#keyPath(Calculator.currentValue)]
            observingKeyPaths.forEach { (keyPath) in
                oldValue?.removeObserver(self, forKeyPath: keyPath, context: &observerVCKVOContext)
                self.observingCalculator?.addObserver(self, forKeyPath: keyPath, options: [.new, .old, .initial], context: &observerVCKVOContext)
            }
        }
    }
    
    deinit {
        observingCalculator = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observingCalculator = calculator // get foo from wherever, this will update UI
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // make sure to remove currentFoo to remove
        // listeners (can optionally just add/remove
        // listeners instead), but it's important that
        // there be no KVO updates when the view is off
        // screen, in case anything goes out of scope
        // and is deallocated (deinit is usually too late)
        observingCalculator = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &observerVCKVOContext {
            print("KVO: \(String(describing: keyPath))")
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(Calculator.currentValue):
            // Do KVO based update here
                print("new current value in view controller: \(calculator.currentValue)")
                currentValueLabel.text = "\(calculator.currentValue)"
            default:
                fatalError("We did not implement this keyPath (\(existingKeyPath)) so how did we end up here?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func lockedOperationButtonPressed(sender: UIButton) {
        _ = try! calculator.add(lockedOperation: .add)
    }
    
    func clearButtonPressed(sender: UIButton) {
        _ = try! calculator.perform(special: .clear)
    }
    
    func valueButtonPressed(sender: UIButton) {
        guard let actualValue = CalculatorValue.value(from: sender.tag) else {
            print("nothing to input!!!!!!!")
            return
        }
        _ = try! calculator.add(value: actualValue)
    }
    
    func equalButtonPressed(sender: UIButton) {
        _ = try! calculator.perform(special: .equal)
    }


}

