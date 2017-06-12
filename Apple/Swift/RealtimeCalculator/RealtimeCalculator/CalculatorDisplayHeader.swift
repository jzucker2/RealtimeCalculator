//
//  CalculatorDisplayHeader.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/12/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class CalculatorDisplayHeader: UICollectionReusableView {
    
    let displayLabel: UILabel
    
    override init(frame: CGRect) {
        self.displayLabel = UILabel(frame: frame)
        super.init(frame: frame)
        addSubview(displayLabel)
        displayLabel.translatesAutoresizingMaskIntoConstraints = false
        displayLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        displayLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        //        displayLabel.centerXAnchor.constraintEqualToSystemSpacingAfter(contentView.centerXAnchor, multiplier: 1.0).isActive = true
        //        displayLabel.centerYAnchor.constraintEqualToSystemSpacingBelow(contentView.centerYAnchor, multiplier: 1.0).isActive = true
        displayLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        displayLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        displayLabel.textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(using value: Int) {
        update(with: "\(value)")
    }
    
    func update(with result: String) {
        displayLabel.text = result
        displayLabel.setNeedsLayout()
    }
    
}
