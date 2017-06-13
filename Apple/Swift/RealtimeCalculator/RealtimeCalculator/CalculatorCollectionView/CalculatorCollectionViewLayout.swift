//
//  CalculatorCollectionViewLayout.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/12/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class CalculatorCollectionViewLayout: UICollectionViewFlowLayout {
    
    override required init() {
        super.init()
        itemSize = CGSize(width: 30.0, height: 30.0)
        scrollDirection = .vertical
        headerReferenceSize = CGSize(width: 100.0, height: 50.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
