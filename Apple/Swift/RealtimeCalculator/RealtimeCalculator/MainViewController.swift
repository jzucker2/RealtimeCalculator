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
//            let firstHeaderIndexPath = IndexPath(item: 0, section: 0)
//            guard let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: firstHeaderIndexPath) as? CalculatorResultHeaderView else {
//                fatalError()
//            }
//            self.dataSourceAdapter.update(supplementary: headerView)
            self.dataSourceAdapter.update(to: .header)
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
                    calculatorCell.isSelectedInterface = false
                })
            }
        })
        
        self.observingOtherRemoteResultValueToken = calculator.observe(\.otherResult, changeHandler: { (calculator, change) in
//            let lastFooterIndexPath = IndexPath(item: 0, section: 3)
//            guard let footerView = self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: lastFooterIndexPath) as? CalculatorResultFooterView else {
//                fatalError()
//            }
            
//            if let inputValue = calculator.otherResult?.inputValue {
//                let updatedIndexPaths = self.dataSource[inputValue]
//                for indexPath in updatedIndexPaths {
//                    guard let calculatorCell = self.collectionView.cellForItem(at: indexPath) as? CalculatorCollectionViewCell else {
//                        fatalError()
//                    }
//                    // TODO: Clean this up and add true selection
//                    calculatorCell.isGhostSelectedInterface = true
//                }
//            }
//            self.dataSourceAdapter.update(supplementary: footerView)
//            self.dataSourceAdapter.update(supplementary: footerView, displaying: .inputValue)
            guard let otherResult = calculator.otherResult else {
                return
            }
            guard let inputValue = otherResult.inputValue, let currentTotal = otherResult.currentTotal else {
                return
            }
            let inputValueIndexPaths = self.dataSource[inputValue]
            let currentTotalIndexPaths = self.dataSource[currentTotal]
            
            let buttonPressSelection: (Bool, [IndexPath]) -> (Void) = { (shouldSelect, indexPaths) in
                for indexPath in indexPaths {
                    guard let calculatorCell = self.collectionView.cellForItem(at: indexPath) as? CalculatorCollectionViewCell else {
                        fatalError()
                    }
                    print("buttonPressSelection with shouldSelect: \(shouldSelect), time: \(Date())")
                    calculatorCell.isGhostSelectedInterface = shouldSelect
                    calculatorCell.layoutIfNeeded()
                }
            }
            
            let animationDuration = 3.0
            
            UIView.animateKeyframes(withDuration: 4.0, delay: 0.0, options: [], animations: {
                let defaultDuration = 1.0/7.0
                let relativeStartTime: (Int) -> (TimeInterval) = { sequenceNumber in
                    guard sequenceNumber != 0 else {
                        return 0.0
                    }
//                    return 1.0/(Double(exactly: sequenceNumber)! * defaultDuration)
                    return 0.0 + defaultDuration * Double(exactly: sequenceNumber)!
                }
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                    print("1: \(Date())")
                    buttonPressSelection(true, currentTotalIndexPaths)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                    print("2: \(Date())")
                    self.dataSourceAdapter.update(to: .footer, displaying: .currentTotal)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.50, relativeDuration: 0.25, animations: {
                    print("3: \(Date())")
                    buttonPressSelection(false, currentTotalIndexPaths)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                    print("4: \(Date())")
                    self.dataSourceAdapter.update(to: .footer, displaying: .result)
                })
//                UIView.addKeyframe(withRelativeStartTime: relativeStartTime(0), relativeDuration: defaultDuration, animations: {
//                    print("1: \(Date())")
//                    buttonPressSelection(true, currentTotalIndexPaths)
//                })
//                UIView.addKeyframe(withRelativeStartTime: relativeStartTime(1), relativeDuration: defaultDuration, animations: {
//                    print("2: \(Date())")
//                    self.dataSourceAdapter.update(to: .footer, displaying: .currentTotal)
//                })
//                UIView.addKeyframe(withRelativeStartTime: relativeStartTime(2), relativeDuration: defaultDuration, animations: {
//                    print("3: \(Date())")
//                    buttonPressSelection(false, currentTotalIndexPaths)
//                })
//                UIView.addKeyframe(withRelativeStartTime: relativeStartTime(3), relativeDuration: defaultDuration, animations: {
//                    buttonPressSelection(true, inputValueIndexPaths)
//                })
//                UIView.addKeyframe(withRelativeStartTime: relativeStartTime(4), relativeDuration: defaultDuration, animations: {
//                    self.dataSourceAdapter.update(to: .footer, displaying: .inputValue)
//                })
//                UIView.addKeyframe(withRelativeStartTime: relativeStartTime(5), relativeDuration: defaultDuration, animations: {
//                    buttonPressSelection(false, inputValueIndexPaths)
//                })
//                UIView.addKeyframe(withRelativeStartTime: relativeStartTime(6), relativeDuration: defaultDuration, animations: {
//                    self.dataSourceAdapter.update(to: .footer, displaying: .result)
//                })
            }, completion: { (finished) in
                print("done: \(Date())")
            })
            
//            UIView.animate(withDuration: animationDuration, animations: {
//                print("1: \(Date())")
//                buttonPressSelection(true, currentTotalIndexPaths)
//            }, completion: { (finished) in
//                print("2: \(Date())")
//                print("finished: \(finished)")
//                UIView.animate(withDuration: animationDuration, animations: {
//                    print("3: \(Date())")
//                    buttonPressSelection(false, currentTotalIndexPaths)
//                }, completion: { (_) in
//                    print("4: \(Date())")
//                    UIView.animate(withDuration: animationDuration, animations: {
//                        print("5: \(Date())")
//                        self.dataSourceAdapter.update(to: .footer, displaying: .currentTotal)
//                    }, completion: { (_) in
//                        print("6: \(Date())")
//                        UIView.animate(withDuration: animationDuration, animations: {
//                            print("7: \(Date())")
//                            buttonPressSelection(true, inputValueIndexPaths)
//                        }, completion: { (_) in
//                            print("8: \(Date())")
//                            UIView.animate(withDuration: animationDuration, animations: {
//                                print("9: \(Date())")
//                                buttonPressSelection(false, inputValueIndexPaths)
//                            }, completion: { (_) in
//                                print("10: \(Date())")
//                                UIView.animate(withDuration: animationDuration, animations: {
//                                    print("11: \(Date())")
//                                    self.dataSourceAdapter.update(to: .footer, displaying: .inputValue)
//                                }, completion: { (_) in
//                                    print("12: \(Date())")
//                                    UIView.animate(withDuration: animationDuration, animations: {
//                                        print("13: \(Date())")
//                                        self.dataSourceAdapter.update(to: .footer, displaying: .result)
//                                    }, completion: { (_) in
//                                        print("14: \(Date())")
//                                        print("done!")
//                                    })
//                                })
//                            })
//                        })
//                    })
//                })
//            })
            
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
        calculatorCell.isSelectedInterface = true
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
        calculatorCell.isSelectedInterface = false
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let layout = collectionViewLayout as? CalculatorCollectionViewLayout else {
            fatalError()
        }
        switch section {
        case layout.resultHeaderIndexPath.section:
            return CGSize(width: view.bounds.width, height: 100.0)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let layout = collectionViewLayout as? CalculatorCollectionViewLayout else {
            fatalError()
        }
        switch section {
        case layout.resultFooterIndexPath.section:
            return CGSize(width: view.bounds.width, height: 100.0)
        default:
            return CGSize.zero
        }
    }
    
}

