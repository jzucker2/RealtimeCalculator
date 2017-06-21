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
        stackView.addArrangedSubview(collectionView)
        collectionView.reloadData()
        self.observingDisplayValueToken = calculator.observe(\.displayValue, changeHandler: { (calculator, change) in
            let firstHeaderIndexPath = IndexPath(item: 0, section: 0)
            guard let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: firstHeaderIndexPath) as? CalculatorResultHeaderView else {
                fatalError()
            }
            self.dataSourceAdapter.update(supplementary: headerView)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#function)")
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            fatalError()
        }
        let originalTransform = cell.transform
        UIView.animate(withDuration: 0.01, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .layoutSubviews, .allowAnimatedContent, .curveEaseInOut], animations: {
            cell.transform = originalTransform.scaledBy(x: 0.5, y: 0.5)
            cell.layoutIfNeeded()
        }) { (finished) in
            UIView.animate(withDuration: 0.02, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .layoutSubviews, .allowAnimatedContent, .curveEaseInOut], animations: {
                cell.transform = originalTransform.scaledBy(x: 1.1, y: 1.1)
                cell.layoutIfNeeded()
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.01, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .layoutSubviews, .allowAnimatedContent, .curveEaseInOut], animations: {
                    cell.transform = originalTransform
                    cell.layoutIfNeeded()
                }, completion: { (finished) in
                    do {
                        let buttonPressed = self.dataSource[indexPath]
                        let _ = try self.calculator.performOperation(for: buttonPressed)
                    } catch {
                        print("CalculatorError: \(error.localizedDescription)")
                    }
                })
            })
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch section {
        case 3:
            return CGSize(width: view.bounds.width, height: 100.0)
        default:
            return CGSize.zero
        }
    }
    
}

