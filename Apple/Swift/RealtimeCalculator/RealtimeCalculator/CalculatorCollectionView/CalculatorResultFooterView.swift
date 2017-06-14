//
//  CalculatorResultFooterView.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/13/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class CalculatorResultHeaderFooterView: UICollectionReusableView {
    
    let resultLabel = UILabel(frame: .zero)
    let stackView = UIStackView(frame: .zero)
    let timeLabel = UILabel(frame: .zero)
    
    override init(frame: CGRect) {
//        self.displayLabel = UILabel(frame: frame)
        super.init(frame: frame)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        addSubview(stackView)
//        stackView.frame = frame
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        //        displayLabel.centerXAnchor.constraintEqualToSystemSpacingAfter(contentView.centerXAnchor, multiplier: 1.0).isActive = true
        //        displayLabel.centerYAnchor.constraintEqualToSystemSpacingBelow(contentView.centerYAnchor, multiplier: 1.0).isActive = true
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
    
    func update(with result: CalculatorResult?) {
        defer {
            stackView.setNeedsLayout()
        }
        guard let actualResult = result else {
            resultLabel.text = "No result"
            return
        }
        if let actualResult = actualResult.result {
            resultLabel.text = "\(actualResult)"
        }
        timeLabel.text = "\(actualResult.time)"
    }
}

final class CalculatorResultFooterView: CalculatorResultHeaderFooterView {
    
}

final class CalculatorResultHeaderView: CalculatorResultHeaderFooterView {
    
}
