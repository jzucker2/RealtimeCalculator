//
//  CalculatorCollectionViewCell.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/12/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class CalculatorCollectionViewCell: UICollectionViewCell {
    
    let displayLabel = UILabel(frame: .zero)
    let ghostView = UIView(frame: .zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(displayLabel)
        displayLabel.sizeAndCenter(with: contentView)
        displayLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with calculatorButton: CalculatorDisplayButton) {
        displayLabel.text = calculatorButton.displaySymbol
        displayLabel.font = UIFont.boldSystemFont(ofSize: 42.0)
        displayLabel.textColor = calculatorButton.textColor
        contentView.backgroundColor = calculatorButton.backgroundColor
        contentView.setNeedsLayout()
    }
    
    var isSelectedInterface: Bool = false {
        didSet {
            defer {
                contentView.setNeedsLayout()
            }
            switch isSelectedInterface {
            case true:
                contentView.layer.borderWidth = 3.0
                contentView.layer.borderColor = UIColor.red.cgColor
            case false:
                contentView.layer.borderWidth = 0.0
                contentView.layer.borderColor = UIColor.black.cgColor
            }
        }
    }
    
    var isGhostSelectedInterface: Bool = false {
        didSet {
            ghostView.isHidden = !isGhostSelectedInterface
            contentView.setNeedsLayout()
        }
    }
    
}
