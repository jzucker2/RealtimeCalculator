//
//  ViewController.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 5/3/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

protocol CalculatorDisplayButton {
    var displaySymbol: String { get }
    var backgroundColor: UIColor { get }
}

extension CalculatorSpecialOperation: CalculatorDisplayButton {
    
    var displaySymbol: String {
        switch self {
        case .clear:
            return "AC"
        case .equal:
            return "="
        }
    }
    
    var backgroundColor: UIColor {
        return UIColor.cyan
    }
    
}

extension CalculatorLockedOperation: CalculatorDisplayButton {
    
    var displaySymbol: String {
        switch self {
        case .add:
            return "+"
        case .subtract:
            return "-"
        case .divide:
            return "/"
        case .mutiply:
            return "x"
        }
    }
    
    var backgroundColor: UIColor {
        return UIColor.orange
    }
    
}

extension CalculatorValue: CalculatorDisplayButton {
    
    var displaySymbol: String {
        return "\(intValue)"
    }
    
    var backgroundColor: UIColor {
        return UIColor.lightGray
    }
    
}

class ViewController: UIViewController {
    
    var calculator: Calculator!
    
//    @IBOutlet weak var currentValueLabel: UILabel!
//    @IBOutlet weak var oneButton: UIButton!
//    @IBOutlet weak var twoButton: UIButton!
//    @IBOutlet weak var threeButton: UIButton!
//    @IBOutlet weak var equalButton: UIButton!
//    @IBOutlet weak var clearButton: UIButton!
//    @IBOutlet weak var addButton: UIButton!
    
    var collectionView: CalculatorCollectionView!
    
    struct CalculatorCollectionViewDataSource {
        
        let sections = [[CalculatorValue.one, CalculatorValue.two, CalculatorValue.three, CalculatorLockedOperation.mutiply], [CalculatorValue.four, CalculatorValue.five, CalculatorValue.six, CalculatorLockedOperation.add], [CalculatorValue.seven, CalculatorValue.eight, CalculatorValue.nine, CalculatorLockedOperation.subtract], [CalculatorValue.zero, CalculatorSpecialOperation.clear, CalculatorSpecialOperation.equal, CalculatorLockedOperation.divide]]
        
        subscript(section: Int) -> [CalculatorDisplayButton] {
            guard let calculatorDisplayButtonSection = sections[section] as? [CalculatorDisplayButton] else {
                fatalError()
            }
            return calculatorDisplayButtonSection
        }
        
        subscript(indexPath: IndexPath) -> CalculatorDisplayButton {
            return self[indexPath.section][indexPath.item]
        }
        
    }
    
    let dataSource = CalculatorCollectionViewDataSource()
    var resultView: CalculatorDisplayHeader!
    
    var observingCurrentValueToken: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = CalculatorCollectionViewLayout()
        self.collectionView = CalculatorCollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.reloadData()
        self.observingCurrentValueToken = calculator.observe(\.currentValue, changeHandler: { (calculator, change) in
            self.updateHeaderLabel(with: calculator.currentValue)
        })
    }
//        oneButton.tag = CalculatorValue.one.intValue
//        twoButton.tag = CalculatorValue.two.intValue
//        threeButton.tag = CalculatorValue.three.intValue
//
//        oneButton.addTarget(self, action: #selector(valueButtonPressed(sender:)), for: .touchUpInside)
//        twoButton.addTarget(self, action: #selector(valueButtonPressed(sender:)), for: .touchUpInside)
//        threeButton.addTarget(self, action: #selector(valueButtonPressed(sender:)), for: .touchUpInside)
//        equalButton.addTarget(self, action: #selector(equalButtonPressed(sender:)), for: .touchUpInside)
//        addButton.addTarget(self, action: #selector(lockedOperationButtonPressed(sender:)), for: .touchUpInside)
//        clearButton.addTarget(self, action: #selector(clearButtonPressed(sender:)), for: .touchUpInside)
//    }
        
//    private var observerVCKVOContext = 0
//
//    var observingCalculator: Calculator? {
//        didSet {
//            let observingKeyPaths = [#keyPath(Calculator.currentValue)]
//            observingKeyPaths.forEach { (keyPath) in
//                oldValue?.removeObserver(self, forKeyPath: keyPath, context: &observerVCKVOContext)
//                self.observingCalculator?.addObserver(self, forKeyPath: keyPath, options: [.new, .old, .initial], context: &observerVCKVOContext)
//            }
//        }
//    }
//
//    deinit {
//        observingCalculator = nil
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        observingCalculator = calculator // get foo from wherever, this will update UI
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        // make sure to remove currentFoo to remove
//        // listeners (can optionally just add/remove
//        // listeners instead), but it's important that
//        // there be no KVO updates when the view is off
//        // screen, in case anything goes out of scope
//        // and is deallocated (deinit is usually too late)
//        observingCalculator = nil
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if context == &observerVCKVOContext {
//            print("KVO: \(String(describing: keyPath))")
//            guard let existingKeyPath = keyPath else {
//                return
//            }
//            switch existingKeyPath {
//            case #keyPath(Calculator.currentValue):
//            // Do KVO based update here
//                print("new current value in view controller: \(calculator.currentValue)")
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
////                currentValueLabel.text = "\(calculator.currentValue)"
//            default:
//                fatalError("We did not implement this keyPath (\(existingKeyPath)) so how did we end up here?")
//            }
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//    }
    
//    @objc func lockedOperationButtonPressed(sender: UIButton) {
//        _ = try! calculator.add(lockedOperation: .add)
//    }
//    
//    @objc func clearButtonPressed(sender: UIButton) {
//        _ = try! calculator.perform(special: .clear)
//    }
//    
//    @objc func valueButtonPressed(sender: UIButton) {
//        guard let actualValue = CalculatorValue.value(from: sender.tag) else {
//            print("nothing to input!!!!!!!")
//            return
//        }
//        _ = try! calculator.add(value: actualValue)
//    }
//    
//    @objc func equalButtonPressed(sender: UIButton) {
//        _ = try! calculator.perform(special: .equal)
//    }
    
    // UI Updates
    
    func updateHeaderLabel(with currentResult: Double) {
        DispatchQueue.main.async {
            self.resultView.update(using: currentResult)
        }
    }


}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#function)")
        do {
            let buttonPressed = dataSource[indexPath]
            let _ = try self.calculator.performOperation(for: buttonPressed)
        } catch {
            print("CalculatorError: \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: view.bounds.width, height: 100.0)
        default:
            return CGSize.zero
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let calculatorHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CalculatorDisplayHeader.reuseIdentifier(), for: indexPath) as? CalculatorDisplayHeader else {
            fatalError()
        }
        let firstHeaderIndexPath = IndexPath(item: 0, section: 0)
        guard indexPath == firstHeaderIndexPath else {
            return calculatorHeaderView
        }
        self.resultView = calculatorHeaderView
        calculatorHeaderView.update(using: calculator.currentValue)
        return calculatorHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let calculatorCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalculatorCollectionViewCell.reuseIdentifier(), for: indexPath) as? CalculatorCollectionViewCell else {
            fatalError()
        }
        let calculatorButton = dataSource[indexPath]
        calculatorCell.update(with: calculatorButton)
        return calculatorCell
    }
    
}

