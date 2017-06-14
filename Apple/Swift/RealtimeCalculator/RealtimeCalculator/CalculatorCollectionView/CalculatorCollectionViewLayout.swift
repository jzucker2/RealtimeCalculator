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
//        itemSize = CGSize(width: 75.0, height: 75.0)
//        estimatedItemSize = CGSize(width: 75.0, height: 75.0)
        scrollDirection = .vertical
        minimumLineSpacing = 10.0
        minimumInteritemSpacing = 10.0
        sectionInset = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 5.0, right: 0.0)
        headerReferenceSize = CGSize(width: 100.0, height: 50.0)
        footerReferenceSize = CGSize(width: 100.0, height: 50.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
