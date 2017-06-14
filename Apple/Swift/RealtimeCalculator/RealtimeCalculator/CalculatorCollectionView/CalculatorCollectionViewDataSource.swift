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

typealias CurrentResultUpdateBlock = (CalculatorResultHeaderView) -> (Double)
typealias LastResultUpdateBlock = (CalculatorResultFooterView) -> (CalculatorResult?)

class CalculatorCollectionViewDataSourceAdapter: NSObject {
    let dataSource: CalculatorCollectionViewDataSource
    weak var collectionView: CalculatorCollectionView?
    let currentResultUpdate: CurrentResultUpdateBlock
    let lastResultUpdate: LastResultUpdateBlock
    
    required init(collectionView: CalculatorCollectionView, dataSource: CalculatorCollectionViewDataSource, with currentResultUpdate: @escaping CurrentResultUpdateBlock, and lastResultUpdate: @escaping LastResultUpdateBlock) {
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.currentResultUpdate = currentResultUpdate
        self.lastResultUpdate = lastResultUpdate
        super.init()
    }
    
    func updateResultHeaderView(at indexPath: IndexPath) {
        guard let resultHeader = collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: indexPath) as? CalculatorResultHeaderView else {
            fatalError()
        }
        let updatedResult = currentResultUpdate(resultHeader)
        resultHeader.update(using: updatedResult)
    }
    
    func updateLastResultFooterView(at indexPath: IndexPath) {
        guard let resultFooter = collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: indexPath) as? CalculatorResultFooterView else {
            fatalError()
        }
        guard let actualLastResult = lastResultUpdate(resultFooter) else {
            print("No last result!!!!!!!!!!!!!!!!!!!!!!!!")
            return
        }
        resultFooter.update(with: actualLastResult)
//        let updatedResult = currentResultUpdate(resultHeader)
//        resultHeader.update(using: updatedResult)
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
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let calculatorHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalculatorResultHeaderView.reuseIdentifier(), for: indexPath) as? CalculatorResultHeaderView else {
                fatalError()
            }
            let firstHeaderIndexPath = IndexPath(item: 0, section: 0)
            guard indexPath == firstHeaderIndexPath else {
                return calculatorHeaderView
            }
            let result = currentResultUpdate(calculatorHeaderView)
            calculatorHeaderView.update(using: result)
            return calculatorHeaderView
        case UICollectionElementKindSectionFooter:
            guard let calculatorFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CalculatorResultFooterView.reuseIdentifier(), for: indexPath) as? CalculatorResultFooterView else {
                fatalError()
            }
            let firstFooterIndexPath = IndexPath(item: 0, section: 3)
            guard indexPath == firstFooterIndexPath else {
                return calculatorFooterView
            }
            let lastResult = lastResultUpdate(calculatorFooterView)
            calculatorFooterView.update(with: lastResult)
//            let result = resultUpdate(calculatorHeaderView)
//            calculatorHeaderView.update(using: result)
//            return calculatorHeaderView
            return calculatorFooterView
        default:
            fatalError()
        }
        
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
