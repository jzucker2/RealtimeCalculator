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
    
    let publisherLabel = UILabel(frame: .zero)
    let resultLabel = UILabel(frame: .zero)
    let stackView = UIStackView(frame: .zero)
    let timeLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.axis = .horizontal
        stackView.alignment = .fill
//        stackView.distribution = .fill
        stackView.distribution = .fillProportionally
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        resultLabel.textAlignment = .center
        timeLabel.textAlignment = .center
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(publisherLabel)
        stackView.addArrangedSubview(resultLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(using update: CalculatorHeaderFooterUpdate?) {
        if let actualTimestamp = update?.time {
            timeLabel.isHidden = false
            timeLabel.text = DateDisplay.resultHeaderFooterFormatter.string(from: actualTimestamp)
        } else {
            timeLabel.isHidden = true
            timeLabel.text = ""
        }
        if let actualPublisher = update?.publisher {
            publisherLabel.isHidden = false
            publisherLabel.text = String(actualPublisher.prefix(8))
        } else {
            publisherLabel.text = ""
            publisherLabel.isHidden = true
        }
        stackView.setNeedsLayout()
    }
    
}

final class CalculatorResultFooterView: CalculatorResultHeaderFooterView {
    
    override func update(using update: CalculatorHeaderFooterUpdate?) {
        super.update(using: update)
        guard let actualUpdate = update else {
            resultLabel.text = "No result"
            return
        }
        if let actualResult = actualUpdate.result {
            resultLabel.text = "\(actualResult)"
        }
        stackView.setNeedsLayout()
    }
    
}

final class CalculatorResultHeaderView: CalculatorResultHeaderFooterView {
    
    override func update(using update: CalculatorHeaderFooterUpdate?) {
        super.update(using: update)
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
        stackView.setNeedsLayout()
    }
    
}
