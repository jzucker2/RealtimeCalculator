//
//  CalculatorCollectionViewCell.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/12/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

struct CalculatorCellUpdate {
    let text: String
    let font: UIFont
    let textColor: UIColor
    let backgroundColor: UIColor
    
    static func update(from displayButton: CalculatorDisplayButton) -> CalculatorCellUpdate {
        return CalculatorCellUpdate(text: displayButton.displaySymbol, font: UIFont.boldSystemFont(ofSize: 42.0), textColor: displayButton.textColor, backgroundColor: displayButton.backgroundColor)
    }
    
}

class CalculatorCollectionViewCell: UICollectionViewCell {
    
    let displayLabel = UILabel(frame: .zero)
    let ghostView = UIView(frame: .zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(displayLabel)
        contentView.addSubview(ghostView)
        ghostView.isHidden = true
        ghostView.sizeAndCenter(with: contentView)
        ghostView.clipsToBounds = true
        ghostView.layer.cornerRadius = frame.size.width/2.0
        ghostView.layer.borderWidth = 5.0
        ghostView.layer.borderColor = UIColor.white.cgColor
        displayLabel.sizeAndCenter(with: contentView)
        displayLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func update(with calculatorButton: CalculatorDisplayButton) {
//        displayLabel.text = calculatorButton.displaySymbol
//        displayLabel.font = UIFont.boldSystemFont(ofSize: 42.0)
//        displayLabel.textColor = calculatorButton.textColor
//        contentView.backgroundColor = calculatorButton.backgroundColor
//        contentView.setNeedsLayout()
//    }
    func update(with update: CalculatorCellUpdate) {
        displayLabel.text = update.text
        displayLabel.font = update.font
        displayLabel.textColor = update.textColor
        contentView.backgroundColor = update.backgroundColor
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
