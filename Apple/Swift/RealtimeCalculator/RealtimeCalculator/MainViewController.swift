//
//  ViewController.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 5/3/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let calculator: Calculator
    
    let stackView: UIStackView = {
        let settingUpStackView = UIStackView(frame: .zero)
        settingUpStackView.axis = .vertical
        settingUpStackView.distribution = .fill
        settingUpStackView.alignment = .fill
        return settingUpStackView
    } ()
    var collectionView: CalculatorCollectionView!
    
    let dataSource = CalculatorCollectionViewDataSource()
    var dataSourceAdapter: CalculatorCollectionViewDataSourceAdapter!
    var resultView: CalculatorResultHeaderView?
    
    var observingCurrentValueToken: NSKeyValueObservation?
    
    required init(calculator: Calculator) {
        self.calculator = calculator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.frame = view.frame
        let layout = CalculatorCollectionViewLayout()
        self.collectionView = CalculatorCollectionView(frame: view.bounds, collectionViewLayout: layout)
        dataSourceAdapter = CalculatorCollectionViewDataSourceAdapter(collectionView: collectionView, dataSource: dataSource, with: { (headerView) -> (Double) in
            return self.calculator.currentValue
        })
        collectionView.dataSource = dataSourceAdapter
        collectionView.delegate = self
        stackView.addArrangedSubview(collectionView)
        collectionView.reloadData()
        self.observingCurrentValueToken = calculator.observe(\.currentValue, changeHandler: { (calculator, change) in
            let firstHeaderIndexPath = IndexPath(item: 0, section: 0)
            self.dataSourceAdapter.updateResultHeaderView(at: firstHeaderIndexPath)
        })
        stackView.setNeedsLayout()
    }

}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#function)")
        do {
            let buttonPressed = dataSource[indexPath]
            let _ = try self.calculator.performOperation(for: buttonPressed)
        } catch {
            print("CalculatorError: \(error.localizedDescription)")
        }
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: view.bounds.width, height: 100.0)
        default:
            return CGSize.zero
        }
    }
    
}

