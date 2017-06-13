//
//  CalculatorCollectionView.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/12/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class CalculatorCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundColor = .clear
        register(CalculatorCollectionViewCell.self, forCellWithReuseIdentifier: CalculatorCollectionViewCell.reuseIdentifier())
        register(CalculatorResultHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CalculatorResultHeaderView.reuseIdentifier())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
