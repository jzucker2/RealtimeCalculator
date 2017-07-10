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

extension Double {
    var arrayOfDigits: [Double] {
        return description.characters.flatMap { Double(String($0)) }
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
    
    subscript(button: CalculatorDisplayButton) -> IndexPath {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.enumerated() {
                guard let currentButton = item as? CalculatorDisplayButton else {
                    fatalError()
                }
                if currentButton.displaySymbol == button.displaySymbol {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                } else {
                    continue
                }
            }
        }
        fatalError()
    }
    
    func get(with digit: Int) -> IndexPath {
        guard digit >= 0 && digit <= 9 else {
            fatalError()
        }
        let digitString = "\(digit)"
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.enumerated() {
                guard let currentButton = item as? CalculatorDisplayButton else {
                    fatalError()
                }
                if currentButton.displaySymbol == digitString {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                } else {
                    continue
                }
            }
        }
        fatalError()
    }
    
    subscript (value: Double) -> [IndexPath] {
        return value.arrayOfDigits.map({ (digit) -> IndexPath in
            guard let intDigit = Int(exactly: digit) else {
                fatalError()
            }
            return get(with: intDigit)
        })
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
        calculatorCell.update(with: CalculatorCellUpdate.update(from: calculatorButton))
        return calculatorCell
    }
    
}
