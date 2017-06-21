//
//  CalculatorCollectionViewDataSource.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/13/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

protocol CalculatorDisplayButton {
    var displaySymbol: String { get }
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
}

extension CalculatorDisplayButton {
    
    var textColor: UIColor {
        return UIColor.black
    }
    
    var backgroundColor: UIColor {
        return UIColor.lightGray
    }
    
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
        case .multiply:
            return "x"
        case .unknown:
            fatalError()
        }
    }
    
    var textColor: UIColor {
        return .white
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

struct CalculatorCollectionViewDataSource {
    
    let sections = [[CalculatorValue.one, CalculatorValue.two, CalculatorValue.three, CalculatorLockedOperation.multiply], [CalculatorValue.four, CalculatorValue.five, CalculatorValue.six, CalculatorLockedOperation.add], [CalculatorValue.seven, CalculatorValue.eight, CalculatorValue.nine, CalculatorLockedOperation.subtract], [CalculatorValue.zero, CalculatorSpecialOperation.clear, CalculatorSpecialOperation.equal, CalculatorLockedOperation.divide]]
    
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

typealias ResultUpdateBlock = (CalculatorResultHeaderFooterView) -> (CalculatorHeaderFooterUpdate?)

class CalculatorCollectionViewDataSourceAdapter: NSObject {
    let dataSource: CalculatorCollectionViewDataSource
    weak var collectionView: CalculatorCollectionView?
    let resultUpdate: ResultUpdateBlock
    
    required init(collectionView: CalculatorCollectionView, dataSource: CalculatorCollectionViewDataSource, with resultUpdate: @escaping ResultUpdateBlock) {
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.resultUpdate = resultUpdate
        super.init()
    }
    
    func update(supplementary view: CalculatorResultHeaderFooterView) {
        let updatedResult = resultUpdate(view)
//        view.update(with: updatedResult)
        view.update(using: updatedResult)
    }
    
}

extension CalculatorCollectionViewDataSourceAdapter: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reuseIdentifier = ((kind == UICollectionElementKindSectionHeader) ? CalculatorResultHeaderView.reuseIdentifier() : CalculatorResultFooterView.reuseIdentifier())
        guard let resultHeaderFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as? CalculatorResultHeaderFooterView else {
            fatalError()
        }
        update(supplementary: resultHeaderFooterView)
        return resultHeaderFooterView
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
