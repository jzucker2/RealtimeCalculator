//
//  CalculatorCollectionViewCell.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/12/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class CalculatorCollectionViewCell: UICollectionViewCell {
    
    let displayLabel: UILabel
    
    override init(frame: CGRect) {
        self.displayLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(displayLabel)
        displayLabel.forceAutolayout()
        displayLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0).isActive = true
        displayLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0).isActive = true
        displayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        displayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        displayLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with calculatorButton: CalculatorDisplayButton) {
        displayLabel.text = calculatorButton.displaySymbol
        displayLabel.textColor = calculatorButton.textColor
        contentView.backgroundColor = calculatorButton.backgroundColor
        contentView.setNeedsLayout()
    }
    
    var isOutlined: Bool = false {
        didSet {
            switch isOutlined {
            case true:
                contentView.layer.borderWidth = 3.0
                contentView.layer.borderColor = UIColor.red.cgColor
            case false:
                contentView.layer.borderWidth = 0.0
                contentView.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
}
