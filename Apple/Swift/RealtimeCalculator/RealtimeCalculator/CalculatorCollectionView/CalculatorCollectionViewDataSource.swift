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
