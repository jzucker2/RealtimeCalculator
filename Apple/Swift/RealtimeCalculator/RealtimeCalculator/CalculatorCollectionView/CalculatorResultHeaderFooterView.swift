//
//  CalculatorResultFooterView.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/13/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

struct CalculatorHeaderFooterUpdate {
    let publisher: String?
    let time: Date?
    let result: Double?
    let inputValue: Double?
    let currentTotal: Double?
}

class CalculatorResultHeaderFooterView: UICollectionReusableView {
    
    let resultLabel = UILabel(frame: .zero)
    let stackView = UIStackView(frame: .zero)
    let timeLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        resultLabel.textAlignment = .center
        timeLabel.textAlignment = .center
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(resultLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(using update: CalculatorHeaderFooterUpdate?) {
    
    }
    
//    func update(with result: CalculatorResult?) {
//        defer {
//            stackView.setNeedsLayout()
//        }
//        guard let actualResult = result else {
//            resultLabel.text = "No result"
//            return
//        }
//        if let actualResult = actualResult.result {
//            resultLabel.text = "\(actualResult)"
//        }
//        timeLabel.text = "\(actualResult.time)"
//    }
}

final class CalculatorResultFooterView: CalculatorResultHeaderFooterView {
    
    override func update(using update: CalculatorHeaderFooterUpdate?) {
        defer {
            stackView.setNeedsLayout()
        }
        guard let actualUpdate = update else {
            resultLabel.text = "No result"
            return
        }
        if let actualResult = actualUpdate.result {
            resultLabel.text = "\(actualResult)"
        }
//        if let actualResult = actualUpdate.result {
//            resultLabel.text = "\(actualResult)"
//        } else if let actualInputValue = actualUpdate.inputValue {
//            resultLabel.text = "\(actualInputValue)"
//        } else if let actualCurrentTotal = actualUpdate.currentTotal {
//            resultLabel.text = "\(actualCurrentTotal)"
//        }
        timeLabel.text = "\(actualUpdate.time)"
    }
    
}

final class CalculatorResultHeaderView: CalculatorResultHeaderFooterView {
    
    override func update(using update: CalculatorHeaderFooterUpdate?) {
        defer {
            stackView.setNeedsLayout()
        }
        guard let actualUpdate = update else {
            resultLabel.text = "No result"
            return
        }
        if let actualResult = actualUpdate.result {
            resultLabel.text = "\(actualResult)"
        } else if let actualInputValue = actualUpdate.inputValue {
            resultLabel.text = "\(actualInputValue)"
        } else if let actualCurrentTotal = actualUpdate.currentTotal {
            resultLabel.text = "\(actualCurrentTotal)"
        }
        timeLabel.text = "\(actualUpdate.time)"
    }
    
//    override func update(with result: CalculatorResult?) {
//        defer {
//            stackView.setNeedsLayout()
//        }
//        guard let actualResult = result else {
//            resultLabel.text = "No result"
//            return
//        }
//        if let actualResult = actualResult.result {
//            resultLabel.text = "\(actualResult)"
//        } else if let actualInputValue = actualResult.inputValue {
//            resultLabel.text = "\(actualInputValue)"
//        } else if let actualCurrentTotal = actualResult.currentTotal {
//            resultLabel.text = "\(actualCurrentTotal)"
//        }
//        timeLabel.text = "\(actualResult.time)"
//    }
    
}
