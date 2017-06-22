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
    
    var observingMyRemoteResultToken: NSKeyValueObservation?
    var observingOtherRemoteResultValueToken: NSKeyValueObservation?
    var observingInputValueToken: NSKeyValueObservation?
    var observingDisplayValueToken: NSKeyValueObservation?
    var observingLockedOperationValueToken: NSKeyValueObservation?
    
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
        let currentResultUpdate: ResultUpdateBlock = { (headerFooterView) in
            switch headerFooterView {
            case _ as CalculatorResultHeaderView:
                return self.calculator.localHeaderUpdate
            case _ as CalculatorResultFooterView:
                return self.calculator.otherResult?.headerFooterUpdate(of: .footer)
            default:
                fatalError()
            }
        }
        dataSourceAdapter = CalculatorCollectionViewDataSourceAdapter(collectionView: collectionView, dataSource: dataSource, with: currentResultUpdate)
        collectionView.dataSource = dataSourceAdapter
        collectionView.delegate = self
        collectionView.allowsSelection = true
        stackView.addArrangedSubview(collectionView)
        collectionView.reloadData()
        self.observingDisplayValueToken = calculator.observe(\.displayValue, changeHandler: { (calculator, change) in
            let firstHeaderIndexPath = IndexPath(item: 0, section: 0)
            guard let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: firstHeaderIndexPath) as? CalculatorResultHeaderView else {
                fatalError()
            }
            self.dataSourceAdapter.update(supplementary: headerView)
        })
        self.observingLockedOperationValueToken = calculator.observe(\.currentLockedOperationRawValue, changeHandler: { (calculator, change) in
            guard calculator.currentLockedOperation == nil else {
                return
            }
            DispatchQueue.main.async {
                guard let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems else {
                    return
                }
                selectedIndexPaths.forEach({ (indexPath) in
                    print("deselect at \(indexPath)")
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                    guard let calculatorCell = self.collectionView.cellForItem(at: indexPath) as? CalculatorCollectionViewCell else {
                        fatalError()
                    }
                    calculatorCell.isOutlined = false
                })
            }
        })
        
        self.observingOtherRemoteResultValueToken = calculator.observe(\.otherResult, changeHandler: { (calculator, change) in
            let lastFooterIndexPath = IndexPath(item: 0, section: 3)
            guard let footerView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: lastFooterIndexPath) as? CalculatorResultFooterView else {
                fatalError()
            }
            self.dataSourceAdapter.update(supplementary: footerView)
        })
        stackView.setNeedsLayout()
    }

}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            fatalError()
        }
        let buttonPressed = self.dataSource[indexPath]
        let buttonOperationBlock: (Bool?) -> (Void) = { finished in
            do {
                let _ = try self.calculator.performOperation(for: buttonPressed)
            } catch {
                print("CalculatorError: \(error.localizedDescription)")
            }
        }
        var shouldRunOperationAfterAnimations = true
        if let specialOperation = buttonPressed as? CalculatorSpecialOperation, specialOperation == CalculatorSpecialOperation.equal {
            shouldRunOperationAfterAnimations = false
            buttonOperationBlock(nil)
        }
        
        cell.animateButtonPress { (finished) -> (Void) in
            if shouldRunOperationAfterAnimations {
                buttonOperationBlock(finished)
            }
        }
        switch buttonPressed {
        case _ as CalculatorLockedOperation:
            return true
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let calculatorCell = collectionView.cellForItem(at: indexPath) as? CalculatorCollectionViewCell else {
            fatalError()
        }
        calculatorCell.isOutlined = true
    }
    
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        let buttonPressed = self.dataSource[indexPath]
//        switch buttonPressed {
//        case _ as CalculatorLockedOperation:
//            return true
//        default:
//            return false
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let calculatorCell = collectionView.cellForItem(at: indexPath) as? CalculatorCollectionViewCell else {
            fatalError()
        }
        calculatorCell.isOutlined = false
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch section {
        case 3:
            return CGSize(width: view.bounds.width, height: 100.0)
        default:
            return CGSize.zero
        }
    }
    
}

