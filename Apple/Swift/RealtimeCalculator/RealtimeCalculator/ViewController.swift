//
//  ViewController.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 5/3/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let calculator: Calculator
    
    var collectionView: CalculatorCollectionView!
    
    let dataSource = CalculatorCollectionViewDataSource()
    var resultView: CalculatorResultHeaderView?
    
    var observingCurrentValueToken: NSKeyValueObservation?
    
    required init(calculator: Calculator) {
        self.calculator = calculator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
    
    // UI Updates
    
    func updateHeaderLabel(with currentResult: Double) {
        DispatchQueue.main.async {
            self.resultView?.update(using: currentResult)
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
        guard let calculatorHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CalculatorResultHeaderView.reuseIdentifier(), for: indexPath) as? CalculatorResultHeaderView else {
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

